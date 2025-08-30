import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/classifier_config.dart';

class NetworkHelper {
  /// التحقق من الاتصال بالإنترنت
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// التحقق من استجابة الخادم
  static Future<bool> isServerReachable(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http
          .get(uri)
          .timeout(
            Duration(seconds: ClassifierConfig.serverCheckTimeoutSeconds),
          );
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (e) {
      print('[NetworkHelper] Server unreachable: $e');
      return false;
    }
  }

  /// اختبار سرعة الاتصال
  static Future<Duration> testConnectionSpeed(String url) async {
    final stopwatch = Stopwatch()..start();
    try {
      final uri = Uri.parse(url);
      await http
          .get(uri)
          .timeout(
            Duration(seconds: ClassifierConfig.connectionTimeoutSeconds),
          );
      stopwatch.stop();
      return stopwatch.elapsed;
    } catch (e) {
      stopwatch.stop();
      print('[NetworkHelper] Connection test failed: $e');
      return Duration.zero;
    }
  }
}
