import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/constants.dart';

class RoundButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const RoundButton({
    required this.onPressed,
    Key? key, required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 52.w, vertical: 11.h),
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
