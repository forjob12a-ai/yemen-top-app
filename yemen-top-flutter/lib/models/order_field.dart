/// حقل من «حقول الطلب» كما يعيده الخادم في package_fields (معرف اللاعب، السيرفر، ...).
/// الفحص هنا لمساعدة العميل قبل الإرسال فقط، بنفس قواعد ورسائل الخادم (OrderFieldService)،
/// والخادم يعيد فحص كل قيمة عند الطلب.
class OrderFieldDef {
  /// نفس OrderFieldService::DEFAULT_MAX في الخادم
  static const defaultMax = 190;

  final String key;
  final String label;

  /// text / digits / tel / email / password / select
  final String type;
  final bool isPlayerId;
  final bool required;
  final String? placeholder;
  final String? help;
  final int? min;
  final int? max;
  final String? pattern;
  final String? patternMessage;
  final List<String> options;

  const OrderFieldDef({
    required this.key,
    required this.label,
    this.type = 'text',
    this.isPlayerId = false,
    this.required = false,
    this.placeholder,
    this.help,
    this.min,
    this.max,
    this.pattern,
    this.patternMessage,
    this.options = const [],
  });

  bool get isSecret => type == 'password';
  bool get isSelect => type == 'select';

  factory OrderFieldDef.fromJson(Map<String, dynamic> j) {
    int? asInt(dynamic v) => v == null ? null : int.tryParse(v.toString());
    String? asText(dynamic v) {
      final s = v?.toString().trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    return OrderFieldDef(
      key: (j['key'] ?? '').toString(),
      label: (j['label'] ?? '').toString(),
      type: (j['type'] ?? 'text').toString(),
      isPlayerId: j['is_player_id'] == true,
      required: j['required'] == true,
      placeholder: asText(j['placeholder']),
      help: asText(j['help']),
      min: asInt(j['min']),
      max: asInt(j['max']),
      pattern: asText(j['pattern']),
      patternMessage: asText(j['pattern_message']),
      options: j['options'] is List
          ? (j['options'] as List).map((o) => o.toString()).toList()
          : const [],
    );
  }

  static const _arabicDigits = {
    '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4', '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
    '۰': '0', '۱': '1', '۲': '2', '۳': '3', '۴': '4', '۵': '5', '۶': '6', '۷': '7', '۸': '8', '۹': '9',
  };

  /// التنظيف كما في الخادم: كلمة المرور كما كُتبت، والباقي بلا علامات اتجاه خفية ولا مسافات طرفية
  /// وبأرقام إنجليزية، والأرقام والهاتف بلا مسافات ولا شرطات.
  String clean(String raw) {
    if (isSecret) return raw;
    var v = raw
        .replaceAll(RegExp('[\u200E\u200F\u200B\uFEFF\u202A\u202B\u202C]'), '')
        .replaceAll('\u00A0', ' ');
    v = v.split('').map((c) => _arabicDigits[c] ?? c).join().trim();
    if (type == 'digits' || type == 'tel') {
      v = v.replaceAll(RegExp(r'[\s\-]+'), '');
    }
    return v;
  }

  /// رسالة الخطأ لقيمة نظيفة (فارغة أو لا)، أو null إن كانت صالحة.
  String? validate(String value) {
    if (value.trim().isEmpty) {
      return required ? 'الرجاء إدخال «$label».' : null;
    }
    final len = value.runes.length;
    final limit = max ?? defaultMax;
    if (min != null && len < min!) return '«$label» يجب ألا يقل عن $min خانات.';
    if (len > limit) return '«$label» يجب ألا يزيد عن $limit خانة.';

    switch (type) {
      case 'digits':
        if (!RegExp(r'^\d+$').hasMatch(value)) return '«$label» يجب أن يحتوي على أرقام فقط.';
        break;
      case 'tel':
        if (pattern == null && !RegExp(r'^\+?\d{6,15}$').hasMatch(value)) {
          return 'رقم الهاتف في «$label» غير صحيح.';
        }
        break;
      case 'email':
        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
          return 'البريد الإلكتروني في «$label» غير صحيح.';
        }
        break;
      case 'select':
        if (!options.contains(value)) return 'اختر قيمة من قائمة «$label».';
        break;
    }

    if (pattern != null) {
      try {
        if (!RegExp('^(?:$pattern)\$', unicode: true).hasMatch(value)) {
          return patternMessage ?? 'صيغة «$label» غير صحيحة.';
        }
      } on FormatException {
        // نمط لا يفهمه Dart: نتركه للخادم ولا نمنع العميل بسببه
      }
    }
    return null;
  }
}
