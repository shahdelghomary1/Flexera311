import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/assets/assets_manager.dart';
import '../../core/themes/app_colors.dart';
import '../../view_model/onboarding_view_model.dart';

class OnboardingWidget extends StatelessWidget {
  final String backgroundImage;
  final String mainImage;
  final String title;
  final String subtitle;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;
  final bool isLastPage;
  final bool isFirstPage;
  final Alignment imageAlignment;
  final double imageTopPadding;
  final bool isTitleAboveImage;
  final bool isCenteredTitle;
  final double titlePaddingLeft;

  const OnboardingWidget({
    super.key,
    required this.backgroundImage,
    required this.mainImage,
    required this.title,
    this.subtitle = '',
    required this.description,
    required this.buttonText,
    required this.onPressed,
    this.isLastPage = false,
    this.isFirstPage = false,
    this.imageAlignment = Alignment.center,
    this.imageTopPadding = 0,
    this.isTitleAboveImage = false,
    this.isCenteredTitle = false,
    this.titlePaddingLeft = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          top: 260,
          child: Image.asset(
            backgroundImage,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        SingleChildScrollView(
          child:
            Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 20, right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "F",
                              style: GoogleFonts.grandHotel(
                                fontSize: 40,
                                color: AppColors.blackcolor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Transform.translate(
                              offset: const Offset(-9, 0),
                              child: Image.asset(
                                AssetsManager.logoIcon,
                                width: 40,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(-9, 0),
                              child: Text(
                                "exera",
                                style: GoogleFonts.grandHotel(
                                  fontSize: 40,
                                  color: AppColors.blackcolor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (isFirstPage)
                          Container(
                            margin: const EdgeInsets.only(right: 16, top: 30),
                            child: TextButton(
                              onPressed: () => context
                                  .read<OnboardingViewModel>()
                                  .goToHome(context),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                "Skip",
                                style: GoogleFonts.quicksand(
                                  color: AppColors.graycolor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (isTitleAboveImage)
                    Column(
                      crossAxisAlignment: isCenteredTitle
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: isCenteredTitle
                              ? Alignment.center
                              : Alignment.centerLeft,
                          child: Text(
                            title,
                            textAlign: isCenteredTitle
                                ? TextAlign.center
                                : TextAlign.start,
                            style: GoogleFonts.pacifico(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: [
                                    AppColors.darkpurplecolor,
                                    AppColors.lightpurplecolor,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            textAlign: isCenteredTitle
                                ? TextAlign.center
                                : TextAlign.start,
                            style: GoogleFonts.quicksand(
                              fontSize: 24,
                              color: AppColors.lightblackcolor,
                            ),
                          ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            description,
                            textAlign: isCenteredTitle
                                ? TextAlign.center
                                : TextAlign.start,
                            style: GoogleFonts.quicksand(
                              fontSize: 15,
                              color: AppColors.lightgraycolor,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: imageTopPadding),
                    child: Align(
                      alignment: imageAlignment,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.asset(
                          mainImage,
                          width: MediaQuery.of(context).size.width * 1.8,
                          height: MediaQuery.of(context).size.height * 0.42,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SmoothPageIndicator(
                        controller: context
                            .read<OnboardingViewModel>()
                            .pageController,
                        count: 3,
                        effect: const ExpandingDotsEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          spacing: 8,
                          expansionFactor: 6,
                          dotColor: Colors.grey,
                          activeDotColor: Colors.grey,
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            AppColors.darkpurplecolor,
                            AppColors.lightpurplecolor,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(bounds),
                        blendMode: BlendMode.srcATop,
                        child: SmoothPageIndicator(
                          controller: context
                              .read<OnboardingViewModel>()
                              .pageController,
                          count: 3,
                          effect: const ExpandingDotsEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            spacing: 8,
                            expansionFactor: 6,
                            dotColor: Colors.transparent,
                            activeDotColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (!isTitleAboveImage)
                    Column(
                      crossAxisAlignment: isCenteredTitle
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: isCenteredTitle
                              ? Alignment.center
                              : Alignment.centerLeft,
                          child: Text(
                            title,
                            textAlign: isCenteredTitle
                                ? TextAlign.center
                                : TextAlign.start,
                            style: GoogleFonts.pacifico(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: [
                                    AppColors.darkpurplecolor,
                                    AppColors.lightpurplecolor,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            textAlign: isCenteredTitle
                                ? TextAlign.center
                                : TextAlign.start,
                            style: GoogleFonts.quicksand(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightblackcolor,
                            ),
                          ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            description,
                            textAlign: isCenteredTitle
                                ? TextAlign.center
                                : TextAlign.start,
                            style: GoogleFonts.quicksand(
                              fontSize: 15,
                              color: AppColors.lightgraycolor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  SizedBox(height: 60),
                  Consumer<OnboardingViewModel>(
                    builder: (context, viewModel, child) {
                      final currentPage = viewModel.currentIndex;
                      if (currentPage == 0 || currentPage == 1) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: GestureDetector(
                              onTap: () {
                                viewModel.pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Image.asset(AssetsManager.next, height: 60),
                            ),
                          ),
                        );
                      } else if (currentPage == 2) {
                        return Align(
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                            onTap: () {
                              context.read<OnboardingViewModel>().goToHome(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.darkpurplecolor,
                                    AppColors.lightpurplecolor,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Get Started",
                                style: GoogleFonts.instrumentSans(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),

        ),
      ],
    );
  }
}
