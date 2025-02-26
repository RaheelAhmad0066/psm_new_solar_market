import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/constants.dart';

class TabBarItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final bool isProfile;
  final Color? unSelectedColor;

  const TabBarItem({
    super.key,
    required this.title,
    required this.isSelected,
    this.unSelectedColor,
    required this.isProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isProfile ? 2.w : 0),
      decoration: BoxDecoration(
        color: isSelected ? kPrimaryColor : unSelectedColor,
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            style: GoogleFonts.inter(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: isProfile ? 9.sp : 12.sp,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
