import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/order_field.dart';
import '../../models/product.dart';
import '../../models/package.dart';
import '../../services/api_client.dart';
import '../../services/catalog_service.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/cart_button.dart';
import '../../widgets/product_card.dart';

class ProductDetailScreen extends StatefulWidget {
  final String slug;
  const ProductDetailScreen({super.key, required this.slug});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _catalog = CatalogService();

  /// معرّف اللاعب القديم: لمنتج لم يرسل الخادم له حقول طلب (خادم أقدم)
  final _playerCtrl = TextEditingController();

  /// حقول الطلب حسب مفتاح الحقل: ما كتبه العميل يبقى عند تبديل الباقة
  final Map<String, TextEditingController> _ctrls = {};
  final Map<String, String?> _choice = {};
  final Map<String, String> _errors = {};
  bool _prefilled = false;
  bool _showSecret = false;

  /// باقة الكمية (الكوينز): العدد يكتبه العميل، والسعر من الخادم (لا يُحسب في التطبيق)
  final _unitsCtrl = TextEditingController();
  double? _quotePrice;
  String? _unitsError;
  bool _quoting = false;
  Timer? _debounce;
  int _quoteSeq = 0;

  bool _loading = true;
  String? _error;
  Product? _product;
  Package? _selected;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _playerCtrl.dispose();
    _unitsCtrl.dispose();
    _debounce?.cancel();
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _product = await _catalog.product(widget.slug);
      final inStock = _product!.packages.where((p) => p.inStock).toList();
      _selected = inStock.isNotEmpty ? inStock.first : null;
      _prepareFields();
      _prepareUnits();
    } catch (_) {
      _error = 'تعذّر تحميل المنتج.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<OrderFieldDef> get _fields =>
      (_product == null || _selected == null) ? const [] : _product!.fieldsFor(_selected!.id);

  /// حقول الباقة المختارة: ما يظهر أول مرة يُعبّأ من آخر طلب للعميل لهذا المنتج (مثل الموقع)،
  /// وكلمات المرور لا تُعبّأ أبداً (الخادم لا يرسلها أصلاً).
  void _prepareFields() {
    final p = _product, pkg = _selected;
    if (p == null || pkg == null) return;
    final saved = p.savedFor(pkg.id);
    for (final f in p.fieldsFor(pkg.id)) {
      final s = f.isSecret ? null : saved[f.key];
      if (f.isSelect) {
        if (!_choice.containsKey(f.key)) {
          _choice[f.key] = (s != null && f.options.contains(s)) ? s : null;
          if (_choice[f.key] != null) _prefilled = true;
        }
      } else if (!_ctrls.containsKey(f.key)) {
        _ctrls[f.key] = TextEditingController(text: s ?? '');
        if (s != null && s.isNotEmpty) _prefilled = true;
      }
    }
  }

  void _selectPackage(Package pkg) {
    setState(() {
      _selected = pkg;
      _errors.clear();
      _prepareFields();
    });
    _prepareUnits();
  }

  int get _units => int.tryParse(_unitsCtrl.text) ?? 0;

  /// عند اختيار باقة كمية: العدد الأدنى إن لم يكن العدد الحالي صالحاً لها، ثم السعر من الخادم
  void _prepareUnits() {
    final pkg = _selected;
    _debounce?.cancel();
    if (pkg == null || !pkg.isQuantity) {
      setState(() { _quotePrice = null; _unitsError = null; _quoting = false; });
      return;
    }
    if (_unitsCtrl.text.isEmpty || pkg.checkUnits(_units) != null) {
      _unitsCtrl.text = '${pkg.minUnits ?? 1}';
    }
    _requestQuote();
  }

  static const _arabicDigits = '٠١٢٣٤٥٦٧٨٩';

  /// أرقام فقط (والعربية تتحول إنجليزية)، ثم فحص فوري وسعر بعد توقف الكتابة
  void _onUnitsChanged(String raw) {
    final clean = raw.split('').map((c) {
      final i = _arabicDigits.indexOf(c);
      return i >= 0 ? '$i' : c;
    }).join().replaceAll(RegExp(r'[^0-9]'), '');
    final cut = clean.length > 10 ? clean.substring(0, 10) : clean;
    if (cut != raw) {
      _unitsCtrl.value = TextEditingValue(text: cut, selection: TextSelection.collapsed(offset: cut.length));
    }
    final error = _selected?.checkUnits(_units);
    _debounce?.cancel();
    setState(() { _unitsError = error; _quotePrice = null; _quoting = error == null; });
    if (error == null) _debounce = Timer(const Duration(milliseconds: 350), _requestQuote);
  }

  void _setUnits(int v) {
    _unitsCtrl.text = '$v';
    _onUnitsChanged('$v');
  }

  Future<void> _requestQuote() async {
    final pkg = _selected;
    if (pkg == null || !pkg.isQuantity) return;
    final units = _units;
    final error = pkg.checkUnits(units);
    if (error != null) {
      setState(() { _unitsError = error; _quotePrice = null; _quoting = false; });
      return;
    }
    final seq = ++_quoteSeq;
    setState(() { _quoting = true; _unitsError = null; });
    try {
      final price = await _catalog.quote(pkg.id, units);
      if (!mounted || seq != _quoteSeq) return; // رد قديم بعد تغيير العدد
      setState(() { _quotePrice = price; _quoting = false; });
    } on ApiException catch (e) {
      if (!mounted || seq != _quoteSeq) return;
      setState(() { _unitsError = e.firstError; _quoting = false; });
    } catch (_) {
      if (!mounted || seq != _quoteSeq) return;
      setState(() { _unitsError = 'تعذّر حساب السعر، حاول مرة أخرى.'; _quoting = false; });
    }
  }

  /// يجمع القيم ويفحصها بقواعد الخادم ورسائله؛ null عند وجود خطأ (يظهر تحت كل حقل)
  Map<String, String>? _collectFields() {
    final values = <String, String>{};
    final errors = <String, String>{};
    for (final f in _fields) {
      final raw = f.isSelect ? (_choice[f.key] ?? '') : (_ctrls[f.key]?.text ?? '');
      final v = f.clean(raw);
      final e = f.validate(v);
      if (e != null) {
        errors[f.key] = e;
        continue;
      }
      if (v.trim().isNotEmpty) values[f.key] = v;
    }
    setState(() => _errors
      ..clear()
      ..addAll(errors));
    return errors.isEmpty ? values : null;
  }

  /// سطر البيانات في السلة (كلمة المرور مخفية)
  String _summary(Map<String, String> values) => _fields
      .where((f) => values.containsKey(f.key))
      .map((f) => '${f.label}: ${f.isSecret ? '••••' : values[f.key]}')
      .join(' · ');

  void _addToCart() {
    final p = _product!;
    final pkg = _selected;
    if (pkg == null) {
      _snack('اختر باقة أولاً', AppColors.bad);
      return;
    }
    if (pkg.isQuantity && (_unitsError != null || _quotePrice == null)) {
      _snack(_unitsError ?? 'انتظر حتى يُحسب السعر', AppColors.bad);
      return;
    }
    final units = pkg.isQuantity ? _units : null;
    final unitPrice = pkg.isQuantity ? _quotePrice : null;
    if (p.hasFieldSets) {
      final values = _collectFields();
      if (values == null) {
        _snack(_errors.values.first, AppColors.bad);
        return;
      }
      context.read<CartProvider>().add(p, pkg,
          qty: _qty, fields: values, fieldsSummary: _summary(values), units: units, unitPrice: unitPrice);
    } else {
      if (p.requiresPlayerId && _playerCtrl.text.trim().isEmpty) {
        _snack('أدخل ${p.playerIdLabel ?? 'معرف اللاعب'}', AppColors.bad);
        return;
      }
      context.read<CartProvider>().add(p, pkg,
          qty: _qty,
          playerId: p.requiresPlayerId ? _playerCtrl.text.trim() : null,
          units: units,
          unitPrice: unitPrice);
    }
    _snack('تمت الإضافة إلى السلة', AppColors.good);
  }

  void _snack(String m, Color c) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: c));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل المنتج'), actions: const [CartButton()]),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _buildBody(),
      bottomNavigationBar: (_loading || _error != null || _product == null) ? null : _bottomBar(),
    );
  }

  Widget _buildBody() {
    final p = _product!;
    final fields = _fields;
    final needsPlayer = p.hasFieldSets ? fields.any((f) => f.isPlayerId) : p.requiresPlayerId;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // الصورة كاملة فوق نسخة مموّهة منها (مثل صفحة المنتج في الموقع)
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(aspectRatio: 16 / 10, child: ProductArt(imageUrl: p.imageUrl, iconSize: 60)),
        ),
        const SizedBox(height: 16),
        if (p.category != null)
          Text(p.category!.name, style: TextStyle(color: AppColors.link, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(p.name, style: AppTheme.display.copyWith(fontSize: 22)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _tag(Icons.check_circle_outline, p.deliveryLabel),
          _tag(Icons.shield_outlined, 'دفع آمن'),
          if (needsPlayer) _tag(Icons.person_outline, 'يتطلب معرف اللاعب'),
        ]),
        if (p.description != null) ...[
          const SizedBox(height: 14),
          Text(p.description!, style: TextStyle(color: AppColors.muted, height: 1.7)),
        ],
        const SizedBox(height: 20),
        if (!p.hasFieldSets && p.requiresPlayerId) ...[
          Text(p.playerIdLabel ?? 'معرف اللاعب (ID)', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: _playerCtrl,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(hintText: 'أدخل المعرّف كما يظهر داخل اللعبة'),
          ),
          const SizedBox(height: 20),
        ],
        Text('اختر الباقة', style: AppTheme.display.copyWith(fontSize: 16)),
        const SizedBox(height: 12),
        ...p.packages.map((pkg) => _packageTile(pkg, hasFixed: p.packages.any((x) => !x.isQuantity))),
        if (_selected?.isQuantity == true) _quantityBox(_selected!),
        // بيانات الشحن بعد الباقة: كل باقة قد يكون لها حقول خاصة بها
        if (fields.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('بيانات الشحن', style: AppTheme.display.copyWith(fontSize: 16)),
          if (_prefilled)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('عبّأناها من آخر طلب لك لهذا المنتج، تأكد منها قبل الشراء.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12)),
            ),
          const SizedBox(height: 12),
          ...fields.map(_fieldInput),
        ],
      ],
    );
  }

  Widget _fieldInput(OrderFieldDef f) {
    final error = _errors[f.key];
    void clearError() {
      if (_errors.containsKey(f.key)) setState(() => _errors.remove(f.key));
    }

    final ltr = f.type == 'digits' || f.type == 'tel' || f.type == 'email';
    final Widget input = f.isSelect
        ? DropdownButtonFormField<String>(
            key: ValueKey('select-${f.key}'),
            initialValue: _choice[f.key],
            isExpanded: true,
            dropdownColor: AppColors.navy,
            items: f.options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
            onChanged: (v) {
              _choice[f.key] = v;
              clearError();
            },
            decoration: InputDecoration(hintText: f.placeholder ?? 'اختر', errorText: error, errorMaxLines: 2),
          )
        : TextField(
            controller: _ctrls[f.key],
            keyboardType: switch (f.type) {
              'digits' => TextInputType.number,
              'tel' => TextInputType.phone,
              'email' => TextInputType.emailAddress,
              _ => TextInputType.text,
            },
            textDirection: ltr ? TextDirection.ltr : null,
            obscureText: f.isSecret && !_showSecret,
            autocorrect: false,
            enableSuggestions: !f.isSecret,
            onChanged: (_) => clearError(),
            decoration: InputDecoration(
              hintText: f.placeholder,
              errorText: error,
              errorMaxLines: 2,
              suffixIcon: f.isSecret
                  ? IconButton(
                      icon: Icon(_showSecret ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.muted),
                      onPressed: () => setState(() => _showSecret = !_showSecret),
                    )
                  : null,
            ),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(text: f.label, children: [
              if (f.required) TextSpan(text: ' *', style: TextStyle(color: AppColors.bad)),
            ]),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          input,
          if (f.help != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(f.help!, style: TextStyle(color: AppColors.muted, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _tag(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
            color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.line)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: AppColors.good),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
        ]),
      );

  /// صندوق الكمية كما في الموقع: العدد والوحدة، والسعر من الخادم، وكميات سريعة، والحدود أو الخطأ تحته
  Widget _quantityBox(Package pkg) {
    final min = pkg.minUnits ?? 1;
    final max = pkg.maxUnits;
    final step = pkg.stepUnits ?? 1;
    final hint = 'من ${Package.fmtInt(min)}${max != null ? ' إلى ${Package.fmtInt(max)}' : ''} ${pkg.label}'
        '${step > 1 ? '، بخطوات ${Package.fmtInt(step)}' : ''}.';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('أدخل الكمية', style: AppTheme.display.copyWith(fontSize: 15)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _unitsCtrl,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  onChanged: _onUnitsChanged,
                  style: AppTheme.display.copyWith(fontSize: 17),
                  // اسم الوحدة في طرف الحقل، بعيداً عن الرقم
                  decoration: InputDecoration(
                    errorText: _unitsError,
                    errorMaxLines: 3,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Center(widthFactor: 1, child: Text(pkg.label, style: TextStyle(color: AppColors.muted))),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('السعر', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                  const SizedBox(height: 4),
                  _quoting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_quotePrice != null ? money(_quotePrice!) : '—',
                          style: AppTheme.display.copyWith(color: AppColors.gold, fontSize: 18)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final v in pkg.presets)
                ChoiceChip(
                  label: Text(Package.fmtInt(v)),
                  selected: _units == v,
                  onSelected: (_) => _setUnits(v),
                  shape: const StadiumBorder(),
                  showCheckmark: false,
                ),
            ],
          ),
          if (_unitsError == null) ...[
            const SizedBox(height: 8),
            Text(hint, style: TextStyle(color: AppColors.muted, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _packageTile(Package pkg, {bool hasFixed = true}) {
    final selected = _selected?.id == pkg.id;
    final out = !pkg.inStock;
    return Opacity(
      opacity: out ? 0.5 : 1,
      child: GestureDetector(
        onTap: out ? null : () => _selectPackage(pkg),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.orange.withValues(alpha: 0.1) : AppColors.card,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: selected ? AppColors.orange : AppColors.line, width: selected ? 1.8 : 1.4),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // باقة الكمية بجانب الباقات الثابتة اسمها «كمية مخصصة» كما في الموقع
                    Row(children: [
                      if (pkg.isQuantity) ...[
                        Icon(Icons.edit_outlined, size: 16, color: AppColors.muted),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(pkg.isQuantity && hasFixed ? 'كمية مخصصة' : pkg.name,
                            style: AppTheme.display.copyWith(fontSize: 15.5)),
                      ),
                    ]),
                    if (out) Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text('غير متوفّر حالياً', style: TextStyle(color: AppColors.bad, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${pkg.isQuantity ? 'من ' : ''}${money(pkg.price)}',
                      style: AppTheme.display.copyWith(color: AppColors.gold, fontSize: 16)),
                  if (pkg.hasDiscount && pkg.originalPrice != null)
                    Text(money(pkg.originalPrice!),
                        style: TextStyle(
                            color: AppColors.muted, fontSize: 11.5, decoration: TextDecoration.lineThrough)),
                ],
              ),
              if (pkg.hasDiscount) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.good, borderRadius: BorderRadius.circular(20)),
                  child: Text('-${pkg.discountPercent}%',
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomBar() {
    final quantity = _selected?.isQuantity == true;
    final price = quantity ? (_quotePrice ?? 0) : (_selected?.price ?? 0) * _qty;
    final ready = !quantity || (_quotePrice != null && !_quoting && _unitsError == null);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // عدّاد الكمية للباقات الثابتة فقط (باقة الكمية سطرها واحد بعدد الوحدات)
            if (!quantity) Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line)),
              child: Row(
                children: [
                  IconButton(onPressed: () => setState(() => _qty = (_qty - 1).clamp(1, 99)), icon: const Icon(Icons.remove)),
                  Text('$_qty', style: AppTheme.display.copyWith(fontSize: 16)),
                  IconButton(onPressed: () => setState(() => _qty = (_qty + 1).clamp(1, 99)), icon: const Icon(Icons.add)),
                ],
              ),
            ),
            if (!quantity) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: ready ? _addToCart : null,
                icon: const Icon(Icons.add_shopping_cart, size: 18),
                label: Text(ready ? 'أضف للسلة · ${money(price)}' : 'أضف للسلة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
