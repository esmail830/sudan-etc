import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/classifier_config.dart';
import 'network_helper.dart';

class ClassifierResult {
  final String label;
  final double? confidence;
  final Map<String, dynamic>? raw;

  const ClassifierResult({required this.label, this.confidence, this.raw});
}

class ClassifierService {
  static final ClassifierService _instance = ClassifierService._internal();
  factory ClassifierService() => _instance;
  ClassifierService._internal();

  Uri _buildUri() {
    final base = ClassifierConfig.apiBaseUrl;
    final path = ClassifierConfig.apiPath;
    // دعم تمرير base URL كاملاً بدون مسار إضافي
    final full = (path.isNotEmpty) ? (base + path) : base;
    return Uri.parse(full);
  }

  Future<ClassifierResult?> classifyReport({
    required String description,
    String? type,
    String? location,
  }) async {
    // فحص الاتصال بالإنترنت أولاً
    final hasInternet = await NetworkHelper.hasInternetConnection();
    if (!hasInternet) {
      print('[Classifier] No internet connection');
      return null;
    }

    // فحص استجابة الخادم
    final serverReachable = await NetworkHelper.isServerReachable(
      ClassifierConfig.apiBaseUrl,
    );
    if (!serverReachable) {
      print('[Classifier] Server is not reachable');
      return null;
    }

    final uri = _buildUri();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (ClassifierConfig.apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${ClassifierConfig.apiKey}';
    }

    final body = jsonEncode({
      'description': description,
      if (type != null) 'type': type,
      if (location != null) 'location': location,
    });

    // زيادة timeout إلى 60 ثانية وإضافة retry logic
    const int maxRetries = ClassifierConfig.maxRetries;
    const Duration timeout = Duration(
      seconds: ClassifierConfig.connectionTimeoutSeconds,
    );

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // debug logs
        // ignore: avoid_print
        print(
          '[Classifier] Attempt $attempt/$maxRetries - POST to: ' +
              uri.toString(),
        );
        // ignore: avoid_print
        print('[Classifier] Body: ' + body);

        http.Response res = await http
            .post(uri, headers: headers, body: body)
            .timeout(timeout);

        if (res.statusCode >= 200 && res.statusCode < 300) {
          // ignore: avoid_print
          print('[Classifier] Response: ' + res.body);
          
          // محاولة تحليل الاستجابة
          dynamic parsedData;
          try {
            parsedData = jsonDecode(res.body);
          } catch (e) {
            print('[Classifier] Failed to parse JSON: $e');
            // إذا فشل في تحليل JSON، استخدم النص كما هو
            final fallbackLabel = type ?? 'غير محدد';
            print('[Classifier] Using fallback label due to JSON parse error: $fallbackLabel');
            return ClassifierResult(
              label: fallbackLabel,
              confidence: null,
              raw: {'raw_response': res.body},
            );
          }
          
          final data = parsedData;
          // Try common response shapes
          String? label;
          double? confidence;

          if (data is Map<String, dynamic>) {
            // محاولة استخراج التصنيف من عدة تنسيقات محتملة
            label = data['label']?.toString() ??
                    data['category']?.toString() ??
                    data['class']?.toString() ??
                    data['prediction']?.toString() ??
                    data['result']?.toString() ??
                    data['output']?.toString() ??
                    data['classification']?.toString();
            
            // محاولة استخراج مستوى الثقة
            final confVal = data['confidence'] ?? 
                           data['score'] ?? 
                           data['prob'] ?? 
                           data['probability'] ??
                           data['certainty'];
            if (confVal is num) confidence = confVal.toDouble();
            
            // إذا لم نجد label، جرب استخراجه من data مباشرة
            if (label == null || label.isEmpty) {
              // جرب البحث في جميع القيم
              for (var entry in data.entries) {
                if (entry.value is String && 
                    entry.value.toString().isNotEmpty &&
                    entry.key.toLowerCase() != 'status' &&
                    entry.key.toLowerCase() != 'message' &&
                    entry.key.toLowerCase() != 'error') {
                  label = entry.value.toString();
                  print('[Classifier] Found label in key "${entry.key}": $label');
                  break;
                }
              }
            }
          } else if (data is String) {
            // إذا كانت البيانات نصية مباشرة
            label = data.trim();
            print('[Classifier] Response is direct string: $label');
          } else if (data is List && data.isNotEmpty) {
            // إذا كانت البيانات قائمة
            final firstItem = data.first;
            if (firstItem is Map<String, dynamic>) {
              label = firstItem['label']?.toString() ??
                      firstItem['category']?.toString() ??
                      firstItem['class']?.toString();
            } else if (firstItem is String) {
              label = firstItem;
            }
            print('[Classifier] Response is list, first item: $label');
          }

          // إذا لم نجد label بعد كل المحاولات، استخدم نوع العطل كتصنيف افتراضي
          if (label == null || label.isEmpty) {
            label = type ?? 'غير محدد';
            print('[Classifier] Using fallback label: $label');
          }

          return ClassifierResult(
            label: label,
            confidence: confidence,
            raw: data,
          );
        } else if (res.statusCode == 422) {
          // 422: جرّب شكل حمولة أبسط/بديل بحسب FastAPI schema
          final fallbackBody = jsonEncode({
            'text': description,
            if (type != null) 'type': type,
            if (location != null) 'location': location,
          });
          // ignore: avoid_print
          print('[Classifier] Retrying with fallback body: ' + fallbackBody);
          res = await http
              .post(uri, headers: headers, body: fallbackBody)
              .timeout(timeout);
          if (res.statusCode >= 200 && res.statusCode < 300) {
            // ignore: avoid_print
            print('[Classifier] Response (fallback): ' + res.body);
            final data = jsonDecode(res.body);
            String? label;
            double? confidence;
            if (data is Map<String, dynamic>) {
              label =
                  (data['label'] ??
                          data['category'] ??
                          data['class'] ??
                          data['prediction'])
                      ?.toString();
              final confVal =
                  data['confidence'] ?? data['score'] ?? data['prob'];
              if (confVal is num) confidence = confVal.toDouble();
            }
            if (label == null || label.isEmpty) {
              // استخدم نوع العطل كتصنيف افتراضي
              label = type ?? 'غير محدد';
              print('[Classifier] Using fallback label in 422 case: $label');
            }
            return ClassifierResult(
              label: label,
              confidence: confidence,
              raw: data,
            );
          }
          // ignore: avoid_print
          print(
            '[Classifier] Still non-2xx after fallback: ' +
                res.statusCode.toString(),
          );
        } else {
          // ignore: avoid_print
          print('[Classifier] Non-2xx status: ' + res.statusCode.toString());
        }

        // إذا وصلنا هنا، فشل الطلب. جرب مرة أخرى إذا لم ننتهي من المحاولات
        if (attempt < maxRetries) {
          // ignore: avoid_print
          print(
            '[Classifier] Retrying in ${ClassifierConfig.retryDelaySeconds} seconds...',
          );
          await Future.delayed(
            Duration(seconds: ClassifierConfig.retryDelaySeconds),
          );
          continue;
        }

        return null;
      } catch (e) {
        // ignore: avoid_print
        print('[Classifier] Error on attempt $attempt: $e');

        // إذا كان هذا آخر محاولة، ارجع null
        if (attempt >= maxRetries) {
          // ignore: avoid_print
          print('[Classifier] All attempts failed');
          return null;
        }

        // انتظر قبل المحاولة التالية
        // ignore: avoid_print
        print(
          '[Classifier] Retrying in ${ClassifierConfig.retryDelaySeconds + 1} seconds...',
        );
        await Future.delayed(
          Duration(seconds: ClassifierConfig.retryDelaySeconds + 1),
        );
      }
    }

    return null;
  }
}
