import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/constants.dart';

class TermsConditionsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> _fetchTermsConditions() async {
    try {
      var doc = await _firestore
          .collection('terms_conditions')
          .doc('terms_conditions')
          .get();
      if (doc.exists) {
        return doc['content'];
      } else {
        return "No terms and conditions available.";
      }
    } catch (e) {
      return "Error fetching terms and conditions.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Terms and Conditions',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 19.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<String>(
          future: _fetchTermsConditions(),
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
                ));
          }),
    );
  }
}
