import 'package:flexera/core/themes/app_colors.dart';
import 'package:flexera/view/widget/mood_clipper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flexera/core/assets/assets_manager.dart';

class MoodOverlay extends StatefulWidget {
  final VoidCallback onDismissed;

  const MoodOverlay({super.key, required this.onDismissed});

  @override
  State<MoodOverlay> createState() => _MoodOverlayState();
}

class _MoodOverlayState extends State<MoodOverlay>
    with SingleTickerProviderStateMixin {
  String? _selectedMood;
  final TextEditingController _noteController = TextEditingController();

  late final AnimationController _controller;
  late final Animation<double> _expandAnim;
  late final Animation<double> _bounceAnim;

  double curveYOffset(double bounceValue) {
    return 30 * _expandAnim.value + (6 * bounceValue);
  }

  Offset _getStaticOffset(String label) {
    switch (label) {
      case 'Excellent':
        return const Offset(-6, 0);
      case 'Okay':
        return const Offset(-5, 0);
      case 'Not Great':
        return const Offset(-4, 0);
      case 'Tired':
        return const Offset(-2, 0);
      default:
        return Offset.zero;
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _expandAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    _bounceAnim =
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveAndClose() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mood_overlay_seen', true);
    Navigator.pop(context);
    widget.onDismissed();
  }

  String _getMoodImage(String mood) {
    switch (mood) {
      case 'Excellent':
        return AssetsManager.excellent;
      case 'Okay':
        return AssetsManager.okay;
      case 'Not Great':
        return AssetsManager.notGreat;
      case 'Tired':
        return AssetsManager.tired;
      default:
        return AssetsManager.okay;
    }
  }

  void _selectMood(String mood) {
    setState(() => _selectedMood = mood);
    _controller.forward(from: 0);
  }

  void _selectMoodSafely(String mood) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _selectMood(mood);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final expandValue = _expandAnim.value;
        final bounceValue = _bounceAnim.value;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -3,
                left: 150,
                child: Container(
                  width: 104,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Color(0xFF8D8D8D),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 20),
                          Text(
                            "How is your health",
                            style: GoogleFonts.pacifico(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 135),
                            child: Text(
                              "today?",
                              style: GoogleFonts.pacifico(
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 180,
                      ),
                      if (_selectedMood != null)
                        Positioned(
                          top: 120 - 18 * expandValue,
                          left: 0,
                          right: 0,
                          child: Transform.translate(
                            offset: const Offset(65, 0),
                            child: Transform.scale(
                              scale: 1.5 + 0.08 * expandValue,
                              child: Image.asset(
                                _getMoodImage(_selectedMood!),
                                height: 140 + 15 * expandValue,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Transform.translate(
                    offset: const Offset(0, 35),
                    child: ClipPath(
                      clipper: MoodClipper(
                        selectedIndex: _selectedMood == null
                            ? -1
                            : ['Excellent', 'Okay', 'Not Great', 'Tired']
                                .indexOf(_selectedMood!),
                        progress: _expandAnim.value,
                      ),
                      child: Transform.translate(
                        offset: const Offset(0, -35),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 40, bottom: 0),
                          color: const Color(0xFF9249E0),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 75,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    'Excellent',
                                    'Okay',
                                    'Not Great',
                                    'Tired'
                                  ].map((label) {
                                    final isSelected = _selectedMood == label;

                                    return GestureDetector(
                                      onTap: () => _selectMoodSafely(label),
                                      child: AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 400),
                                        transitionBuilder: (Widget child,
                                            Animation<double> anim) {
                                          return FadeTransition(
                                            opacity: anim,
                                            child: SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(0, 0.2),
                                                end: Offset.zero,
                                              ).animate(anim),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: isSelected
                                            ? Transform.translate(
                                                offset: _getStaticOffset(
                                                        label) +
                                                    Offset(
                                                        0,
                                                        -0.5 *
                                                            curveYOffset(
                                                                bounceValue)),
                                                child: Transform.scale(
                                                  scale: 1 + 0.1 * bounceValue,
                                                  child: Column(
                                                    children: [
                                                      Image.asset(
                                                        AssetsManager
                                                            .healthLight,
                                                        height: 47,
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        label,
                                                        style: GoogleFonts
                                                            .quicksand(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 2,
                                                    height: 14,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    label,
                                                    style:
                                                        GoogleFonts.quicksand(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizeTransition(
                                sizeFactor: _expandAnim,
                                axisAlignment: -1.0,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, top: 0, bottom: 10),
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.black
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          constraints: const BoxConstraints(
                                              maxHeight: 72),
                                          child: TextField(
                                            controller: _noteController,
                                            maxLines: 12,
                                            style: GoogleFonts.instrumentSans(
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontSize: 15,
                                            ),
                                            decoration: InputDecoration(
                                              hintText:
                                                  "Explain here what you feel ...",
                                              hintStyle:
                                                  GoogleFonts.instrumentSans(
                                                color: isDark
                                                    ? Colors.white70
                                                    : Color(0xFF767171),
                                                fontSize: 13,
                                              ),
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 6),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 7),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: GestureDetector(
                                          onTap: _saveAndClose,
                                          child: Container(
                                            width: 87,
                                            height: 25,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? Colors.black
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: isDark
                                                    ? Color(0xFF4050AC)
                                                    : Color(0xFF39489A),
                                                width: 1,
                                              ),
                                            ),
                                            child: Center(
                                              child: ShaderMask(
                                                shaderCallback: (Rect bounds) {
                                                  return LinearGradient(
                                                    colors: [
                                                      AppColors.gradientStart,
                                                      AppColors.darkpurplecolor
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ).createShader(bounds);
                                                },
                                                child: Text(
                                                  "Save",
                                                  style: GoogleFonts.quicksand(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
