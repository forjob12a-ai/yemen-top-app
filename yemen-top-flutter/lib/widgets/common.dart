import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';

/// تنسيق المبالغ بالريال اليمني
String money(num v) => '${NumberFormat.decimalPattern('en').format(v.round())} ﷼';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: AppColors.orange));
}

class EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  const EmptyView({super.key, required this.icon, required this.title, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 78, height: 78,
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
                child: Icon(icon, size: 34, color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              Text(title, style: AppTheme.display.copyWith(fontSize: 18)),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(subtitle!, textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted, fontSize: 14)),
              ],
              if (action != null) ...[const SizedBox(height: 18), action!],
            ],
          ),
        ),
      );
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 44, color: AppColors.muted),
              const SizedBox(height: 14),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                OutlinedButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
              ],
            ],
          ),
        ),
      );
}

/// خلفية متدرّجة بهوية يمن توب
class GradientBox extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final EdgeInsets padding;
  final double radius;
  const GradientBox({
    super.key, required this.child, required this.gradient,
    this.padding = const EdgeInsets.all(20), this.radius = 22,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(radius)),
        child: child,
      );
}

/// عرض شارة حالة (طلب/دفع) بلون مناسب
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const StatusBadge(this.label, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800)),
      );
}

Color statusColor(String status) {
  switch (status) {
    case 'completed':
    case 'delivered':
    case 'paid':
      return AppColors.good;
    case 'processing':
      return AppColors.royal;
    case 'cancelled':
    case 'failed':
      return AppColors.bad;
    default:
      return AppColors.gold;
  }
}
