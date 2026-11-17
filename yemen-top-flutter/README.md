# يمن توب — تطبيق الجوال (Flutter)

تطبيق Flutter كامل لمتجر «يمن توب»، يستهلك واجهة الـ REST API (الخطوة 7أ) — بهوية الموقع
نفسها (داكن، RTL، خطوط Cairo/Tajawal)، ويغطّي رحلة الشراء كاملة على الجوال.

> ⚠️ **مهم:** هذا الكود مكتوب وفق معايير Flutter لكنه **لم يُجمَّع في هذه البيئة** (لا يوجد
> Flutter SDK هنا). جمّعه على جهازك عبر `flutter pub get` ثم `flutter run`.

---

## 1) المتطلبات

- تثبيت **Flutter SDK 3.x** ([flutter.dev/docs/get-started/install](https://flutter.dev)).
- محرّر (VS Code أو Android Studio) + جهاز/محاكي.
- مشروع Laravel (الخطوات 1–8) يعمل وتتوفّر واجهة الـ API.

## 2) التشغيل

```bash
# 1) ادخل مجلد المشروع
cd yemen-top-flutter

# 2) عدّل رابط الـ API في:
#    lib/config/api_config.dart  ←  baseUrl
#    - للجهاز الحقيقي: https://yementop.com/api
#    - لمحاكي أندرويد + سيرفر محلي: http://10.0.2.2:8000/api

# 3) ثبّت الحزم
flutter pub get

# 4) شغّل
flutter run
```

## 3) ضبط رابط الـ API

في `lib/config/api_config.dart`:
```dart
static const String baseUrl = 'https://yementop.com/api';
```
- محاكي أندرويد يصل للسيرفر المحلي عبر `10.0.2.2` (وليس `localhost`).
- محاكي iOS يمكنه استخدام `127.0.0.1` مباشرة.

---

## 4) ما الذي يتضمنه التطبيق؟

| القسم | الشاشات |
|-------|---------|
| المصادقة | شاشة افتتاحية، تسجيل دخول، إنشاء حساب (دخول بالجوال + توكن) |
| الرئيسية | هيرو، الأقسام، شريط العروض، منتجات مميّزة |
| المتجر | بحث + تصفية بالأقسام + شبكة منتجات |
| تفاصيل المنتج | اختيار الباقة + معرف اللاعب + الكمية + إضافة للسلة |
| السلة والدفع | سلة محلية، إتمام الطلب، الدفع من المحفظة أو التحويل اليدوي |
| الطلبات | قائمة الطلبات + التفاصيل + عرض الأكواد المسلّمة + زر الدفع |
| المحفظة | الرصيد + سجل الحركات + شحن المحفظة |
| الإشعارات | قائمة الإشعارات (طلبات/إعلانات) + تعليم كمقروء |
| الحساب | تعديل الملف، تغيير كلمة المرور، تسجيل الخروج |

**البنية المعمارية:**
```
lib/
├── config/      api_config.dart · theme.dart (ألوان الهوية + RTL)
├── models/      11 موديل مطابق لموارد الـ API
├── services/    api_client (توكن + أخطاء) + 6 خدمات
├── providers/   auth_provider · cart_provider (سلة محلية)
├── widgets/     بطاقات وعناصر مشتركة
└── screens/     auth · home · catalog · cart · payment · orders · wallet · notifications · account
```

**التقنيات:** `provider` (الحالة)، `http` (الشبكة)، `shared_preferences` (حفظ التوكن)،
`google_fonts`، `cached_network_image`، `intl`.

---

## 5) إشعارات Push (اختياري — Firebase)

التطبيق جاهز لاستقبال Push عبر FCM (الباك-إند يرسلها). لتفعيلها:
1. أنشئ مشروع Firebase وأضف تطبيق أندرويد/iOS (ملفات `google-services.json` / `GoogleService-Info.plist`).
2. فعّل الحزم في `pubspec.yaml` (مُعلّقة حالياً):
   ```yaml
   firebase_core: ^2.31.0
   firebase_messaging: ^14.9.0
   ```
3. في بدء التطبيق، احصل على توكن الجهاز وأرسله إلى `POST /api/device-tokens`
   (الدالة `NotificationService.registerDevice` جاهزة لذلك).

---

## 6) رفع صور الإيصالات (تحسين مقترح)

نماذج الدفع/الشحن ترسل **رقم العملية واسم المُحوِّل** (والـ API يقبل الإيصال كصورة اختيارية).
لإضافة رفع صورة الإيصال من التطبيق، أضِف حزمة `image_picker`، واختر صورة، ومرّر مسارها إلى
`PaymentService.submitManual` / `WalletService.topup` عبر المعامل `receiptPath` (مدعوم في الخدمات).

---

## 🎉 المشروع مكتمل

بهذا تكتمل المنصّة: **8 خطوات للباك-إند والويب ولوحة التحكم وواجهة الـ API + تطبيق Flutter**.
أي تعديل أو إضافة (مثل دمج Push أو رفع الإيصالات) أخبرني به.
