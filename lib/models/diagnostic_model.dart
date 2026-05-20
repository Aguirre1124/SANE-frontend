class DiagnosticOption {
  final String id;
  final String label;
  final String value;

  const DiagnosticOption({
    required this.id,
    required this.label,
    required this.value,
  });

  factory DiagnosticOption.fromJson(Map<String, dynamic> j) => DiagnosticOption(
        id: j['id'] as String,
        label: j['label'] as String,
        value: j['value'] as String,
      );
}

class DiagnosticQuestion {
  final String id;
  final int order;
  final String text;
  final String? helpText;
  final String category;
  final List<DiagnosticOption> options;

  const DiagnosticQuestion({
    required this.id,
    required this.order,
    required this.text,
    this.helpText,
    required this.category,
    required this.options,
  });

  factory DiagnosticQuestion.fromJson(Map<String, dynamic> j) => DiagnosticQuestion(
        id: j['id'] as String,
        order: j['order'] as int,
        text: j['text'] as String,
        helpText: j['help_text'] as String?,
        category: j['category'] as String,
        options: (j['options'] as List)
            .map((o) => DiagnosticOption.fromJson(o as Map<String, dynamic>))
            .toList(),
      );
}

class StartDiagnosticResponse {
  final String sessionId;
  final String status;
  final int totalQuestions;
  final DiagnosticQuestion firstQuestion;

  const StartDiagnosticResponse({
    required this.sessionId,
    required this.status,
    required this.totalQuestions,
    required this.firstQuestion,
  });

  factory StartDiagnosticResponse.fromJson(Map<String, dynamic> j) =>
      StartDiagnosticResponse(
        sessionId: j['session_id'] as String,
        status: j['status'] as String,
        totalQuestions: j['total_questions'] as int,
        firstQuestion: DiagnosticQuestion.fromJson(
            j['first_question'] as Map<String, dynamic>),
      );
}

class AnswerResponse {
  final bool answerSaved;
  final int totalAnswers;
  final String sessionStatus;
  final bool isCompleted;
  final String? nextQuestionId;

  const AnswerResponse({
    required this.answerSaved,
    required this.totalAnswers,
    required this.sessionStatus,
    required this.isCompleted,
    this.nextQuestionId,
  });

  factory AnswerResponse.fromJson(Map<String, dynamic> j) => AnswerResponse(
        answerSaved: j['answer_saved'] as bool,
        totalAnswers: j['total_answers'] as int,
        sessionStatus: j['session_status'] as String,
        isCompleted: j['is_completed'] as bool,
        nextQuestionId: j['next_question_id'] as String?,
      );
}

class DiagnosticResult {
  final String sessionId;
  final String riskLevel;
  final String tramiteType;
  final List<String> checklist;
  final String summary;
  final String targetEntity;
  final List<String> normativasApplied;
  final double confidenceScore;
  final String? assignedRouteId;

  const DiagnosticResult({
    required this.sessionId,
    required this.riskLevel,
    required this.tramiteType,
    required this.checklist,
    required this.summary,
    required this.targetEntity,
    required this.normativasApplied,
    required this.confidenceScore,
    this.assignedRouteId,
  });

  factory DiagnosticResult.fromJson(Map<String, dynamic> j) => DiagnosticResult(
        sessionId: j['session_id'] as String,
        riskLevel: j['risk_level'] as String,
        tramiteType: j['tramite_type'] as String,
        checklist:
            (j['checklist'] as List).map((e) => e as String).toList(),
        summary: j['summary'] as String,
        targetEntity: j['target_entity'] as String,
        normativasApplied: (j['normativas_applied'] as List)
            .map((e) => e as String)
            .toList(),
        confidenceScore: (j['confidence_score'] as num).toDouble(),
        assignedRouteId: j['assigned_route_id'] as String?,
      );
}

class DiagnosticSession {
  final String sessionId;
  final String? businessId;
  final String status;
  final String startedAt;
  final String? completedAt;
  final int? totalInteractions;

  const DiagnosticSession({
    required this.sessionId,
    this.businessId,
    required this.status,
    required this.startedAt,
    this.completedAt,
    this.totalInteractions,
  });

  factory DiagnosticSession.fromJson(Map<String, dynamic> j) => DiagnosticSession(
        sessionId: j['session_id'] as String,
        businessId: j['business_id'] as String?,
        status: j['status'] as String,
        startedAt: j['started_at'] as String,
        completedAt: j['completed_at'] as String?,
        totalInteractions: j['total_interactions'] as int?,
      );
}
