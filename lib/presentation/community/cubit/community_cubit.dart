import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/socket/socket_service.dart';
import '../../../data/models/community_message_model.dart';
import '../../../domain/entities/community_message.dart';
import '../../../domain/entities/community_details.dart';
import '../../../domain/repositories/community_repository.dart';

abstract class CommunityState {}

class CommunityInitial extends CommunityState {}

class CommunityLoading extends CommunityState {}

class CommunityLoaded extends CommunityState {
  final CommunityDetails details;
  final List<CommunityMessage> messages;
  final List<String> typingUsers;
  CommunityLoaded({required this.details, required this.messages, this.typingUsers = const []});
}

class CommunitySending extends CommunityState {
  final CommunityDetails details;
  final List<CommunityMessage> messages;
  final List<String> typingUsers;
  CommunitySending({required this.details, required this.messages, this.typingUsers = const []});
}

class CommunityError extends CommunityState {
  final String message;
  CommunityError({required this.message});
}

class CommunityCubit extends Cubit<CommunityState> {
  final CommunityRepository communityRepository;
  final SocketService socketService;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _stopTypingSubscription;

  CommunityCubit({required this.communityRepository, required this.socketService})
      : super(CommunityInitial()) {
    _messageSubscription = socketService.messageStream.listen(_onNewMessage);
    _typingSubscription = socketService.typingStream.listen(_onUserTyping);
    _stopTypingSubscription = socketService.stopTypingStream.listen(_onUserStoppedTyping);
  }

  void _onNewMessage(Map<String, dynamic> data) {
    if (state is CommunityLoaded || state is CommunitySending) {
      final details = (state as dynamic).details as CommunityDetails;
      final messages = List<CommunityMessage>.from((state as dynamic).messages);
      final typingUsers = List<String>.from((state as dynamic).typingUsers);
      
      final newMessage = CommunityMessageModel.fromJson(data);
      
      // Ensure we have a valid ID for comparison (socket might send id or _id)
      final newMessageId = newMessage.id.isNotEmpty ? newMessage.id : (data['id']?.toString() ?? '');

      // Prevent duplicates: Remove optimistic versions (temp_) from the same sender with matching text
      messages.removeWhere((m) => 
        (m.id.startsWith("temp_") && m.senderId == newMessage.senderId && m.text == newMessage.text) ||
        (m.id == newMessageId && newMessageId.isNotEmpty)
      );

      messages.add(newMessage);
      emit(CommunityLoaded(details: details, messages: List.unmodifiable(messages), typingUsers: typingUsers));
    }
  }

  void _onUserTyping(String userName) {
    if (state is CommunityLoaded || state is CommunitySending) {
       final details = (state is CommunityLoaded) ? (state as CommunityLoaded).details : (state as CommunitySending).details;
       final messages = (state is CommunityLoaded) ? (state as CommunityLoaded).messages : (state as CommunitySending).messages;
       final typingUsers = List<String>.from((state is CommunityLoaded) ? (state as CommunityLoaded).typingUsers : (state as CommunitySending).typingUsers);
       
       if (!typingUsers.contains(userName)) {
         typingUsers.add(userName);
         if (state is CommunityLoaded) {
           emit(CommunityLoaded(details: details, messages: messages, typingUsers: typingUsers));
         } else {
           emit(CommunitySending(details: details, messages: messages, typingUsers: typingUsers));
         }
       }
    }
  }

  void _onUserStoppedTyping(String userName) {
     if (state is CommunityLoaded || state is CommunitySending) {
       final details = (state is CommunityLoaded) ? (state as CommunityLoaded).details : (state as CommunitySending).details;
       final messages = (state is CommunityLoaded) ? (state as CommunityLoaded).messages : (state as CommunitySending).messages;
       final typingUsers = List<String>.from((state is CommunityLoaded) ? (state as CommunityLoaded).typingUsers : (state as CommunitySending).typingUsers);
       
       if (typingUsers.contains(userName)) {
         typingUsers.remove(userName);
         if (state is CommunityLoaded) {
           emit(CommunityLoaded(details: details, messages: messages, typingUsers: typingUsers));
         } else {
           emit(CommunitySending(details: details, messages: messages, typingUsers: typingUsers));
         }
       }
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _stopTypingSubscription?.cancel();
    return super.close();
  }

  Future<void> loadCommunity(String hostelId) async {
    emit(CommunityLoading());
    try {
      final results = await Future.wait([
        communityRepository.getCommunityDetails(hostelId),
        communityRepository.getMessages(hostelId),
      ]);
      emit(CommunityLoaded(
        details: results[0] as dynamic,
        messages: results[1] as dynamic,
      ));
    } catch (e) {
      emit(CommunityError(message: e.toString()));
    }
  }

  Future<void> sendMessage({
    required String hostelId,
    required String text,
    required String senderId,
    required String senderName,
    required String senderRole,
  }) async {
    if (state is! CommunityLoaded && state is! CommunitySending) return;

    final currentDetails = (state as dynamic).details as CommunityDetails;
    final messages = List<CommunityMessage>.from((state as dynamic).messages);
    final typingUsers = List<String>.from((state as dynamic).typingUsers);

    // Optimistic Update
    final tempId = "temp_${DateTime.now().millisecondsSinceEpoch}";
    final optimisticMessage = CommunityMessage(
      id: tempId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      text: text,
      createdAt: DateTime.now().toIso8601String(),
    );

    messages.add(optimisticMessage);
    emit(CommunitySending(details: currentDetails, messages: messages, typingUsers: typingUsers));

    try {
      final result = await communityRepository.sendMessage(hostelId, text);
      
      // After success, we can immediately update the optimistic message with the real one from response
      // if the backend returns the message object. 
      final realMessage = CommunityMessageModel.fromJson(result);
      
      final index = messages.indexWhere((m) => m.id == tempId);
      final alreadyExists = messages.any((m) => m.id == realMessage.id);

      if (index != -1) {
        if (alreadyExists) {
          messages.removeAt(index);
        } else {
          messages[index] = realMessage;
        }
      } else if (!alreadyExists) {
        messages.add(realMessage);
      }
      
      emit(CommunityLoaded(details: currentDetails, messages: List.unmodifiable(messages), typingUsers: typingUsers));
    } catch (e) {
      // Remove optimistic message on failure
      messages.removeWhere((m) => m.id == tempId);
      emit(CommunityLoaded(details: currentDetails, messages: List.unmodifiable(messages), typingUsers: typingUsers));
      emit(CommunityError(message: e.toString()));
    }
  }

  void setTyping(String hostelId, String userName, bool isTyping) {
    if (isTyping) {
      socketService.emitTyping(hostelId, userName);
    } else {
      socketService.emitStopTyping(hostelId, userName);
    }
  }

  void joinRoom(String hostelId, String userId, String role) {
    socketService.joinCommunity(hostelId, userId, role: role);
  }
}
