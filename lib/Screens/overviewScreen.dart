import 'package:auto/Screens/AuthScreen.dart';
import 'package:flutter/material.dart';

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({super.key});

  @override
  State<OnboardingScreens> createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens> {
  final PageController controller = PageController();
  int index = 0;

  // Icons according to screenshots
  final List<IconData> icons = [
    Icons.auto_awesome,          // Upload Your Images (sparkle icon)
    Icons.auto_fix_high,         // AI Magic Happens
    Icons.share_rounded,         // Share Your Creation
  ];

  // Titles
  final List<String> titles = [
    "Upload Your Images",
    "AI Magic Happens",
    "Share Your Creation",
  ];

  // Subtitles (EXACT TEXT from your screenshots)
  final List<String> subs = [
    "Start by uploading any static image from your device. Supports all major formats including JPG, PNG, and more.",
    "Our  powerful AI models work together - Image Understanding, Stable Diffusion, and background Music transform your image into a dynamic video.",
    "Export your AI-generated video in stunning 720p quality and share it directly to social media or save it to your device.",
  ];

  // Icon background colors (exact from pictures)
  final List<Color> iconBg = [
    Color(0xFF7C3AED), // purple
    Color(0xFF10B981), // green
    Color(0xFFF59E0B), // orange
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor:  Color(0xFF0F172A),
         // backgroundColor: const Color(0xFF0B0F1C), // dark navy background

        body: Stack(
          children: [
            PageView.builder(
              controller: controller,
              onPageChanged: (i) => setState(() => index = i),
              itemCount: 3,
              itemBuilder: (_, i) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ICON BOX (same size + Same shape triple Screen)
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: iconBg[i],
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Icon(
                        icons[i],
                        color: Colors.white,
                        size: 56,
                      ),
                    ),

                     SizedBox(height: 45),

                    // TITLE
                    Text(
                      titles[i],
                      textAlign: TextAlign.center,
                      style:  TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'font4'
                      ),
                    ),

                     SizedBox(height: 12),

                    // SUBTITLE (MULTI-LINE centered)
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        subs[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15.5,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // BOTTOM NAV (Skip + Dots + Next)
            Positioned(
              left: 20,
              right: 20,
              bottom: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // SKIP
                  // TextButton(
                  //   onPressed: () => controller.jumpToPage(2),
                  //   child: Text(
                  //     "Skip",
                  //     style: TextStyle(
                  //       color: Colors.white.withOpacity(0.85),
                  //       fontSize: 16,
                  //       fontFamily: 'font6'
                  //     ),
                  //   ),
                  // ),

                  // DOTS (EXACT original style)
                  GestureDetector(
                    onTap: () {
                      // Navigate to authentication screen when skip is tapped
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GlassAuthScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Skip",
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 16,
                          fontFamily: 'font6'
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(3, (i) {
                      bool active = index == i;
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 250),
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active ? Colors.blueAccent : Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),

                  // NEXT / GET STARTED
                  GestureDetector(
                    onTap: () {
                      if (index < 2) {
                        controller.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease);
                      } else {
                        //login screen phr move krwana wala method
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>  GlassAuthScreen(),
                          ),
                        );
                        // Navigator.pushReplacementNamed(context, "/home");
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF6366F1),
                            Color(0xFF8B5CF6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        index == 2 ? "Get Started" : "Next",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'font6'
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
