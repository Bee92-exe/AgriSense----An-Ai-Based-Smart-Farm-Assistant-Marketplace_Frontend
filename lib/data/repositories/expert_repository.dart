import '../models/diagnosis.dart';
import '../models/enums.dart';
import '../models/growth.dart';
import '../models/ops.dart';

/// The agri expert's work: review the AI's low-confidence cases, edit and
/// publish Krishi Barta drafts, and maintain the knowledge base
/// (API_SPEC §3, §9, §11).
abstract interface class ExpertRepository {
  Future<List<ReviewCase>> reviews();

  Future<List<Disease>> diseasesFor(CropType? crop);

  /// Confirms a disease (and optionally adds a note). The farmer is notified by
  /// the server; the app only reports that the case left the queue.
  Future<ReviewCase> resolve(
    String reviewId, {
    required String diseaseId,
    String? note,
  });

  /// Asks the farmer for a clearer photo. [note] is required by the API.
  Future<ReviewCase> needsRetake(String reviewId, {required String note});

  Future<List<NewsDraft>> news();

  Future<NewsDraft> saveDraft(NewsDraft draft);

  Future<NewsDraft> approveNews(String draftId, {required bool urgent});

  Future<NewsDraft> rejectNews(String draftId, {required String reason});

  /// A manual item authored by the expert (API_SPEC §9 `POST /expert/news`).
  Future<NewsDraft> addManualNews({
    required String title,
    required String summary,
    required NewsCategory category,
    required CropType crop,
    required Severity severity,
    required String advisedAction,
  });

  /// Proposes a new source for the admin to add (API_SPEC §9).
  Future<void> suggestSource({
    required String name,
    required String url,
    String? note,
  });

  Future<List<KnowledgeEntry>> knowledge({String query = ''});

  Future<KnowledgeEntry> saveKnowledge({
    required String diseaseId,
    required String protocolBn,
    required String source,
    required String safetyNoteBn,
  });

  /// Feed, farmer requests, consultation plans, bookings and peers in one call.
  /// No endpoint exists in `API_SPEC` yet, so this is the UI-first seam.
  Future<ExpertDesk> desk();

  Future<ExpertArticle> toggleLike(String articleId);

  Future<ExpertArticle> toggleSaved(String articleId);

  Future<ExpertArticle> rateArticle(String articleId, int rating);

  Future<ExpertArticle> commentOnArticle(String articleId, String body);

  /// Publishes an expert-authored article to the farmer feed.
  Future<ExpertArticle> publishArticle({
    required String title,
    required String summary,
    required String body,
    required String crop,
  });

  /// Answers a farmer request. `reply` is shown to the farmer, so it is required.
  Future<ExpertQuestion> answerQuestion(String questionId, String reply);

  /// Turns a consultation plan on or off. Subscribers keep their existing plan.
  Future<ConsultationPlan> togglePlan(String planId, bool active);

  Future<ExpertPeer> toggleConnect(String peerId);
}
