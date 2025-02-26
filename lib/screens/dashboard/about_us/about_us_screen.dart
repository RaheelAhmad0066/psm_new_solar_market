import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/constants.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'About Us',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 18.w,vertical: 12.h),
          child: Column(
            children: [
              Text(
                'Welcome to Pakistan Solar Market',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryColor,
                ),
              ),
              Text(
                'We provide the latest in solar energy solutions for Pakistan, offering a range of high-quality panels, inverters, and lithium batteries.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              SizedBox(height: 20),
          
              // Panels Section
              _buildSection(
                context,
                title: 'Solar Panels',
                description:
                    'Our solar panels are built with the latest technology to provide maximum efficiency and reliability in the harshest of conditions. They are ideal for residential and commercial installations.',
                imagePath:
                    'assets/icons/panels.svg', // You can update this with an actual image path
              ),
              SizedBox(height: 20),
          
              // Inverters Section
              _buildSection(
                context,
                title: 'Inverters',
                description:
                    'We offer a range of inverters that convert solar power to usable electricity. Our inverters are known for their efficiency, durability, and easy integration with existing systems.',
                imagePath:
                    'assets/icons/inverters.svg', // Update with your actual image
              ),
              SizedBox(height: 20),
          
              // Lithium Batteries Section
              _buildSection(
                context,
                title: 'Lithium Batteries',
                description:
                    'Our lithium batteries provide long-lasting storage for solar energy. They are compact, lightweight, and have a higher energy density, ensuring you get the most out of your solar system.',
                imagePath:
                    'assets/icons/lithium.svg', // Update with your actual image
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title,
      required String description,
      required String imagePath}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style:
              GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Text(
          description,
          style: GoogleFonts.inter(fontSize: 16.sp, color: Colors.black),
        ),
        SizedBox(height: 16.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(8.sp),
          child: SvgPicture.asset(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 78.h,
            color: kPrimaryColor,
          ),
        ),
      ],
    );
  }
}
