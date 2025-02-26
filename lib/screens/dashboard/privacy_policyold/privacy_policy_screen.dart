import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> _fetchPrivacyPolicy() async {
    try {
      var doc = await _firestore
          .collection('privacy_policy')
          .doc('privacy_policy')
          .get();
      if (doc.exists) {
        return doc['content'];
      } else {
        return "No privacy policy available.";
      }
    } catch (e) {
      return "Error fetching privacy policy.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 19.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<String>(
        future: _fetchPrivacyPolicy(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: kPrimaryColor,
            ));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
                child: Text(
              "Error fetching data.",
              style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
            ));
          }
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
            child: SingleChildScrollView(
              child: Text(snapshot.data!,
                  style: GoogleFonts.poppins(fontSize: 16)),
            ),
          );
        },
      ),
    );
  }
}
