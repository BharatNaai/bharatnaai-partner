import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:partner_app/core/constants/app_colors.dart';
import 'package:partner_app/core/constants/app_strings.dart';
import 'package:partner_app/routes/app_routes.dart';
import 'package:partner_app/providers/welcome_provider.dart';
import 'package:partner_app/widgets/welcome_card.dart';
import 'package:partner_app/widgets/common_button.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key});

  final List<Map<String, String>> slides = [
    {
      "image": "assets/images/wl_1.png",
      "title": AppStrings.welcomeTitle1,
      "subtitle": AppStrings.welcomeSubtitle1,
    },
    {
      "image": "assets/images/wl_2.png",
      "title": AppStrings.welcomeTitle2,
      "subtitle": AppStrings.welcomeSubtitle2,
    },
    {
      "image": "assets/images/wl_3.png",
      "title": AppStrings.welcomeTitle3,
      "subtitle": AppStrings.welcomeSubtitle3,
    },
    {
      "image": "assets/images/wl_4.png",
      "title": AppStrings.welcomeTitle4,
      "subtitle": AppStrings.welcomeSubtitle4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WelcomeProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Carousel with dots inside
              Stack(
                children: [
                  // Carousel
                  CarouselSlider.builder(
                    itemCount: slides.length,
                    itemBuilder: (context, index, realIdx) {
                      final slide = slides[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7.0),
                        child: WelcomeCard(
                          imagePath: slide["image"]!,
                          title: slide["title"]!,
                          subtitle: slide["subtitle"]!,
                        ),
                      );
                    },
                    options: CarouselOptions(
                      height: MediaQuery.sizeOf(context).height * 0.53,
                      enlargeCenterPage: false,
                      autoPlay: true,
                      onPageChanged: (index, reason) {
                        provider.setIndex(index);
                      },
                    ),
                  ),

                  // Dots positioned at bottom of carousel
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: slides.asMap().entries.map((entry) {
                        final selected = provider.currentIndex == entry.key;
                        return Container(
                          width: selected
                              ? 24
                              : 8, // Increased width for selected dot
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              4,
                            ), // Rounded corners for selected dot
                            color: selected
                                ? AppColors.carouselDotSelected
                                : AppColors.carouselDotUnselected,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Title and subtitle below dots
              Text(
                slides[provider.currentIndex]["title"]!,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  slides[provider.currentIndex]["subtitle"]!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              // Buttons
              CommonButton(
                text: AppStrings.loginButton,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.register);
                },
                child: Text(
                  AppStrings.signupButton,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.linkBlue,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
