# إصلاحات Classifier - Sudan Electricity App

## المشاكل التي تم حلها

### 1. مشكلة Timeout
- **المشكلة**: كان timeout قصير جداً (20 ثانية) مما يسبب فشل الطلبات
- **الحل**: تم زيادة timeout إلى 60 ثانية مع إمكانية التخصيص

### 2. عدم وجود Retry Logic
- **المشكلة**: عند فشل الطلب، لم يكن هناك محاولات إعادة
- **الحل**: تم إضافة retry logic مع 3 محاولات

### 3. عدم فحص الاتصال
- **المشكلة**: لم يتم فحص الاتصال بالإنترنت قبل إرسال الطلب
- **الحل**: تم إضافة فحص الاتصال واستجابة الخادم

## التحسينات المضافة

### ClassifierConfig
```dart
class ClassifierConfig {
  // إعدادات الشبكة
  static const int connectionTimeoutSeconds = 60;
  static const int maxRetries = 3;
  static const int retryDelaySeconds = 2;
  static const int serverCheckTimeoutSeconds = 10;
}
```

### NetworkHelper
- فحص الاتصال بالإنترنت
- فحص استجابة الخادم
- اختبار سرعة الاتصال

### ClassifierService
- فحص الاتصال قبل إرسال الطلب
- retry logic مع تأخير ذكي
- معالجة أفضل للأخطاء
- logging محسن

## كيفية الاستخدام

### 1. تشغيل التطبيق
```bash
flutter run
```

### 2. تخصيص الإعدادات (اختياري)
```bash
flutter run --dart-define=CLASSIFIER_API_URL=https://your-api.com
flutter run --dart-define=CLASSIFIER_API_KEY=your-api-key
```

### 3. مراقبة Logs
ستظهر رسائل مثل:
```
[Classifier] Attempt 1/3 - POST to: https://faults-api.onrender.com/predict
[Classifier] Body: {"description":"العداد ما شغال","type":"انقطاع كهرباء","location":"كسلا حي المطار"}
[Classifier] Response: {"label": "انقطاع كهرباء", "confidence": 0.95}
```

## استكشاف الأخطاء

### إذا فشل الاتصال:
1. تأكد من وجود اتصال بالإنترنت
2. تحقق من استجابة الخادم
3. راجع logs للتأكد من صحة البيانات المرسلة

### إذا استمر الفشل:
1. تحقق من صحة API URL
2. تأكد من صحة API Key (إذا كان مطلوباً)
3. تحقق من حالة الخادم

## ملاحظات مهمة

- تم زيادة timeout إلى 60 ثانية لمعالجة مشاكل الشبكة البطيئة
- يتم إعادة المحاولة تلقائياً عند الفشل
- يتم فحص الاتصال قبل كل طلب
- يمكن تخصيص جميع الإعدادات من ClassifierConfig
