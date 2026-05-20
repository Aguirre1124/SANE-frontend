import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../models/diagnostic_model.dart';
import '../../providers/diagnostic_provider.dart';
import '../../widgets/responsive_layout.dart';

class QuestionScreen extends ConsumerStatefulWidget {
  const QuestionScreen({
    super.key,
    required this.sessionId,
    this.businessId,
  });

  final String sessionId;
  final String? businessId;

  @override
  ConsumerState<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends ConsumerState<QuestionScreen> {
  String? _selectedOptionId;
  String? _selectedValue;

  @override
  Widget build(BuildContext context) {
    final flowKey = widget.businessId ?? widget.sessionId;
    final flowAsync = ref.watch(diagnosticFlowProvider(flowKey));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Diagnóstico sanitario')),
      body: flowAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(e.toString(),
              style: const TextStyle(color: AppColors.error)),
        ),
        data: (flow) {
          if (flow == null) {
            return const Center(
              child: Text(
                'Sin sesión activa. Vuelve atrás e inicia un diagnóstico.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ResponsiveCenter(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _ProgressHeader(
                  answered: flow.answeredCount,
                  total: flow.totalQuestions,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _QuestionCard(
                    question: flow.currentQuestion,
                    selectedOptionId: _selectedOptionId,
                    onOptionSelected: (id, value) {
                      setState(() {
                        _selectedOptionId = id;
                        _selectedValue = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (flow.isSubmitting ||
                            _selectedOptionId == null)
                        ? null
                        : () => _answer(
                            context, ref, flow, flowKey),
                    child: flow.isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Siguiente'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _answer(
    BuildContext context,
    WidgetRef ref,
    QuestionFlowState flow,
    String flowKey,
  ) async {
    if (_selectedOptionId == null || _selectedValue == null) return;

    try {
      final answer = await ref
          .read(diagnosticFlowProvider(flowKey).notifier)
          .answer(
            sessionId: widget.sessionId,
            questionId: flow.currentQuestion.id,
            optionId: _selectedOptionId!,
            rawValue: _selectedValue!,
          );

      setState(() {
        _selectedOptionId = null;
        _selectedValue = null;
      });

      if (answer.isCompleted && context.mounted) {
        final result = await ref
            .read(diagnosticFlowProvider(flowKey).notifier)
            .complete(widget.sessionId);
        if (context.mounted) {
          context.pushReplacement(
              '/app/diagnostic/${widget.sessionId}/result',
              extra: result);
        }
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.message), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.answered, required this.total});

  final int answered;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? answered / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pregunta ${answered + 1} de $total',
                style: Theme.of(context).textTheme.bodyMedium),
            Text('${(progress * 100).toInt()}%',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.success)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.selectedOptionId,
    required this.onOptionSelected,
  });

  final DiagnosticQuestion question;
  final String? selectedOptionId;
  final void Function(String id, String value) onOptionSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.text,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (question.helpText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      question.helpText!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...question.options.map(
            (opt) => _OptionTile(
              option: opt,
              isSelected: selectedOptionId == opt.id,
              onTap: () => onOptionSelected(opt.id, opt.value),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final DiagnosticOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
