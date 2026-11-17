import 'package:intl/intl.dart';

/// عملة واحدة (ريال يمني / سعودي / دولار ...) قادمة من /api/app-config
class Currency {
  final String code; // YER, SAR, USD
  final String name; // الاسم المعروض
  final String symbol; // الرمز: ﷼ , ر.س , $
  final String symbolPosition; // 'before' أو 'after'
  final int decimals; // عدد المنازل العشرية
  final double rate; // معدّل التحويل (الريال اليمني = 1)
  final bool isDefault;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    this.symbolPosition = 'after',
    this.decimals = 0,
    this.rate = 1,
    this.isDefault = false,
  });

  factory Currency.fromJson(Map<String, dynamic> j) => Currency(
        code: (j['code'] ?? 'YER').toString(),
        name: (j['name'] ?? '').toString(),
        symbol: (j['symbol'] ?? '').toString(),
        symbolPosition: (j['symbol_position'] ?? 'after').toString(),
        decimals: j['decimals'] is int
            ? j['decimals']
            : int.tryParse('${j['decimals']}') ?? 0,
        rate: double.tryParse((j['rate'] ?? 1).toString()) ?? 1,
        isDefault: j['is_default'] == true || j['is_default'] == 1,
      );

  /// تحويل مبلغ مخزّن بالعملة الأساسية (الريال اليمني) إلى هذه العملة وتنسيقه بالرمز.
  /// المعادلة: السعر المعروض = السعر بالريال اليمني ÷ rate
  String format(num baseAmountYer) {
    final divisor = rate == 0 ? 1 : rate;
    final converted = baseAmountYer / divisor;
    final pattern = decimals > 0 ? '#,##0.${'0' * decimals}' : '#,##0';
    final number = NumberFormat(pattern, 'en').format(converted);
    return symbolPosition == 'before' ? '$symbol$number' : '$number $symbol';
  }

  /// العملة الأساسية الافتراضية (تُستخدم قبل تحميل الإعدادات أو عند فشل الاتصال).
  static const Currency fallback = Currency(
    code: 'YER',
    name: 'ريال يمني',
    symbol: '﷼',
    symbolPosition: 'after',
    decimals: 0,
    rate: 1,
    isDefault: true,
  );
}
