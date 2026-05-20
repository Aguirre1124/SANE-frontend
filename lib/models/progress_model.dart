class PendingStep {
  final String id;
  final String title;
  final int order;

  const PendingStep({
    required this.id,
    required this.title,
    required this.order,
  });

  factory PendingStep.fromJson(Map<String, dynamic> j) => PendingStep(
        id: j['id'] as String,
        title: j['title'] as String,
        order: j['order'] as int,
      );
}

class ProgressModel {
  final String trackerId;
  final double overallProgress;
  final int completedSteps;
  final int totalSteps;
  final bool isCompleted;
  final int daysElapsed;
  final List<PendingStep> pendingSteps;

  const ProgressModel({
    required this.trackerId,
    required this.overallProgress,
    required this.completedSteps,
    required this.totalSteps,
    required this.isCompleted,
    required this.daysElapsed,
    required this.pendingSteps,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> j) => ProgressModel(
        trackerId: j['tracker_id'] as String,
        overallProgress: (j['overall_progress'] as num).toDouble(),
        completedSteps: j['completed_steps'] as int,
        totalSteps: j['total_steps'] as int,
        isCompleted: j['is_completed'] as bool,
        daysElapsed: j['days_elapsed'] as int,
        pendingSteps: (j['pending_steps'] as List)
            .map((s) => PendingStep.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}
