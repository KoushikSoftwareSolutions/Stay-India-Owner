import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';
import '../utils/logger.dart';

class SocketService {
  final String baseUrl;
  io.Socket? _socket;
  
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<String>.broadcast();
  final _stopTypingController = StreamController<String>.broadcast();
  final _bookingController = StreamController<Map<String, dynamic>>.broadcast();
  final _dashboardRefreshController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<String> get typingStream => _typingController.stream;
  Stream<String> get stopTypingStream => _stopTypingController.stream;
  Stream<Map<String, dynamic>> get bookingStream => _bookingController.stream;
  Stream<Map<String, dynamic>> get dashboardRefreshStream => _dashboardRefreshController.stream;

  String? _lastRoomId;
  String? _lastUserId;
  String? _lastRole;

  SocketService({required this.baseUrl});

  void connect() {
    _socket = io.io(baseUrl, io.OptionBuilder()
      .enableAutoConnect()
      .enableReconnection()
      .setReconnectionDelay(2000)
      .setReconnectionAttempts(20)
      .setTransports(['websocket', 'polling']) // Allow polling fallback
      .build());

    _socket!.onConnect((_) {
      AppLogger.info('🚀 Socket: Connected to server');
      // Auto re-join last community if exists
      if (_lastRoomId != null && _lastUserId != null) {
        AppLogger.info('🔄 Socket: Auto-rejoining room $_lastRoomId');
        joinCommunity(_lastRoomId!, _lastUserId!, role: _lastRole ?? 'OWNER');
      }
    });

    _socket!.onConnectError((err) {
      AppLogger.error('❌ Socket: Connection error: $err');
    });

    _socket!.onConnectTimeout((err) {
      AppLogger.error('❌ Socket: Connection timeout: $err');
    });

    _socket!.onError((err) {
      AppLogger.error('❌ Socket: Error: $err');
    });

    _socket!.on('joined_community', (data) {
      AppLogger.info('✅ Socket: Successfully joined room ${data['hostelId']}');
    });

    _socket!.on('new_message', (data) {
      AppLogger.debug('📩 Socket: New message received');
      _messageController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('new_booking', (data) {
      AppLogger.info('🎁 Received new_booking notification: $data');
      _bookingController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('dashboard_refresh', (data) {
      AppLogger.info('🔄 Received dashboard_refresh request: $data');
      _dashboardRefreshController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('user_typing', (data) {
      if (data['userName'] != null) {
        AppLogger.debug('✍️ Socket: User typing: ${data['userName']}');
        _typingController.add(data['userName']);
      }
    });

    _socket!.on('user_stopped_typing', (data) {
       if (data['userName'] != null) {
        _stopTypingController.add(data['userName']);
      }
    });

    _socket!.onDisconnect((_) => AppLogger.warning('👋 Socket: Disconnected from server'));
    
    _socket!.onConnectError((err) => AppLogger.error('❌ Socket: Connection error: $err'));
  }

  void joinCommunity(String hostelId, String userId, {String role = 'OWNER'}) {
    _lastRoomId = hostelId;
    _lastUserId = userId;
    _lastRole = role;

    _socket?.emit('join_community', {
      'hostelId': hostelId,
      'userId': userId,
      'role': role,
    });
  }

  void leaveCommunity(String hostelId) {
    _socket?.emit('leave_community', {
      'hostelId': hostelId,
    });
  }

  void emitTyping(String hostelId, String userName) {
    _socket?.emit('typing', {
      'hostelId': hostelId,
      'userName': userName,
    });
  }

  void emitStopTyping(String hostelId, String userName) {
    _socket?.emit('stop_typing', {
      'hostelId': hostelId,
      'userName': userName,
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
