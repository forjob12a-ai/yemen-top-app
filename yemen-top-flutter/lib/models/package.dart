class Package {
  final int id;
  final String name;
  final String? description;
  final double price;
  final double? originalPrice;
  final bool hasDiscount;
  final int discountPercent;
  final bool inStock;
  final String currency;

  /// fixed، أو quantity لباقة الكمية (الكوينز): العميل يحدد العدد والخادم يسعّره
  final String pricingType;
  final String? unitLabel;
  final int? unitSize;
  final int? minUnits;
  final int? maxUnits;
  final int? stepUnits;

  Package({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.originalPrice,
    this.hasDiscount = false,
    this.discountPercent = 0,
    this.inStock = true,
    this.currency = 'YER',
    this.pricingType = 'fixed',
    this.unitLabel,
    this.unitSize,
    this.minUnits,
    this.maxUnits,
    this.stepUnits,
  });

  bool get isQuantity => pricingType == 'quantity';

  String get label => unitLabel ?? 'وحدة';

  /// فحص العدد بنفس رسائل الخادم (PriceResolver::checkUnits)؛ الخادم يعيد الفحص عند الطلب
  String? checkUnits(int units) {
    final min = minUnits ?? 1;
    final step = stepUnits ?? 1;
    final max = maxUnits ?? 0;
    if (units < 1) return 'حدّد عدد $label المطلوبة.';
    if (units < min) return 'أقل كمية يمكن طلبها ${fmtInt(min)} $label.';
    if (max > 0 && units > max) return 'أكبر كمية يمكن طلبها ${fmtInt(max)} $label.';
    if (step > 1 && (units - min) % step != 0) {
      return 'الكمية تزيد بخطوات من ${fmtInt(step)} $label (مثل ${fmtInt(min)} أو ${fmtInt(min + step)}).';
    }
    return null;
  }

  /// كميات سريعة كما في الموقع: الأدنى ×1 و×2 و×5 و×10، على الخطوة وضمن الحد الأقصى
  List<int> get presets {
    final min = minUnits ?? 1;
    final step = stepUnits ?? 1;
    final max = maxUnits ?? 0;
    final out = <int>[];
    for (final m in [1, 2, 5, 10]) {
      var v = min * m;
      if (step > 1) v = min + ((v - min) / step).round() * step;
      if (v >= min && (max <= 0 || v <= max) && !out.contains(v)) out.add(v);
    }
    return out;
  }

  /// 2500 => 2,500
  static String fmtInt(int v) =>
      v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  factory Package.fromJson(Map<String, dynamic> j) => Package(
        id: j['id'],
        name: j['name'] ?? '',
        description: j['description'],
        price: double.tryParse((j['price'] ?? 0).toString()) ?? 0,
        originalPrice: j['original_price'] != null ? double.tryParse(j['original_price'].toString()) : null,
        hasDiscount: j['has_discount'] ?? false,
        discountPercent: j['discount_percent'] ?? 0,
        inStock: j['in_stock'] ?? true,
        currency: j['currency'] ?? 'YER',
        pricingType: (j['pricing_type'] ?? 'fixed').toString(),
        unitLabel: j['unit_label']?.toString(),
        unitSize: _int(j['unit_size']),
        minUnits: _int(j['min_units']),
        maxUnits: _int(j['max_units']),
        stepUnits: _int(j['step_units']),
      );

  static int? _int(dynamic v) => v == null ? null : int.tryParse(v.toString());
}
