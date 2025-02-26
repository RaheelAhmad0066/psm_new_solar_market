import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants.dart';
import '../../../widgets/backbutton.dart';

class TermsConditionsScreen extends StatefulWidget {
  @override
  _TermsConditionsScreenState createState() =>
      _TermsConditionsScreenState();
}

class _TermsConditionsScreenState
    extends State<TermsConditionsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _currentTermsConditions = ""; // Stores the current terms and conditions
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTermsConditions();
  }

  // Fetch the current terms and conditions from Firestore
  Future<void> _fetchTermsConditions() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var doc = await _firestore
          .collection('terms_conditions')
          .doc('terms_conditions')
          .get();
      if (doc.exists) {
        setState(() {
          _currentTermsConditions = doc['content'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching terms and conditions: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    await launchUrl(emailUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackNavigatingButton(color: kblack),
        title: Text(
          'Terms and Conditions',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 19.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: kPrimaryColor,
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                
                  SizedBox(height: 10.h),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildTermsConditionsContent(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTermsConditionsContent() {
    final List<String> termsSections = _currentTermsConditions.split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: termsSections.map((section) {
        final lines = section.split('\n');
        if (lines.isEmpty) return const SizedBox.shrink();

        final heading = lines.first.trim();
        final content = lines.skip(1).join('\n').trim();

        return Padding(
          padding: EdgeInsets.only(bottom: 15.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                heading,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 5.h),
              if (content.isNotEmpty)
                RichText(
                  text: TextSpan(
                    children: _buildContentWithClickableEmails(content),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<TextSpan> _buildContentWithClickableEmails(String content) {
    final RegExp emailRegex = RegExp(r'\b[\w._%+-]+@[\w.-]+\.[a-zA-Z]{2,}\b');
    final List<TextSpan> spans = [];
    int start = 0;

    for (final match in emailRegex.allMatches(content)) {
      if (match.start > start) {
        spans.add(TextSpan(
          text: content.substring(start, match.start),
          style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black),
        ));
      }
      final email = match.group(0)!;
      spans.add(TextSpan(
        text: email,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => _launchEmail(email),
      ));
      start = match.end;
    }

    if (start < content.length) {
      spans.add(TextSpan(
        text: content.substring(start),
        style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black),
      ));
    }

    return spans;
  }
}
