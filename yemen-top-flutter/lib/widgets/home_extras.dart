import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/api_config.dart';
import '../config/theme.dart';
import '../models/app_config.dart';
import '../providers/app_config_provider.dart';

/// إعلانات الموقع (شريط الإعلانات) بنفس ألوانها: خلفية مائلة للون فوق البطاقة، وحد وأيقونة ورابط باللون.
class NoticeBars extends StatelessWidget {
  const NoticeBars({super.key});

  @override
  Widget build(BuildContext context) {
    final cfg = context.watch<AppConfigProvider>();
    final notices = cfg.notices;
    if (notices.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        for (final n in notices) ...[
          _NoticeBar(notice: n, onClose: () => cfg.dismissNotice(n)),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _NoticeBar extends StatelessWidget {
  final SiteNotice notice;
  final VoidCallback onClose;
  const _NoticeBar({required this.notice, required this.onClose});

  /// لون الإعلان، ولون الأيقونة والرابط في الوضعين (theme-v2.css: .yt2-notice.is-*)
  (Color base, Color accent) get _colors {
    final dark = AppColors.isDark;
    switch (notice.style) {
      case 'green':
        return (const Color(0xFF4CAF50), dark ? AppColors.barActive : const Color(0xFF2E7D32));
      case 'gold':
        return (const Color(0xFFF6C44E), dark ? const Color(0xFFF6C44E) : const Color(0xFF8F5D00));
      case 'red':
        return (const Color(0xFFE53935), dark ? const Color(0xFFFF6B6B) : const Color(0xFFC62F2F));
      case 'purple':
        return (const Color(0xFF7E57C2), dark ? const Color(0xFFB39DDB) : const Color(0xFF5E35B1));
      case 'navy':
        return (AppColors.bar, AppColors.link);
      default:
        return (AppColors.royal, AppColors.link);
    }
  }

  IconData get _icon {
    switch (notice.type) {
      case 'offer':
        return Icons.local_offer_outlined;
      case 'update':
        return Icons.campaign_outlined;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'maintenance':
        return Icons.build_outlined;
      default:
        return Icons.info_outline;
    }
  }

  /// الرابط النسبي (/products) يُفتح على الموقع نفسه
  Uri? get _link {
    final url = notice.linkUrl;
    if (url == null) return null;
    final site = ApiConfig.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
    return Uri.tryParse(url.startsWith('/') ? '$site$url' : url);
  }

  @override
  Widget build(BuildContext context) {
    final (base, accent) = _colors;
    final link = _link;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 4, 10),
      decoration: BoxDecoration(
        color: Color.alphaBlend(base.withValues(alpha: 0.16), AppColors.navy),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: base.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(_icon, size: 20, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notice.message, style: TextStyle(color: AppColors.text, fontSize: 13.5, height: 1.5)),
                if (link != null)
                  InkWell(
                    onTap: () => launchUrl(link, mode: LaunchMode.externalApplication),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(notice.linkText ?? 'التفاصيل',
                          style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                  ),
              ],
            ),
          ),
          if (notice.dismissible)
            IconButton(
              onPressed: onClose,
              tooltip: 'إغلاق',
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.close, size: 18, color: AppColors.muted),
            ),
        ],
      ),
    );
  }
}

/// شريط المزايا كما في الرئيسية على الموقع (لماذا يمن توب)
class TrustStrip extends StatelessWidget {
  const TrustStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          _item(Icons.bolt_rounded, const Color(0xFFF6C44E), 'تسليم سريع', 'الأكواد تصلك تلقائياً بعد الدفع'),
          const SizedBox(width: 10),
          _item(Icons.verified_user_outlined, const Color(0xFF29B6F6), 'دفع آمن', 'أسعار واضحة يتحقق منها خادمنا'),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _item(Icons.account_balance_wallet_outlined, const Color(0xFF4CAF50), 'محفظة داخلية', 'اشحن رصيدك مرة واشترِ بضغطة'),
          const SizedBox(width: 10),
          _item(Icons.support_agent_rounded, const Color(0xFF7E57C2), 'دعم عبر واتساب', 'فريقنا يساعدك في أي طلب'),
        ]),
      ],
    );
  }

  Widget _item(IconData icon, Color color, String title, String sub) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 19, color: color),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(sub, style: TextStyle(color: AppColors.muted, fontSize: 11, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

/// عدّاد «طلبات تم تسليمها» كما في الموقع: يظهر فقط حين يرسله الخادم (بلغ الحد ومفعّل من الإعدادات)
class DeliveredCounter extends StatelessWidget {
  const DeliveredCounter({super.key});

  @override
  Widget build(BuildContext context) {
    final label = context.watch<AppConfigProvider>().deliveredCounter;
    if (label == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, size: 20, color: AppColors.orange),
          const SizedBox(width: 8),
          Text('طلبات تم تسليمها', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          // الرقم بعزل اتجاه حتى لا تنقلب علامة + في النص العربي
          Text(label,
              textDirection: TextDirection.ltr,
              style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w900, fontSize: 17)),
        ],
      ),
    );
  }
}
