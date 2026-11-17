import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/app_config_provider.dart';

/// زرّ صغير في الشريط العلوي لاختيار العملة (يفتح قائمة سفلية).
class CurrencySelector extends StatelessWidget {
  const CurrencySelector({super.key});

  @override
  Widget build(BuildContext context) {
    final cfg = context.watch<AppConfigProvider>();
    // لا نعرض الزرّ إن كانت هناك عملة واحدة فقط.
    if (cfg.currencies.length < 2) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => _openPicker(context, cfg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            // الزر في الشريط العلوي الكحلي في الوضعين، فألوانه فاتحة دائماً
            color: const Color(0x1FFFFFFF),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0x38FFFFFF)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.currency_exchange_rounded,
                  size: 15, color: Color(0xFFF6C44E)),
              const SizedBox(width: 6),
              Text(cfg.selected.code,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }

  void _openPicker(BuildContext context, AppConfigProvider cfg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            Text('اختر العملة', style: AppTheme.display.copyWith(fontSize: 18)),
            const SizedBox(height: 6),
            ...cfg.currencies.map((c) {
              final isSelected = c.code == cfg.selected.code;
              return ListTile(
                onTap: () {
                  cfg.setCurrency(c);
                  Navigator.pop(context);
                },
                leading: SizedBox(
                  width: 30,
                  child: Text(c.symbol,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, color: AppColors.gold)),
                ),
                title: Text(c.name,
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: AppColors.text)),
                subtitle: Text(c.code,
                    style: TextStyle(color: AppColors.muted, fontSize: 12)),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded, color: AppColors.good)
                    : Icon(Icons.circle_outlined, color: AppColors.muted),
              );
            }),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}
