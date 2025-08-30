import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AppNotification {
  final String title;
  final String body;
  final DateTime createdAt;
  final String? soundFile;
  final bool playSound;

  AppNotification({
    required this.title,
    required this.body,
    DateTime? createdAt,
    this.soundFile,
    this.playSound = true,
  }) : createdAt = createdAt ?? DateTime.now();
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ValueNotifier<List<AppNotification>> notifications =
      ValueNotifier<List<AppNotification>>(<AppNotification>[]);

  // Audio Player
  late AudioPlayer _audioPlayer;

  // Notification Settings
  bool _isInitialized = false;

  /// تهيئة خدمة الإشعارات
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // تهيئة Audio Player
      _audioPlayer = AudioPlayer();

      _isInitialized = true;
      print('[NotificationService] تم تهيئة خدمة الإشعارات بنجاح');
    } catch (e) {
      print('[NotificationService] خطأ في تهيئة خدمة الإشعارات: $e');
    }
  }

  /// إضافة إشعار جديد
  void addNotification(AppNotification notification) {
    // إضافة للإشعارات الداخلية
    final current = List<AppNotification>.from(notifications.value);
    current.insert(0, notification);
    notifications.value = current;

    // تشغيل الصوت إذا كان مطلوباً
    if (notification.playSound) {
      _playNotificationSound(notification.soundFile);
    }

    print('[NotificationService] تم إضافة إشعار: ${notification.title}');
  }

  /// تشغيل صوت الإشعار
  Future<void> _playNotificationSound(String? soundFile) async {
    try {
      if (!_isInitialized) await initialize();

      // إيقاف أي صوت قيد التشغيل
      await _audioPlayer.stop();

      // تشغيل الصوت
      if (soundFile != null && soundFile.isNotEmpty) {
        // محاولة تشغيل ملف صوت مخصص
        try {
          await _audioPlayer.setAsset('assets/sounds/$soundFile');
          await _audioPlayer.play();
          print('[NotificationService] تم تشغيل صوت مخصص: $soundFile');
        } catch (e) {
          print('[NotificationService] فشل في تشغيل الصوت المخصص: $e');
          // استخدام الصوت الافتراضي
          await _playDefaultSound();
        }
      } else {
        // تشغيل صوت افتراضي
        await _playDefaultSound();
      }
    } catch (e) {
      print('[NotificationService] خطأ في تشغيل صوت الإشعار: $e');
      // محاولة تشغيل صوت بسيط
      await _playDefaultSound();
    }
  }

  /// تشغيل الصوت الافتراضي
  Future<void> _playDefaultSound() async {
    try {
      // محاولة تشغيل صوت افتراضي
      await _audioPlayer.setAsset('assets/sounds/default_notification.mp3');
      await _audioPlayer.play();
      print('[NotificationService] تم تشغيل الصوت الافتراضي');
    } catch (e) {
      print('[NotificationService] فشل في تشغيل الصوت الافتراضي: $e');
      // إذا فشل كل شيء، لا تشغل صوتاً
    }
  }

  /// إزالة إشعار
  void removeNotification(int index) {
    final current = List<AppNotification>.from(notifications.value);
    if (index >= 0 && index < current.length) {
      current.removeAt(index);
      notifications.value = current;
    }
  }

  /// مسح جميع الإشعارات
  void clearAllNotifications() {
    notifications.value = [];
    print('[NotificationService] تم مسح جميع الإشعارات');
  }

  /// إيقاف صوت الإشعار
  Future<void> stopSound() async {
    try {
      if (_isInitialized) {
        await _audioPlayer.stop();
        print('[NotificationService] تم إيقاف صوت الإشعار');
      }
    } catch (e) {
      print('[NotificationService] خطأ في إيقاف صوت الإشعار: $e');
    }
  }

  /// إغلاق الخدمة
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      print('[NotificationService] تم إغلاق خدمة الإشعارات');
    } catch (e) {
      print('[NotificationService] خطأ في إغلاق الخدمة: $e');
    }
  }

  /// اختبار الصوت
  Future<void> testSound() async {
    try {
      if (!_isInitialized) await initialize();

      print('[NotificationService] اختبار الصوت...');
      await _playNotificationSound('test_sound.mp3');
    } catch (e) {
      print('[NotificationService] خطأ في اختبار الصوت: $e');
    }
  }
}
