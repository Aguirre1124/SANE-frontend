import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/diagnostic_model.dart';
import '../../providers/diagnostic_provider.dart';
import '../../widgets/animated_orbs_background.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/premium_card.dart';
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
      body: AnimatedOrbsBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _QuestionHeader(
                onBack: () => context.pop(),
              ),
              Expanded(
                child: flowAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                  error: (e, _) => ErrorView(
                    error: e,
                    onRetry: () {
                      ref.invalidate(diagnosticFlowProvider(flowKey));
                    },
                  ),
                  data: (flow) {
                    if (flow == null) {
                      return const EmptyState(
                        icon: Icons.error_outline,
                        title: 'Sin sesión activa',
                        subtitle:
                            'Vuelve atrás e inicia un diagnóstico.',
                      );
                    }

                    return ResponsiveCenter(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        children: [
                          _ProgressHeader(
                            answered: flow.answeredCount,
                            total: flow.totalQuestions,
                          ),
                          const SizedBox(height: AppSpacing.xl),
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
                          const SizedBox(height: AppSpacing.lg),
                          _NextButton(
                            isEnabled: _selectedOptionId != null,
                            isLoading: flowAsync.value?.isSubmitting ?? false,
                            onPressed: (flow.isSubmitting ||
                                    _selectedOptionId == null)
                                ? null
                                : () => _answer(
                                    context, ref, flow, flowKey),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    )),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.surface,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
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
          PremiumCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            enableHoverEffect: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.text,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
                if (question.helpText != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    question.helpText!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.surface.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Text(
                    option.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header glassmorphism ──────────────────────────────────────────────────────

class _QuestionHeader extends StatelessWidget {
  const _QuestionHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.glassSurface,
            border: Border(
              bottom: BorderSide(color: AppColors.borderLight, width: 1),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: onBack,
                tooltip: 'Volver',
                style: IconButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Diagnóstico', style: tt.headlineMedium),
                    const SizedBox(height: 2),
                    Text(
                      'Responde las preguntas',
                      style: tt.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Next Button with glow ────────────────────────────────────────────────────

class _NextButton extends StatefulWidget {
  const _NextButton({
    required this.isEnabled,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isEnabled;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            decoration: widget.isEnabled && !widget.isLoading
                ? BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: 0.3 * _glowAnimation.value,
                        ),
                        blurRadius: 16 * _glowAnimation.value,
                        spreadRadius: 2,
                      ),
                    ],
                  )
                : null,
            child: ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lg,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                elevation: widget.isEnabled ? 8 : 0,
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      'Siguiente',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.onPrimary,
                          ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
