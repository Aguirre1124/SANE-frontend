import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../models/diagnostic_model.dart';

final diagnosticListProvider =
    FutureProvider.family<List<DiagnosticSession>, void>((ref, _) async {
  try {
    final dio = ref.read(dioProvider);
    final res = await dio.get('/diagnostic');
    return (res.data as List)
        .map((s) => DiagnosticSession.fromJson(s as Map<String, dynamic>))
        .toList();
  } on DioException catch (e) {
    throw dioToApi(e);
  }
});

final diagnosticListRefreshProvider = StateProvider<int>((ref) => 0);

final diagnosticSessionsProvider =
    FutureProvider<List<DiagnosticSession>>((ref) async {
  ref.watch(diagnosticListRefreshProvider);
  try {
    final dio = ref.read(dioProvider);
    final res = await dio.get('/diagnostic');
    return (res.data as List)
        .map((s) => DiagnosticSession.fromJson(s as Map<String, dynamic>))
        .toList();
  } on DioException catch (e) {
    throw dioToApi(e);
  }
});

class QuestionFlowState {
  final String sessionId;
  final int totalQuestions;
  final DiagnosticQuestion currentQuestion;
  final int answeredCount;
  final bool isSubmitting;

  const QuestionFlowState({
    required this.sessionId,
    required this.totalQuestions,
    required this.currentQuestion,
    required this.answeredCount,
    this.isSubmitting = false,
  });

  QuestionFlowState copyWith({
    DiagnosticQuestion? currentQuestion,
    int? answeredCount,
    bool? isSubmitting,
  }) =>
      QuestionFlowState(
        sessionId: sessionId,
        totalQuestions: totalQuestions,
        currentQuestion: currentQuestion ?? this.currentQuestion,
        answeredCount: answeredCount ?? this.answeredCount,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );
}

class DiagnosticFlowNotifier
    extends FamilyAsyncNotifier<QuestionFlowState?, String> {
  @override
  Future<QuestionFlowState?> build(String arg) async => null;

  Future<StartDiagnosticResponse> startDiagnostic(
      {String? businessId}) async {
    try {
      final dio = ref.read(dioProvider);
      final body = <String, dynamic>{};
      if (businessId != null) body['business_id'] = businessId;
      final res = await dio.post('/diagnostic/start', data: body);
      final started = StartDiagnosticResponse.fromJson(
          res.data as Map<String, dynamic>);
      state = AsyncData(QuestionFlowState(
        sessionId: started.sessionId,
        totalQuestions: started.totalQuestions,
        currentQuestion: started.firstQuestion,
        answeredCount: 0,
      ));
      return started;
    } on DioException catch (e) {
      throw dioToApi(e);
    }
  }

  Future<AnswerResponse> answer({
    required String sessionId,
    required String questionId,
    required String optionId,
    required String rawValue,
  }) async {
    final currentState = state.asData?.value;
    if (currentState == null) throw const ApiException('Sin sesión activa', 0);

    state = AsyncData(currentState.copyWith(isSubmitting: true));

    try {
      final dio = ref.read(dioProvider);
      final res = await dio.post('/diagnostic/$sessionId/answer', data: {
        'question_id': questionId,
        'selected_option_id': optionId,
        'raw_value': rawValue,
        'time_spent_ms': 0,
      });
      final answer = AnswerResponse.fromJson(res.data as Map<String, dynamic>);

      if (!answer.isCompleted) {
        final qRes = await dio.get('/diagnostic/$sessionId/questions');
        final body = qRes.data as Map<String, dynamic>;
        // El endpoint devuelve un wrapper: {"question": {...}, "finished": bool, ...}
        final questionData = (body['question'] ?? body) as Map<String, dynamic>;
        final nextQ = DiagnosticQuestion.fromJson(questionData);
        state = AsyncData(currentState.copyWith(
          currentQuestion: nextQ,
          answeredCount: answer.totalAnswers,
          isSubmitting: false,
        ));
      } else {
        state = AsyncData(currentState.copyWith(
          answeredCount: answer.totalAnswers,
          isSubmitting: false,
        ));
      }
      return answer;
    } on DioException catch (e) {
      state = AsyncData(currentState.copyWith(isSubmitting: false));
      throw dioToApi(e);
    }
  }

  Future<DiagnosticResult> complete(String sessionId) async {
    try {
      final dio = ref.read(dioProvider);
      final res =
          await dio.post('/diagnostic/$sessionId/complete', data: {});
      return DiagnosticResult.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw dioToApi(e);
    }
  }
}

final diagnosticFlowProvider = AsyncNotifierProviderFamily<
    DiagnosticFlowNotifier, QuestionFlowState?, String>(
  DiagnosticFlowNotifier.new,
);

final diagnosticResultProvider =
    FutureProvider.family<DiagnosticResult, String>((ref, sessionId) async {
  try {
    final dio = ref.read(dioProvider);
    final res = await dio.get('/diagnostic/$sessionId/result');
    return DiagnosticResult.fromJson(res.data as Map<String, dynamic>);
  } on DioException catch (e) {
    throw dioToApi(e);
  }
});
