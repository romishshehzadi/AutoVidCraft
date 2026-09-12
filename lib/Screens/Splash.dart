import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController logoController;
  late AnimationController dotsController;

  @override
  void initState() {
    super.initState();

    //  INCREASED TIME (4.5 seconds)
    Timer(const Duration(milliseconds: 4500), () {
      widget.onComplete();
    });

    logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    dotsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    logoController.dispose();
    dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6A5AE0),
                Color(0xFF8B5CF6),
                Color(0xFF6A5AE0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: FadeTransition(
              opacity: logoController,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1).animate(
                  CurvedAnimation(
                    parent: logoController,
                    curve: Curves.easeOut,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //  LOGO FULLY COVER CONTAINER
                    ScaleTransition(
                      scale: Tween<double>(begin: 0, end: 1).animate(
                        CurvedAnimation(
                          parent: logoController,
                          curve: Curves.elasticOut,
                        ),
                      ),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          // border: Border.all(
                          //   color: Colors.white.withOpacity(0.3),
                          // ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
      
                          borderRadius: BorderRadius.circular(30),
                          child: SizedBox.expand(
                            child: Image.asset(
      
                              'images/logo1.jpg',
      
                              fit: BoxFit.cover, //  FULL COVER
                            ),
                          ),
                        ),
                      ),
                    ),
      
                    const SizedBox(height: 22),
      
                    const Text(
                      "AutoVidCraft",
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'font4'
                      ),
                    ),
      
                    const SizedBox(height: 8),
      
                    const Text(
                      "AI-Powered Video Generation",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
      
                    const SizedBox(height: 45),
      
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return AnimatedBuilder(
                          animation: dotsController,
                          builder: (_, __) {
                            double value =
                                (dotsController.value + index * 0.25) % 1;
                            double scale =
                                1 + (0.3 * (1 - (value - 0.5).abs() * 2));
                            double opacity = scale.clamp(0.0, 1.0);
      
                            return Transform.scale(
                              scale: scale,
                              child: Opacity(
                                opacity: opacity,
                                child: Container(
                                  margin:
                                  const EdgeInsets.symmetric(horizontal: 4),
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
