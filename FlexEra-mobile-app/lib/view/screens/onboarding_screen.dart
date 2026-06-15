import 'package:flexera/view/widget/onboarding_widget.dart';
import 'package:flexera/view_model/onboarding_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/assets/assets_manager.dart';
import '../../core/themes/app_colors.dart';
import 'role_selection_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingViewModel(),
      child: Consumer<OnboardingViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: AppColors.backgroundcolor1,
            body: SafeArea(
              child: GestureDetector(
                onTap: viewModel.nextPage,
                child: Stack(
                  children: [
                    PageView(
                      controller: viewModel.pageController,
                      onPageChanged: viewModel.onPageChanged,
                      children: [
                        OnboardingWidget(
                          mainImage: AssetsManager.first,
                          backgroundImage: AssetsManager.bg1,
                          title: "  Welcome",
                          subtitle: "   Feeling pain or discomfort?",
                          description:
                              "     We’re here to help you restore your body’s \n      balance and move freely again.",
                          buttonText: "Next",
                          onPressed: viewModel.nextPage,
                          imageAlignment: Alignment.topCenter,
                          // isCenteredTitle: false,
                          imageTopPadding: 5.h,
                          isFirstPage: true,
                        ),
                        OnboardingWidget(
                          title: "Guidance",
                          description:
                              "We provide expert-designed exercise programs to help you recover safely and effectively.",
                          mainImage: AssetsManager.second,
                          backgroundImage: AssetsManager.bg2,
                          buttonText: "Next",
                          onPressed: viewModel.nextPage,
                          imageAlignment: Alignment.center,
                          isTitleAboveImage: true,
                          isCenteredTitle: true,
                          imageTopPadding: 29.h,
                        ),
                        OnboardingWidget(
                          title: "Get Started",
                          mainImage: AssetsManager.third,
                          backgroundImage: AssetsManager.bg3,
                          description: "",
                          buttonText: "Get Started",
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RoleSelectionScreen(),
                              ),
                            );
                          },
                          isLastPage: true,
                          isCenteredTitle: true,
                          isTitleAboveImage: true,
                          imageAlignment: Alignment.bottomCenter,
                          imageTopPadding: 40.h,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
