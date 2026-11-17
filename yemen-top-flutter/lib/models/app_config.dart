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

  factory ContactInfo.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const ContactInfo();
    return ContactInfo(
      whatsapp: j['whatsapp']?.toString(),
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

/// إعدادات التطبيق العامة (عملات + تواصل) — استجابة GET /api/app-config
class AppConfig {
  final List<Currency> currencies;
  final String defaultCurrency;
  final ContactInfo contact;

  const AppConfig({
    this.currencies = const [],
    this.defaultCurrency = 'YER',
    this.contact = const ContactInfo(),
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
        ),
      );
}
