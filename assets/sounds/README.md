# مجلد الأصوات - Sudan Electricity App

## 📁 الملفات المطلوبة

### 1. **notification_sound.mp3** - صوت الإشعار الافتراضي
- مدة: 2-3 ثواني
- تنسيق: MP3
- حجم: أقل من 100KB

### 2. **success_notification.mp3** - صوت نجاح العملية
- مدة: 1-2 ثانية
- تنسيق: MP3
- حجم: أقل من 50KB

### 3. **default_notification.mp3** - صوت احتياطي
- مدة: 1 ثانية
- تنسيق: MP3
- حجم: أقل من 30KB

### 4. **notification_sound.wav** - صوت iOS
- مدة: 2-3 ثواني
- تنسيق: WAV
- حجم: أقل من 100KB

## 🎵 مصادر الأصوات

### **أصوات مجانية:**
- [Freesound.org](https://freesound.org/)
- [Zapsplat](https://www.zapsplat.com/)
- [SoundBible](http://soundbible.com/)

### **أصوات مخصصة:**
- يمكن إنشاء أصوات مخصصة باستخدام:
  - Audacity (مجاني)
  - GarageBand (macOS)
  - Online Tone Generator

## 🔧 كيفية الإضافة

### **1. تحميل الأصوات:**
- احفظ الملفات في هذا المجلد
- تأكد من التنسيق الصحيح
- تحقق من حجم الملفات

### **2. تحديث pubspec.yaml:**
```yaml
flutter:
  assets:
    - assets/sounds/
```

### **3. اختبار الأصوات:**
```dart
final notificationService = NotificationService();
await notificationService.initialize();

// اختبار صوت مخصص
notificationService.addNotification(
  AppNotification(
    title: 'اختبار',
    body: 'اختبار الصوت',
    soundFile: 'notification_sound.mp3',
  ),
);
```

## 📱 دعم المنصات

### **Android:**
- يدعم MP3, WAV, OGG
- يفضل MP3 للحجم الصغير
- يجب أن يكون الملف في `assets/sounds/`

### **iOS:**
- يدعم WAV, CAF, AIFF
- يفضل WAV للتوافق
- يجب أن يكون الملف في `assets/sounds/`

## 🎯 نصائح للأصوات

1. **مدة قصيرة**: 1-3 ثواني
2. **حجم صغير**: أقل من 100KB
3. **جودة مناسبة**: 44.1kHz, 16-bit
4. **صوت واضح**: بدون ضوضاء
5. **مريح للأذن**: لا يكون مزعجاً

## 🚀 أمثلة على الأصوات

### **إشعار عادي:**
- نغمة بسيطة وواضحة
- مدة: 1-2 ثانية
- صوت: "ding" أو "ping"

### **إشعار نجاح:**
- نغمة إيجابية
- مدة: 1-2 ثانية
- صوت: "success" أو "chime"

### **إشعار تحذير:**
- نغمة تنبيه
- مدة: 2-3 ثانية
- صوت: "alert" أو "warning"
