import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/document_repository.dart';
import 'document_state.dart';

class DocumentCubit extends Cubit<DocumentState> {
  final DocumentRepository documentRepository;

  DocumentCubit({required this.documentRepository}) : super(DocumentInitial());

  Future<void> getDocuments(String hostelId) async {
    emit(DocumentLoading());
    try {
      final documents = await documentRepository.getDocuments(hostelId);
      emit(DocumentLoaded(documents: documents));
    } catch (e) {
      emit(DocumentError(message: e.toString()));
    }
  }

  Future<void> uploadDocument({
    required String hostelId,
    required String licenseType,
    required String licenseNumber,
    String? expiryDate,
    required String filePath,
  }) async {
    emit(DocumentLoading());
    try {
      final document = await documentRepository.uploadDocument(
        hostelId: hostelId,
        licenseType: licenseType,
        licenseNumber: licenseNumber,
        expiryDate: expiryDate,
        filePath: filePath,
      );
      emit(DocumentOperationSuccess(
        message: 'Document uploaded successfully',
        document: document,
      ));
    } catch (e) {
      emit(DocumentError(message: e.toString()));
    }
  }

  Future<void> deleteDocument(String documentId, String hostelId) async {
    emit(DocumentLoading());
    try {
      await documentRepository.deleteDocument(documentId);
      emit(DocumentOperationSuccess(
        message: 'Document deleted successfully',
      ));
      await getDocuments(hostelId);
    } catch (e) {
      emit(DocumentError(message: e.toString()));
    }
  }
}
