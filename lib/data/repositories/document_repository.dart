import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/document_model.dart';

class DocumentRepository {
  final ApiClient _api;

  DocumentRepository(this._api);

  Future<List<DocumentModel>> getDocuments() async {
    final data = await _api.get(ApiEndpoints.documents);
    final list = data['documents'] as List? ?? [];
    return list.map((d) => _mapToDocumentModel(d)).toList();
  }

  Future<void> markAsRead(String id) async {
    await _api.post(ApiEndpoints.documentMarkRead(id));
  }

  Future<void> signDocument(String id) async {
    await _api.post(ApiEndpoints.documentSign(id));
  }

  /// Telecharge le PDF du document (bytes bruts)
  Future<List<int>> downloadDocument(String id) async {
    return await _api.getBytes(ApiEndpoints.documentDownload(id));
  }

  DocumentModel _mapToDocumentModel(Map<String, dynamic> d) {
    return DocumentModel(
      id: d['id'] ?? '',
      title: d['title'] ?? '',
      type: _mapDocumentType(d['type']),
      contractId: d['contractRef'],
      date: DateTime.tryParse(d['date'] ?? '') ?? DateTime.now(),
      fileUrl: d['fileUrl'] ?? '',
      fileType: d['fileType'] ?? 'pdf',
      fileSize: d['fileSize'] ?? 0,
      isRead: d['isRead'] ?? false,
      year: d['year'],
      description: d['description'],
      requiresSignature: d['requiresSignature'] ?? false,
      isSigned: d['isSigned'] ?? false,
    );
  }

  DocumentType _mapDocumentType(String? type) {
    switch (type) {
      case 'releve':
        return DocumentType.statement;
      case 'fiscal':
        return DocumentType.tax;
      case 'contrat':
        return DocumentType.contract;
      case 'notice':
        return DocumentType.notice;
      case 'attestation':
        return DocumentType.certificate;
      case 'courrier':
        return DocumentType.correspondence;
      default:
        return DocumentType.other;
    }
  }
}
