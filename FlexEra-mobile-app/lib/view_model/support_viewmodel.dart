import 'package:flutter/material.dart';
import 'package:flexera/model/faq_model.dart';

class SupportViewModel extends ChangeNotifier {
  final List<FAQModel> faqs = [
    FAQModel(
      question: "How can I reset my password?",
      answer:
          "Go to the login page, click on 'Forgot your password?', enter your email, and follow the instructions to reset your password.",
    ),
    FAQModel(
      question: "How do I book an appointment?",
      answer:
          "You can book an appointment through the 'Booking' section in the app or contact support.",
    ),
    FAQModel(
      question: "Can I track my exercise progress?",
      answer:
          "Yes, you can view your exercise progress in the 'Progress' section of your profile.",
    ),
    FAQModel(
      question: "How do I contact my doctor?",
      answer:
          "You can contact your doctor through the 'Messages' tab in the app or via email.",
    ),
  ];
}
