import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_config_provider.dart';

/// زرّ واتساب عائم للدعم — يفتح https://wa.me/<الرقم>
class WhatsappButton extends StatelessWidget {
  const WhatsappButton({super.key});

  static const _green = Color(0xFF25D366);

  Future<void> _openWhatsapp(BuildContext context, String number) async {
    // تنظيف الرقم: نُبقي الأرقام فقط (نزيل + والمسافات والرموز).
    final cleaned = number.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$cleaned');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر فتح واتساب على جهازك')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final number = context.watch<AppConfigProvider>().contact.whatsapp;
    // لا نعرض الزرّ إن لم يصل رقم واتساب من السيرفر.
    if (number == null || number.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      heroTag: 'whatsapp_support_fab',
      backgroundColor: _green,
      tooltip: 'تواصل عبر واتساب',
      onPressed: () => _openWhatsapp(context, number),
      child: const Icon(Icons.chat_rounded, color: Colors.white, size: 26),
    );
  }
}
