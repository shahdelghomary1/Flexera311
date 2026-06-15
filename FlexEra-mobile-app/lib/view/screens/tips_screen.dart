import 'package:flexera/view/widget/tip_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class TipsScreen extends StatelessWidget {
  TipsScreen({super.key});

  final List<TipItem> tips = [
    TipItem(
      icon: "🦵🏻",
      title: "Strengthen Your Core",
      shortDescription:
          "A strong core reduces lower-back pain and improves balance",
      fullDescription:
          "A strong core is essential for supporting your spine, improving posture, and reducing lower-back pain. Core muscles include your abdominal muscles, lower-back muscles, and pelvic floor, and when they are weak, your body places extra stress on the lumbar spine. Regular core training improves balance, stability, and your ability to perform daily activities without discomfort. Physiotherapists recommend starting with low-impact exercises such as planks, bridges, and abdominal bracing, gradually increasing intensity as your control improves",
      image: 'assets/images/tip1.jpg',
      link:
          "https://www.mayoclinic.org/healthy-lifestyle/fitness/in-depth/core-strength/art-20546851",
      color: Color(0xFF590B8D),
      disclaimer: true,
    ),
    TipItem(
      icon: "🤸🏻‍♂️",
      title: "Daily Stretching",
      shortDescription:
          "Regular stretching improves flexibility and reduces muscle tension",
      fullDescription:
          "Stretching helps reduce muscle tightness, increases your range of motion, and prevents injuries. Tight muscles especially in the hamstrings, hip flexors, chest, and shoulders can contribute to poor posture and joint pain. A daily stretching routine of 10–15 minutes can significantly improve mobility over time. Hold each stretch for 15–30 seconds without bouncing, and avoid forcing the movement into pain. Consistency is more important than intensity; gentle stretching every day has stronger benefits than occasional deep stretching.",
      image: 'assets/images/tip2.jpg',

      link:
          "https://www.mayoclinic.org/healthy-lifestyle/fitness/in-depth/stretching/art-20546848",
      color: Color(0xFF3111B6),
      // Purple
      disclaimer: true,
    ),
    TipItem(
      icon: "🧊",
      title: "Cold vs. Heat Therapy",
      shortDescription: "Cold reduces swelling , heat relaxes tight muscles",
      fullDescription:
          "Cold and heat therapy are two simple but powerful tools in physiotherapy. Cold (ice packs) is best used during the first 48 hours after an injury because it reduces inflammation, swelling, and pain. Heat (warm compresses or heating pads) helps relax tight muscles, loosen stiff joints, and improve blood flow. Using the wrong method at the wrong time can worsen symptoms, so it's important to understand the difference. For chronic back or neck stiffness, heat works best; for sprains, bruises, or sudden pain, cold is safer.",
      image: 'assets/images/tip3.jpg',

      link:
          "https://www.healthline.com/health/chronic-pain/treating-pain-with-heat-and-cold",
      color: Color(0xFF9E37F9),
      // blue-purple
      disclaimer: true,
    ),
    TipItem(
      icon: "🚶🏻‍♂️",
      title: "Walking Helps Recovery",
      shortDescription:
          "Walking improves blood flow, reduces stiffness, and boosts joint health",
      fullDescription:
          "Walking is one of the simplest and safest exercises for improving joint mobility, enhancing blood circulation, and reducing stiffness. It's low-impact, making it suitable for patients with arthritis, back pain, or post-injury recovery. Starting with 10–20 minutes a day can increase cardiovascular health, improve mood, and support weight management—all of which help reduce strain on the musculoskeletal system. Gradually increase your pace and duration as your endurance improves.",
      image: 'assets/images/tip4.jpg',
      link:
          "https://curaclinical.com/blog/stepping-towards-recovery-the-healing-power-of-walking/",
      color: Color(0xFF5955DD),
      disclaimer: false,
    ),
    TipItem(
      icon: "🛌",
      title: "Sleep Supports Healing",
      shortDescription:
          "Quality sleep helps tissue repair and reduces inflammation",
      fullDescription:
          "Sleep is crucial for physical recovery because the body repairs tissues, builds muscle, and reduces inflammation during rest. Lack of sleep can slow healing, increase sensitivity to pain, and decrease your ability to exercise or move comfortably. Adults generally need 7–9 hours of quality sleep per night. Maintaining a regular sleep schedule and avoiding screens before bedtime can help improve sleep quality and support your physiotherapy progress.",
      image: 'assets/images/tip5.jpg',
      link:
          "https://mdpremier.com/how-sleep-and-recovery-help-your-body-heal-faster/",
      color: Color(0xFFC390F0),
      disclaimer: false,
    ),
    TipItem(
      icon: "🧠",
      title: "Move Through the Pain ",
      shortDescription:
          "Complete rest can slow recovery , gentle movement is better",
      fullDescription:
          "Complete rest after an injury may seem like the best choice, but too much rest can delay healing and lead to more stiffness and weakness. Gentle movement, guided by pain levels, helps maintain mobility and improve circulation. Physiotherapists recommend avoiding sharp or worsening pain, but continuing with light activity and exercises that promote gradual recovery. Movement is a key part of healing—not something to fear",
      image: 'assets/images/tip6.jpg',

      link:
          "https://www.psychologytoday.com/us/blog/goodbye-perfect/202409/how-to-move-through-pain-and-fear",
      color: Color(0xFFB5CEFD),
      // Light blue
      disclaimer: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      backgroundColor: isDark ? const Color(0xFF131313) : Colors.white,
      body: Stack(
        children: [
          /// Background
          Positioned.fill(
            child: Container(
              color: isDark ? const Color(0xFF131313) : Colors.white,
            ),
          ),

          Positioned(
            top: -10.h,
            left: -25.w,
            child: Transform.rotate(
              angle: 0,
              child: Image.asset(
                isDark
                    ? 'assets/images/Ellipse8dark.png'
                    : 'assets/images/Ellipse8.png',
                width: 450.w,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            bottom: -10.h,
            left: 0,
            child: Transform.rotate(
              angle: 0,
              // child: Opacity(
              //   opacity: 0.9,
              child: Image.asset(
                'assets/images/Ellipse1.png',
                width: 450.w,
                // height: 1009.65,
                fit: BoxFit.contain,
              ),
              // ),
            ),
          ),

          Positioned(
            top: 80.h,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 25.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Custom circular back button
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            // rounded circular
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              // frosted blur
                              child: Container(
                                width: 50.w,
                                height: 50.h,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E1E1E).withOpacity(1)
                                      : Colors.white.withOpacity(1),
                                  // semi-transparent for blur
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color:
                                        isDark ? Colors.white24 : Colors.white,
                                    width: 1.w,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 4,
                                      offset: Offset(0, 4.h), // shadow
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/icons/arrow.png',
                                    width: 25.w,
                                    height: 25.h,
                                    color: isDark ? Colors.white : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 12.w),

                        // Column for title + subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Gradient "Discover" title
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final text = "Discover";
                                  final textStyle = GoogleFonts.homemadeApple(
                                    fontSize: 44.sp,
                                  );

                                  final textPainter = TextPainter(
                                    text:
                                        TextSpan(text: text, style: textStyle),
                                    textDirection: TextDirection.ltr,
                                  )..layout();

                                  return Text(
                                    text,
                                    textAlign: TextAlign.center,
                                    style: textStyle.copyWith(
                                      foreground: Paint()
                                        ..shader = LinearGradient(
                                          colors: [
                                            Color(0xFF590B8D),
                                            Color(0xFF786AC8)
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ).createShader(
                                          Rect.fromLTWH(
                                            0,
                                            0,
                                            textPainter.width,
                                            textPainter.height,
                                          ),
                                        ),
                                    ),
                                  );
                                },
                              ),

                              Text(
                                "helpful guides for your recovery journey",
                                style: GoogleFonts.instrumentSans(
                                    fontSize: 15.sp,
                                    color: isDark ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.w600,
                                    height: -1.h),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Tip cards
                  ...tips.map(
                    (item) => TipCard(
                      item: item,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TipDetailsScreen(item: item, isDark: isDark),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 60.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
