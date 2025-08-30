import 'package:flutter/material.dart';
import 'services/auth_service.dart';

class WelcomeScreens extends StatefulWidget {
  const WelcomeScreens({super.key});

  @override
  State<WelcomeScreens> createState() => _WelcomeScreensState();
}

class _WelcomeScreensState extends State<WelcomeScreens> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  bool _isCheckingAuth = true;

  final List<_WelcomePageData> _pages = [
    _WelcomePageData(
      icon: Icons.electric_bolt,
      title: 'مرحباً بك في تطبيق الكهرباء',
      description:
          'تطبيقنا يساعدك في الإبلاغ عن أعطال الكهرباء بسرعة وسهولة لضمان استمرارية الخدمة.',
      color: Colors.blueAccent,
      gradient: [Colors.blue[400]!, Colors.blue[600]!],
    ),
    _WelcomePageData(
      icon: Icons.family_restroom,
      title: 'الكهرباء أساس الحياة الحديثة',
      description:
          'الكهرباء تضيء منازلنا وتشغّل أجهزتنا وتدعم كل تفاصيل حياتنا اليومية.',
      color: Colors.blue,
      gradient: [Colors.blue[400]!, Colors.blue[600]!],
    ),
    _WelcomePageData(
      icon: Icons.eco,
      title: 'المحافظة على الكهرباء مسؤوليتنا جميعاً',
      description:
          'بإبلاغك عن الأعطال، تساهم في الحفاظ على مورد الكهرباء وضمان استدامته للجميع.',
      color: Colors.blue,
      gradient: [Colors.blue[400]!, Colors.blue[600]!],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  /// فحص حالة تسجيل الدخول
  Future<void> _checkAuthStatus() async {
    try {
      final authService = AuthService();
      final isLoggedIn = await authService.isLoggedIn();

      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
        });

        if (isLoggedIn) {
          // إذا كان المستخدم مسجل دخول، انتقل مباشرة إلى الشاشة الرئيسية
          print(
            '[WelcomeScreens] المستخدم مسجل دخول، الانتقال إلى الشاشة الرئيسية',
          );
          Navigator.pushReplacementNamed(context, '/main');
        }
      }
    } catch (e) {
      print('[WelcomeScreens] خطأ في فحص حالة تسجيل الدخول: $e');
      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
        });
      }
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/phone_auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    // إذا كان يتم فحص حالة تسجيل الدخول، اعرض شاشة تحميل
    if (_isCheckingAuth) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[400]!, Colors.blue[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.electric_bolt,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'شركة الكهرباء السودانية',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 16),
              const Text(
                'جاري فحص حالة تسجيل الدخول...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: page.gradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: page.color.withOpacity(0.3),
                                spreadRadius: 5,
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(page.icon, size: 80, color: Colors.white),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: page.color,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          page.description,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: _currentPage == index ? 30 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color:
                        _currentPage == index
                            ? _pages[index].color
                            : Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pages[_currentPage].color,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: _pages[_currentPage].color.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'ابدأ' : 'التالي',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _WelcomePageData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final List<Color> gradient;
  const _WelcomePageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.gradient,
  });
}
