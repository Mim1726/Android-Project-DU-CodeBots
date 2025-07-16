import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class OnboardingScreens extends StatefulWidget {
  static const String routeName = '/onboarding';
  const OnboardingScreens({Key? key}) : super(key: key);

  @override
  State<OnboardingScreens> createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      title: 'Discover New Recipes',
      subtitle: 'Browse thousands of dishes tailored to your taste.',
      backgroundImage: 'assets/screen_images/screen2.jpg',
    ),
    _OnboardingPage(
      title: 'Save Your Favourites',
      subtitle: 'Bookmark what you love and cook it later.',
      backgroundImage: 'assets/screen_images/screen1.jpg',
    ),
    _OnboardingPage(
      title: 'Cook With Confidence',
      subtitle: 'Calculate ingredients and follow voice instructions',
      backgroundImage: 'assets/screen_images/screen3.jpg',
    ),
  ];

  static const Color _textColor = Color(0xFFFF5722); // deep orange

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: _pages.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, index) {
          final page = _pages[index];
          final isLast = index == _pages.length - 1;

          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                page.backgroundImage,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(), // Empty space at top
                    Column(
                      children: [
                        Text(
                          page.title,
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                blurRadius: 6,
                                color: Colors.white.withOpacity(0.9),
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          page.subtitle,
                          style: TextStyle(
                            color: _textColor.withOpacity(0.9),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            height: 1.4,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.white.withOpacity(0.85),
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _completeOnboarding,
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Row(
                          children: List.generate(
                            _pages.length,
                                (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              width: _currentPage == index ? 24 : 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? Colors.deepOrange
                                    : Colors.deepOrange.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          onPressed: () {
                            if (isLast) {
                              _completeOnboarding();
                            } else {
                              _controller.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Text(isLast ? 'Get Started' : 'Next'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OnboardingPage {
  final String title;
  final String subtitle;
  final String backgroundImage;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.backgroundImage,
  });
}
