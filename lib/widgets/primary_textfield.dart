import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/constants.dart';

class PrimaryTextField extends StatelessWidget {
  final TextInputType fieldType;
  final String headerText;
  final String hintText;
  final bool obsecure;
  final bool readOnly;
  final int maxLines;
  final TextEditingController controller;
  final List<TextInputFormatter>? inputFormatters;

  const PrimaryTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.headerText,
    this.fieldType = TextInputType.text,
    this.maxLines = 1,
    this.obsecure = false,
    this.readOnly = false,
     this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headerText,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        TextFormField(
          obscureText: obsecure,
          maxLines: maxLines,
          keyboardType: fieldType,
          controller: controller,
          readOnly: readOnly,
          style: GoogleFonts.inter(fontSize: 14.sp),
          cursorColor: kPrimaryColor,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.width * 0.030.h,
                  horizontal: 22.w),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(33),
                borderSide: const BorderSide(color: Color(0xFFECECEC)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(33),
                borderSide: const BorderSide(
                  color: Colors.black26,
                ),
              ),
              fillColor: const Color(0xFFECECEC),
              filled: true,
              hintStyle: GoogleFonts.inter(
                color: const Color(0xFF868686),
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
              ),
              isDense: true,
              hintText: hintText,
              border: InputBorder.none
              // border: OutlineInputBorder(borderRadius: BorderRadius.circular(33))
              ),
               inputFormatters: inputFormatters,
        ),
      ],
    );
  }
}



class PhoneTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onCountryCodeChanged;

  const PhoneTextField({
    required this.controller,
    required this.onCountryCodeChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Phone No',
          style: GoogleFonts.inter(
        color: Colors.black,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          keyboardType: TextInputType.phone,
          controller: controller,
          style: GoogleFonts.inter(color: kblack, fontSize: 14.sp),
          decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width * 0.030.h,
          horizontal: 22.w,
        ),
        prefixIcon: CountryCodePicker(
          onChanged: (value) => onCountryCodeChanged(value.dialCode ?? ''),
          initialSelection: 'PK',
          favorite: ['+92', 'PK'],
          showCountryOnly: false,
          showOnlyCountryWhenClosed: false,
          alignLeft: false,
          textStyle: GoogleFonts.inter(color: kblack),
          flagDecoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(33.r),
          borderSide: const BorderSide(color: Color(0xFFECECEC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(33.r),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        fillColor: const Color(0xFFECECEC),
        filled: true,
        hintText: '3001234567',
        isDense: true,
        hintStyle: GoogleFonts.inter(
          color: const Color(0xFF868686),
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
          ),
        ),
      ],
    );
  }
}

// class PhoneTextField extends StatelessWidget {
//   final TextEditingController controller;

//   const PhoneTextField({
//     required this.controller,
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Enter Phone No',
//           style: GoogleFonts.inter(
//             color: Colors.black,
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         SizedBox(height: 8.h),
//         TextFormField(
//           keyboardType: TextInputType.number,
//           controller: controller,
//           style: GoogleFonts.inter(color: kblack, fontSize: 14.sp),
//           decoration: InputDecoration(
//             contentPadding: EdgeInsets.symmetric(
//                 vertical: MediaQuery.of(context).size.width * 0.030.h,
//                 horizontal: 22.w),
//             prefixText: '+92 ', // Static country code as a prefix
//             prefixStyle: GoogleFonts.inter(
//               color: kblack,
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w500,
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(33.r),
//               borderSide: const BorderSide(color: Color(0xFFECECEC)),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(33.r),
//               borderSide: const BorderSide(color: Colors.black26),
//             ),
//             fillColor: const Color(0xFFECECEC),
//             filled: true,
//             hintText: '3001234567',
//             isDense: true,
//             hintStyle: GoogleFonts.inter(
//               color: const Color(0xFF868686),
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
