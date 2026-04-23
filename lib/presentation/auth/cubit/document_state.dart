import '../../../domain/entities/document.dart';

abstract class DocumentState {}

class DocumentInitial extends DocumentState {}

class DocumentLoading extends DocumentState {}

class DocumentLoaded extends DocumentState {
  final List<Document> documents;
  DocumentLoaded({required this.documents});
}

class DocumentOperationSuccess extends DocumentState {
  final String message;
  final Document? document;
  DocumentOperationSuccess({required this.message, this.document});
}

class DocumentError extends DocumentState {
  final String message;
  DocumentError({required this.message});
}
