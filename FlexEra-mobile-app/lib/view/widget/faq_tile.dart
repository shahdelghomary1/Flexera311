import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flexera/core/themes/app_colors.dart';
import 'package:flexera/model/faq_model.dart';

class FAQTile extends StatelessWidget {
  final FAQModel faq;

  const FAQTile({super.key, required this.faq});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.lightpurplecolor, AppColors.darkpurplecolor]
              : [AppColors.lightpurplecolor, AppColors.darkpurplecolor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.grey.shade900, Colors.black]
                : [Color(0xFFE0E0E0), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            childrenPadding:
                const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 10),
            collapsedShape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            iconColor: AppColors.mainColor,
            collapsedIconColor: AppColors.mainColor,
            title: Text(
              faq.question,
              style: GoogleFonts.instrumentSans(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.mainColor,
              ),
            ),
            children: [
              Container(
                width: double.infinity,
                height: 1.5,
                margin: const EdgeInsets.only(top: 0, bottom: 6),
                color: isDark
                    ? Colors.white24
                    : AppColors.mainColor.withOpacity(0.4),
              ),
              Text(
                faq.answer,
                style: GoogleFonts.instrumentSans(
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.mainColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
