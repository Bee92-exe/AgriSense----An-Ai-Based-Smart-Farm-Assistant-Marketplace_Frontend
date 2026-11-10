import '../models/diagnosis.dart';
import '../models/enums.dart';
import '../models/growth.dart';
import '../models/ops.dart';
import '../repositories/expert_repository.dart';
import '../repositories/expert_review_repository.dart';
import 'api_client.dart';

/// The expert workspace against the live API.
///
/// Implements both interfaces because the review queue is the same data as the
/// rest of the desk: one instance serves `expertRepositoryProvider` and
/// `expertReviewRepositoryProvider`, so the queue badge and the review list can
/// never disagree.
class RemoteExpertRepository
    implements ExpertRepository, ExpertReviewRepository {
  RemoteExpertRepository(this._client);

  final ApiClient _client;

  // ---------------------------------------------------------------- reviews

  @override
  Future<List<ReviewCase>> reviews() async {
    final response = await _client.get('/expert/diagnoses/pending');
    final list = (response['diagnoses'] as List<dynamic>?) ?? const [];
    return list.map((raw) {
      final json = raw as Map<String, dynamic>;
      return ReviewCase(
        id: json['id'] as String,
        diagnosisId: json['id'] as String,
        farmerName: json['farmerName'] as String? ?? '',
        farmerDistrict: json['farmerLocation'] as String? ?? '',
        crop: CropType.fromWire(json['crop'] as String?),
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
        createdAt:
            DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        resolved: false,
        top3: ((json['ai_top3'] as List<dynamic>?) ?? const []).map((rawTop) {
          final top = rawTop as Map<String, dynamic>;
          return (
            Disease(
              id: top['disease_id'] as String? ?? '',
              nameBn: top['name_bn'] as String? ?? '',
              nameEn: top['name_en'] as String? ?? '',
            ),
            (top['confidence'] as num?)?.toDouble() ?? 0,
          );
        }).toList(),
        note: json['reviewReason'] as String?,
      );
    }).toList(growable: false);
  }

  @override
  Future<List<Disease>> diseasesFor(CropType? crop) async {
    // The corpus is the authority: offering a disease the retriever has no
    // protocol for would let an expert confirm an unanswerable diagnosis.
    final response = await _client.get(
      '/expert/knowledge',
      query: crop == null ? null : {'query': crop.wire},
    );
    final entries = (response['entries'] as List<dynamic>?) ?? const [];
    final seen = <String>{};
    final diseases = <Disease>[];
    for (final raw in entries) {
      final json = raw as Map<String, dynamic>;
      final id = json['disease_id'] as String? ?? '';
      if (id.isEmpty || !seen.add(id)) continue;
      diseases.add(
        Disease(
          id: id,
          nameBn: json['disease_name'] as String? ?? '',
          nameEn: json['chunk_id'] as String? ?? id,
        ),
      );
    }
    return diseases;
  }

  @override
  Future<ReviewCase> resolve(
    String reviewId, {
    required String diseaseId,
    String? diseaseName,
    String? note,
  }) async {
    await _client.put('/expert/diagnoses/$reviewId/review', body: {
      'review': note?.trim().isNotEmpty == true
          ? note!.trim()
          : 'বিশেষজ্ঞ রোগটি নিশ্চিত করেছেন।',
      'diseaseName': diseaseName ?? diseaseId,
    });
    return _resolved(reviewId, diseaseId: diseaseId, note: note);
  }

  @override
  Future<ReviewCase> needsRetake(String reviewId, {required String note}) async {
    await _client.post(
      '/expert/diagnoses/$reviewId/needs-retake',
      body: {'note': note},
    );
    return _resolved(reviewId, note: note, needsRetake: true);
  }

  ReviewCase _resolved(
    String id, {
    String? diseaseId,
    String? note,
    bool needsRetake = false,
  }) =>
      ReviewCase(
        id: id,
        diagnosisId: id,
        farmerName: '',
        farmerDistrict: '',
        crop: null,
        confidence: 0,
        createdAt: DateTime.now(),
        resolved: true,
        resolutionDiseaseId: diseaseId,
        note: note,
        needsRetake: needsRetake,
      );

  // ------------------------------------------------------------ news drafts

  @override
  Future<List<NewsDraft>> news() async {
    final response = await _client.get('/expert/news');
    return ((response['drafts'] as List<dynamic>?) ?? const [])
        .map((e) => NewsDraft.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<NewsDraft> saveDraft(NewsDraft draft) async {
    final body = <String, dynamic>{
      if (draft.id.isNotEmpty) 'id': draft.id,
      'title_bn': draft.titleBn,
      'summary_bn': draft.summaryBn,
      'symptoms_bn': draft.symptomsBn,
      'advised_action_bn': draft.advisedActionBn,
      'category': draft.category.wire,
      'severity': draft.severity.wire,
      'crop': draft.crop.wire,
      'is_urgent': draft.urgent,
      'source_name': draft.sourceName,
      'source_url': draft.sourceUrl,
      'affected_districts': draft.affectedDistricts,
    };

    final response = draft.id.isEmpty
        ? await _client.post('/expert/news', body: body)
        : await _client.put('/expert/news/${draft.id}', body: body);

    return NewsDraft.fromJson(response['draft'] as Map<String, dynamic>);
  }

  @override
  Future<NewsDraft> approveNews(String draftId, {required bool urgent}) async {
    final response = await _client.post(
      '/expert/news/$draftId/approve',
      body: {'urgent': urgent},
    );
    return NewsDraft.fromJson(response['draft'] as Map<String, dynamic>);
  }

  @override
  Future<NewsDraft> rejectNews(String draftId, {required String reason}) async {
    final response = await _client.post(
      '/expert/news/$draftId/reject',
      body: {'reason': reason},
    );
    return NewsDraft.fromJson(response['draft'] as Map<String, dynamic>);
  }

  @override
  Future<NewsDraft> addManualNews({
    required String title,
    required String summary,
    required NewsCategory category,
    required CropType crop,
    required Severity severity,
    required String advisedAction,
  }) async {
    final response = await _client.post('/expert/news', body: {
      'title_bn': title,
      'summary_bn': summary,
      'advised_action_bn': advisedAction,
      'category': category.wire,
      'severity': severity.wire,
      'crop': crop.wire,
    });
    return NewsDraft.fromJson(response['draft'] as Map<String, dynamic>);
  }

  @override
  Future<void> suggestSource({
    required String name,
    required String url,
    String? note,
  }) async {
    await _client.post('/expert/sources/suggest', body: {
      'name': name,
      'url': url,
      'note': ?note,
    });
  }

  // -------------------------------------------------------------- knowledge

  @override
  Future<List<KnowledgeEntry>> knowledge({String query = ''}) async {
    final response = await _client.get(
      '/expert/knowledge',
      query: query.trim().isEmpty ? null : {'query': query.trim()},
    );
    return ((response['entries'] as List<dynamic>?) ?? const [])
        .map((e) => KnowledgeEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<KnowledgeEntry> saveKnowledge({
    required String diseaseId,
    required String protocolBn,
    required String source,
    required String safetyNoteBn,
  }) async {
    final response = await _client.put('/expert/knowledge', body: {
      // `diseaseId` carries the chunk id from the editor; the server keys on it.
      'chunk_id': diseaseId,
      'protocol_bn': protocolBn,
      'source': source,
      'safety_note_bn': safetyNoteBn,
    });
    return KnowledgeEntry.fromJson(response['entry'] as Map<String, dynamic>);
  }

  // ------------------------------------------------------------------- desk

  @override
  Future<ExpertDesk> desk() async {
    final response = await _client.get('/expert/desk');
    return ExpertDesk.fromJson(
      response['desk'] as Map<String, dynamic>? ?? const {},
    );
  }

  @override
  Future<ExpertArticle> toggleLike(String articleId) async =>
      _article(await _client.post('/articles/$articleId/like'));

  @override
  Future<ExpertArticle> toggleSaved(String articleId) async =>
      _article(await _client.post('/articles/$articleId/save'));

  @override
  Future<ExpertArticle> rateArticle(String articleId, int rating) async =>
      _article(
        await _client.post(
          '/articles/$articleId/rating',
          body: {'rating': rating},
        ),
      );

  @override
  Future<ExpertArticle> commentOnArticle(String articleId, String body) async =>
      _article(
        await _client.post(
          '/articles/$articleId/comments',
          body: {'body': body},
        ),
      );

  ExpertArticle _article(Map<String, dynamic> response) =>
      ExpertArticle.fromJson(response['article'] as Map<String, dynamic>);

  @override
  Future<ExpertArticle> publishArticle({
    required String title,
    required String summary,
    required String body,
    required String crop,
  }) async {
    final response = await _client.post('/expert/articles', body: {
      'title': title,
      'summary': summary,
      'body': body,
      'crop': crop,
    });
    return _article(response);
  }

  @override
  Future<ExpertQuestion> answerQuestion(String questionId, String reply) async {
    final response = await _client.post(
      '/expert/questions/$questionId/answer',
      body: {'reply': reply},
    );
    return ExpertQuestion.fromJson(
      response['question'] as Map<String, dynamic>,
    );
  }

  @override
  Future<ConsultationPlan> togglePlan(String planId, bool active) async {
    final response = await _client.put(
      '/expert/plans/$planId',
      body: {'active': active},
    );
    return ConsultationPlan.fromJson(response['plan'] as Map<String, dynamic>);
  }

  @override
  Future<ExpertPeer> toggleConnect(String peerId) async {
    final response = await _client.post('/expert/peers/$peerId/connect');
    return ExpertPeer.fromJson(response['peer'] as Map<String, dynamic>);
  }
}
