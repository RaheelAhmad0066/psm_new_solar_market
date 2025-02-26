import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/screens/auth/login_screen.dart';
import 'package:solar_market/screens/auth/register_screen.dart';

class AuthPopup {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration:  ShapeDecoration(
                color: kPrimaryColor, // Replace with your `kPrimaryColor`
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.r),
                    topRight: Radius.circular(18.r),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Account',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

             SizedBox(height: 36.h),

            // Message
            Padding(
                         padding:  EdgeInsets.symmetric(horizontal: 16.r),

              child: Text(
                'Do not have an Account',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
             SizedBox(height: 8.h),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'Please login or register your account to get access',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
             SizedBox(height: 28.h),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor, // Replace with your `kPrimaryColor`
                  ),
                  onPressed: () => Get.to(() => const LoginScreen()),
                  child: Text(
                    'Login',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                 SizedBox(width: 12.w),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor, // Replace with your `kPrimaryColor`
                  ),
                  onPressed: () => Get.to(() => const RegisterSccreen()),
                  child: Text(
                    'Register',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

             SizedBox(height: 28.h),
          ],
        ),
      ),
    );
  }
}
