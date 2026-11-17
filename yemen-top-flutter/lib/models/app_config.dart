import 'currency.dart';

/// بيانات التواصل القادمة من /api/app-config
class ContactInfo {
  final String? whatsapp; // رقم دولي بدون + مثل: 967771234567
  final List<String> phones;
  final String? address;
  final Map<String, String> socials; // facebook, instagram, telegram ...

  const ContactInfo({
    this.whatsapp,
    this.phones = const [],
    this.address,
    this.socials = const {},
  });

  /// whatsappNumber: الحقل whatsapp_number في جذر الاستجابة (ما يرسله الخادم فعلاً)
  factory ContactInfo.fromJson(Map<String, dynamic>? j, {String? whatsappNumber}) {
    final wa = (whatsappNumber != null && whatsappNumber.isNotEmpty) ? whatsappNumber : null;
    if (j == null) return ContactInfo(whatsapp: wa);
    return ContactInfo(
      whatsapp: j['whatsapp']?.toString() ?? wa,
      phones: j['phones'] is List
          ? (j['phones'] as List).map((e) => e.toString()).toList()
          : const [],
      address: j['address']?.toString(),
      socials: j['socials'] is Map
          ? (j['socials'] as Map)
              .map((k, v) => MapEntry(k.toString(), v.toString()))
          : const {},
    );
  }
}

/// إعلان من شريط الإعلانات في الموقع (notices في /api/app-config)
class SiteNotice {
  final int id;
  final String message;

  /// info / offer / update / warning / maintenance
  final String type;

  /// blue / green / gold / red / navy / purple
  final String style;
  final String? linkUrl;
  final String? linkText;
  final bool dismissible;

  const SiteNotice({
    required this.id,
    required this.message,
    this.type = 'info',
    this.style = 'blue',
    this.linkUrl,
    this.linkText,
    this.dismissible = true,
  });

  factory SiteNotice.fromJson(Map<String, dynamic> j) => SiteNotice(
        id: int.tryParse('${j['id']}') ?? 0,
        message: (j['message'] ?? '').toString(),
        type: (j['type'] ?? 'info').toString(),
        style: (j['style'] ?? 'blue').toString(),
        linkUrl: (j['link_url'] ?? '').toString().isEmpty ? null : j['link_url'].toString(),
        linkText: (j['link_text'] ?? '').toString().isEmpty ? null : j['link_text'].toString(),
        dismissible: j['dismissible'] != false,
      );
}

/// إعدادات التطبيق العامة — استجابة GET /api/app-config
class AppConfig {
  final List<Currency> currencies;
  final String defaultCurrency;
  final ContactInfo contact;
  final List<SiteNotice> notices;

  /// نص عدّاد «طلبات تم تسليمها» كما في الموقع (مثل 1,200+)، أو null حين لا يُعرض
  final String? deliveredCounter;

  const AppConfig({
    this.currencies = const [],
    this.defaultCurrency = 'YER',
    this.contact = const ContactInfo(),
    this.notices = const [],
    this.deliveredCounter,
  });

  factory AppConfig.fromJson(Map<String, dynamic> j) => AppConfig(
        currencies: j['currencies'] is List
            ? (j['currencies'] as List)
                .map((c) => Currency.fromJson(Map<String, dynamic>.from(c)))
                .toList()
            : const [],
        defaultCurrency: (j['default_currency'] ?? 'YER').toString(),
        contact: ContactInfo.fromJson(
          j['contact'] is Map ? Map<String, dynamic>.from(j['contact']) : null,
          whatsappNumber: j['whatsapp_number']?.toString(),
        ),
        notices: j['notices'] is List
            ? (j['notices'] as List)
                .whereType<Map>()
                .map((n) => SiteNotice.fromJson(Map<String, dynamic>.from(n)))
                .where((n) => n.message.isNotEmpty)
                .toList()
            : const [],
        deliveredCounter: (j['delivered_counter'] ?? '').toString().isEmpty
            ? null
            : j['delivered_counter'].toString(),
      );
}
