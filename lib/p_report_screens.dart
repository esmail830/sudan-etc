// p_report_screens.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sudan_electricity_app/utils/psupabasetest.dart';
import 'dart:io';
import "services/psupbase_service.dart";

import 'utils/simple_test.dart';

class PReportScreen extends StatefulWidget {
  const PReportScreen({super.key});

  @override
  State<PReportScreen> createState() => _PReportScreenState();
}

class _PReportScreenState extends State<PReportScreen> {
  final TextEditingController descController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  String? selectedType;
  bool isSubmitting = false;
  String? errorMessage;
  File? selectedImage;
  bool isLegalAgreementAccepted = false;
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> types = [
    {'name': 'اختراق محول', 'icon': Icons.power_off, 'color': Colors.red},
    {
      'name': 'عمود مكسور',
      'icon': Icons.electric_bolt,
      'color': Colors.orange,
    },
    {
      'name': 'سلك مقطوع',
      'icon': Icons.trending_down,
      'color': Colors.yellow[800],
    },
    {'name': 'أخرى', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ];

  void submitPReport() async {
    setState(() {
      errorMessage = null;
    });

    // التحقق من صحة البيانات
    if (selectedType == null) {
      setState(() {
        errorMessage = 'يرجى اختيار نوع العطل';
      });
      return;
    }
    if (descController.text.trim().isEmpty) {
      setState(() {
        errorMessage = 'يرجى كتابة وصف للعطل';
      });
      return;
    }
    if (locationController.text.trim().isEmpty) {
      setState(() {
        errorMessage = 'يرجى إدخال الموقع';
      });
      return;
    }
    if (!isLegalAgreementAccepted) {
      setState(() {
        errorMessage = 'يجب الموافقة على الشروط القانونية قبل الإرسال';
      });
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // استخدام Supabase service لإرسال البلاغ
      final psupabaseService = PSupabaseService();
      final result = await psupabaseService.submitPReport(
        type: selectedType!,
        description: descController.text.trim(),
        location: locationController.text.trim(),
        image: selectedImage,
        legalAgreementAccepted: isLegalAgreementAccepted,
      );

      if (result['success']) {
        // نجح الإرسال
        if (mounted) {
          // عرض رسالة نجاح
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // الانتقال إلى شاشة التأكيد
          Navigator.pushNamed(context, '/confirmation');
        }
      } else {
        // فشل الإرسال
        setState(() {
          errorMessage = result['message'];
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'حدث خطأ غير متوقع: $error';
      });
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source:
          await showModalBottomSheet<ImageSource>(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            builder:
                (context) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('التقاط صورة بالكاميرا'),
                        onTap: () => Navigator.pop(context, ImageSource.camera),
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: const Text('اختيار من المعرض'),
                        onTap:
                            () => Navigator.pop(context, ImageSource.gallery),
                      ),
                    ],
                  ),
                ),
          ) ??
          ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('تسجيل بلاغ عطل'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              try {
                // اختبار الاتصال بـ Supabase
                final result = await PSupabaseTest.testConnection();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result['success']
                            ? '✅ ${result['message']}'
                            : '❌ ${result['error']}',
                      ),
                      backgroundColor:
                          result['success'] ? Colors.green : Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              } catch (error) {
                print('خطأ في اختبار الاتصال: $error');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ خطأ في اختبار الاتصال: $error'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              }
            },
            tooltip: 'اختبار الاتصال',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () async {
              try {
                // اختبار بسيط
                await SimpleTest.printSupabaseInfo();
                final success = await SimpleTest.testBasicConnection();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? '✅🌷 الاتصال يعمل' : '❌❌ مشكلة في الاتصال',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } catch (error) {
                print('خطأ في الاختبار البسيط: $error');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ خطأ في الاختبار: $error'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            tooltip: 'اختبار بسيط',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[200]!, Colors.blue[50]!],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.08),
                    spreadRadius: 2,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.public,
                    size: 60,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'تسجيل بلاغ عام',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'يرجى ملء البيانات التالية بدقة لضمان سرعة الاستجابة',
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Type Selection Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    spreadRadius: 1,
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'نوع العطل',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 14),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2.7,
                        ),
                    itemCount: types.length,
                    itemBuilder: (context, index) {
                      final type = types[index];
                      final isSelected = selectedType == type['name'];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: Material(
                          color:
                              isSelected
                                  ? type['color'].withOpacity(0.15)
                                  : Colors.grey[100],
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              setState(() {
                                selectedType = type['name'];
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    type['icon'],
                                    color: type['color'],
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      type['name'],
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? type['color']
                                                : Colors.grey[800],
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                        fontSize: 15,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'اختر نوع العطل الذي تواجهه',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Description Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    spreadRadius: 1,
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'وصف العطل',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'اكتب وصفاً مفصلاً للعطل',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                      helperText:
                          'يرجى ذكر التفاصيل المهمة مثل وقت حدوث العطل أو تكراره',
                    ),
                    maxLines: 3,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: pickImage,
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('إضافة صورة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (selectedImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            selectedImage!,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Location Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    spreadRadius: 1,
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الموقع',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'عنوان العطل أو المنطقة',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                      helperText: 'مثال: شارع النيل، قرب محطة الوقود',
                    ),
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Legal Agreement Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.amber[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    spreadRadius: 1,
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: Colors.amber[700],
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'إقرار قانوني مهم',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'أقر وأتعهد بأن جميع المعلومات المقدمة في هذا البلاغ صحيحة ودقيقة، وأدرك أن شركة الكهرباء السودانية ستتخذ الإجراءات القانونية المناسبة ضد أي بلاغات كاذبة أو مضللة وفقاً للقوانين السارية.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: isLegalAgreementAccepted,
                        onChanged: (value) {
                          setState(() {
                            isLegalAgreementAccepted = value ?? false;
                          });
                        },
                        activeColor: Colors.amber[700],
                      ),
                      const Expanded(
                        child: Text(
                          'أوافق على الشروط القانونية المذكورة أعلاه',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (errorMessage != null) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : submitPReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child:
                    isSubmitting
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2.5,
                          ),
                        )
                        : const Text('إرسال البلاغ'),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
