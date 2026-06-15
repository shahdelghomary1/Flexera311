// import 'package:flexera/core/utils/payment_formatters.dart';
// import 'package:flexera/model/auth_models/booking_model.dart';
// import 'package:flexera/view/screens/booking_review_screen.dart';
// import 'package:flexera/view/widget/payment_widgets.dart';
// import 'package:flexera/view_model/appointment_view_model.dart';
// import 'package:flexera/view_model/payment_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
//
// class PaymentScreen extends StatelessWidget {
//   final BookingModel doctor;
//
//   const PaymentScreen({super.key, required this.doctor});
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final size = MediaQuery.of(context).size;
//
//     final vm = Provider.of<PaymentViewModel>(context);
//
//     return Scaffold(
//       backgroundColor: isDark ? Color(0xFF131313) : Color(0xFFF7F7FB),
//       body: Stack(
//         children: [
//           Align(
//             alignment: Alignment(0, 0.2),
//             child: Image.asset(
//               "assets/images/paymentbackground.png",
//               fit: BoxFit.contain,
//               width: size.width,
//             ),
//           ),
//           SafeArea(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20.w),
//               child: SingleChildScrollView(
//                 child: Form(
//                   key: vm.formKey,
//                   child: Column(
//                     children: [
//                       SizedBox(height: 50.h),
//                       Row(
//                         children: [
//                           GestureDetector(
//                             onTap: () => Navigator.of(context).pop(),
//                             child: Container(
//                               height: 44.h,
//                               width: 44.w,
//                               decoration: BoxDecoration(
//                                 boxShadow: [
//                                   BoxShadow(
//                                       color: Colors.black.withOpacity(0.2),
//                                       offset: Offset(0, 4.h),
//                                       blurRadius: 8),
//                                 ],
//                                 color: isDark ? Colors.white10 : Colors.white,
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Padding(
//                                 padding: EdgeInsets.all(12.0.r),
//                                 child: Image.asset('assets/icons/arrow.png',
//                                     color:
//                                         isDark ? Colors.white : Colors.black),
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             child: Center(
//                               child: Text(
//                                 "Payment",
//                                 style: GoogleFonts.quicksand(
//                                   fontSize: 26.sp,
//                                   fontWeight: FontWeight.bold,
//                                   color: isDark ? Colors.white : Colors.black,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 42.w),
//                         ],
//                       ),
//                       SizedBox(height: 100.h),
//                       SizedBox(
//                         height: 195.h,
//                         width: 212.w,
//                         child: Image.asset(
//                           "assets/images/credit_motion.gif",
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       SizedBox(height: 30.h),
//                       PaymentTextField(
//                         hintText: "Cardholder's Name",
//                         controller: vm.cardHolderController,
//                         validator: vm.validateName,
//                         keyboardType: TextInputType.name,
//                         height: 61.h,
//                         width: 350.w,
//                         focusNode: vm.nameFocusNode,
//                         textInputAction: TextInputAction.next,
//                         onFieldSubmitted: (_) {
//                           FocusScope.of(context)
//                               .requestFocus(vm.numberFocusNode);
//                         },
//                       ),
//                       SizedBox(height: 30.h),
//                       PaymentTextField(
//                         height: 61.h,
//                         width: 350.h,
//                         hintText: "Card Number",
//                         controller: vm.cardNumberController,
//                         validator: vm.validateCardNumber,
//                         keyboardType: TextInputType.number,
//                         focusNode: vm.numberFocusNode,
//                         textInputAction: TextInputAction.next,
//                         onFieldSubmitted: (_) {
//                           FocusScope.of(context)
//                               .requestFocus(vm.expiryFocusNode);
//                         },
//                         maxLength: 22,
//                         inputFormatters: [
//                           FilteringTextInputFormatter.digitsOnly,
//                           CardNumberInputFormatter(),
//                         ],
//                         prefixIcon: Padding(
//                           padding: EdgeInsets.all(10.0.r),
//                           child: Image.asset("assets/icons/mastercard 1.png",
//                               width: 24.w),
//                         ),
//                       ),
//                       SizedBox(height: 30.h),
//                       Container(
//                         width: 350.w,
//                         child: Row(
//                           children: [
//                             PaymentTextField(
//                               height: 61.h,
//                               width: 154.w,
//                               hintText: "Expiry (MM/YY)",
//                               controller: vm.expiryController,
//                               validator: vm.validateExpiry,
//                               keyboardType: TextInputType.number,
//                               focusNode: vm.expiryFocusNode,
//                               textInputAction: TextInputAction.next,
//                               onFieldSubmitted: (_) {
//                                 FocusScope.of(context)
//                                     .requestFocus(vm.cvvFocusNode);
//                               },
//                               maxLength: 5,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.digitsOnly,
//                                 CardDateInputFormatter(),
//                               ],
//                             ),
//                             SizedBox(width: 20.w),
//                             Expanded(
//                               child: PaymentTextField(
//                                 height: 61.h,
//                                 width: 154.w,
//                                 hintText: "CVV/CVC",
//                                 controller: vm.cvvController,
//                                 validator: vm.validateCVV,
//                                 keyboardType: TextInputType.number,
//                                 focusNode: vm.cvvFocusNode,
//                                 textInputAction: TextInputAction.done,
//                                 onFieldSubmitted: (_) {
//                                   FocusScope.of(context).unfocus();
//                                 },
//                                 maxLength: 4,
//                                 inputFormatters: [
//                                   FilteringTextInputFormatter.digitsOnly,
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 70.h),
//                       SizedBox(
//                         width: 235.w,
//                         height: 54.h,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             if (vm.submitPayment()) {
//                               final appointmentVM =
//                                   Provider.of<AppointmentViewModel>(context,
//                                       listen: false);
//
//                               appointmentVM.setPaymentDetails(
//                                 name: vm.cardHolderController.text,
//                                 cardNumber: vm.cardNumberController.text,
//                               );
//
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (_) =>
//                                         BookingReviewScreen(doctor: doctor)),
//                               );
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.transparent,
//                             padding: EdgeInsets.zero,
//                             elevation: 0,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(16)),
//                           ),
//                           child: Ink(
//                             decoration: BoxDecoration(
//                               gradient: const LinearGradient(colors: [
//                                 Color(0xFF786AC8),
//                                 Color(0xFF5B5F9C)
//                               ]),
//                               borderRadius: BorderRadius.circular(14),
//                             ),
//                             child: Container(
//                               alignment: Alignment.center,
//                               child: Text(
//                                 "Continues",
//                                 style: GoogleFonts.quicksand(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 25.sp),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 20.h),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
