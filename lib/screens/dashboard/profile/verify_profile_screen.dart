import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/controllers/profile/verify_profile_controller.dart';
import 'package:solar_market/screens/dashboard/add_items/components/dropdown.dart';
import 'package:solar_market/widgets/round_button.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class VerifyProfileScreen extends StatefulWidget {
  final String profileStatus;
  const VerifyProfileScreen({Key? key, required this.profileStatus})
      : super(key: key);

  @override
  State<VerifyProfileScreen> createState() => _VerifyProfileScreenState();
}

class _VerifyProfileScreenState extends State<VerifyProfileScreen> {
  Future<Map<String, dynamic>> fetchProfileDetails() async {
    final doc = await FirebaseFirestore.instance
        .collection('psmProfiles')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    return doc.data() ?? {};
  }

  final ScreenshotController screenshotController = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<VerifyProfileController>(
      init: VerifyProfileController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: widget.profileStatus == 'verified'
              ? Colors.grey.shade200
              : Colors.white,
          appBar: AppBar(
            centerTitle: true,
            // elevation: 1,
            title: Text(
              widget.profileStatus == 'pending'
                  ? 'Verification Status Pending'
                  : widget.profileStatus == 'verified'
                      ? 'PSM Card'
                      : 'Verify Now',
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: widget.profileStatus == 'verified'
                ? Colors.grey.shade200
                : Colors.white,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.profileStatus == 'pending') _buildPendingStatus(),
                if (widget.profileStatus == 'verified') _buildVerifiedStatus(),
                if (widget.profileStatus == 'rejected')
                  _buildRejectedStatus(
                    _buildVerifyForm(controller, context),
                  ),
                if (widget.profileStatus != 'verified' &&
                    widget.profileStatus != 'rejected' &&
                    widget.profileStatus != 'pending')
                  _buildVerifyForm(controller, context)
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerifyForm(
      VerifyProfileController controller, BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Center(
            //     child: Image.asset(
            //   'assets/images/logo.png',
            //   height: 78.h,
            // )),
            SizedBox(height: 10.h),
            // Form Fields
            Dropdown.buildTextField(
              label: 'Company Name',
              hint: 'Enter company name',
              controller: controller.compNameController,
            ),
            SizedBox(height: 10.h),
            Dropdown.buildTextField(
              label: 'Company NTN/INC',
              hint: 'Enter company NTN/INC',
              controller: controller.compTnsController,
            ),
            SizedBox(height: 10.h),
            Dropdown.buildTextField(
              label: 'Company Location',
              hint: 'Enter company location',
              controller: controller.compLocationController,
            ),
            SizedBox(height: 10.h),
            Dropdown.buildTextField(
              label: 'Address',
              hint: 'Enter your address',
              controller: controller.addressController,
            ),
            SizedBox(height: 10.h),
            Dropdown.buildTextField(
              label: 'Designation',
              hint: 'Enter designation',
              controller: controller.designationController,
            ),
            SizedBox(height: 10.h),
            Dropdown.buildTextField(
              label: 'Owner Name',
              hint: 'Enter owner name',
              controller: controller.ownerNameController,
            ),
            SizedBox(height: 10.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Id',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                    controller: controller.uniqueIdController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.inter(
                      // color: Color(0xFF626262),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Enter token money',
                      hintStyle: GoogleFonts.inter(
                        color: Color(0xFF626262),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.black26)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.black38)),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    )),
              ],
            ),
            // Dropdown.buildTextField(
            //   label: 'User ID',
            //   hint: 'Enter user ID',
            //   controller: controller.uniqueIdController,
            // ),
            SizedBox(height: 28.h),

            Center(
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      _showImageSourceActionSheet(context, controller, 'user');
                    },
                    child: Container(
                      width: 199.h,
                      height: 118.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.r),
                        image: controller.userImage.value != null
                            ? DecorationImage(
                                image: FileImage(controller.userImage.value!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: controller.userImage.value == null
                          ? Icon(Icons.camera_alt,
                              size: 30.sp, color: Colors.grey[700])
                          : null,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Company Logo',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // SizedBox(height: 10.h),
            Dropdown.buildTextField(
              label: 'Bank Name',
              hint: 'Enter bank name',
              controller: controller.bankNameController,
            ),
            SizedBox(height: 10.h),
            Dropdown.buildTextField(
              label: 'Account Number',
              hint: 'Enter account number',
              fielType: TextInputType.number,
              controller: controller.accountNumberController,
            ),
            SizedBox(height: 10.h),
            Dropdown.buildTextField(
              label: 'IBAN',
              hint: 'Enter IBAN',
              controller: controller.ibanController,
            ),
            SizedBox(height: 28.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // CNIC Front
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _showImageSourceActionSheet(
                          context, controller, 'cnic_front');
                    },
                    child: Column(
                      children: [
                        Container(
                          height: 111.h,
                          width: 166.w,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8.r),
                            image: controller.cnicFrontImage.value != null
                                ? DecorationImage(
                                    image: FileImage(
                                        controller.cnicFrontImage.value!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: controller.cnicFrontImage.value == null
                              ? Icon(Icons.camera_alt,
                                  size: 30.sp, color: Colors.grey[700])
                              : null,
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          'CNIC Front',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                // CNIC Back
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _showImageSourceActionSheet(
                          context, controller, 'cnic_back');
                    },
                    child: Column(
                      children: [
                        Container(
                          height: 111.h,
                          width: 166.w,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8.r),
                            image: controller.cnicBackImage.value != null
                                ? DecorationImage(
                                    image: FileImage(
                                        controller.cnicBackImage.value!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: controller.cnicBackImage.value == null
                              ? Icon(Icons.camera_alt,
                                  size: 30.sp, color: Colors.grey[700])
                              : null,
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          'CNIC Back',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 22.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PAKISTAN SOLAR MARKET',
                  style: GoogleFonts.inter(
                      fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Meeza Bank - MOULANA SHOUKAT ALI LHR',
                  style: GoogleFonts.inter(
                      fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Account Number : 11340109444369',
                  style: GoogleFonts.inter(
                      fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                Text(
                  'IBAN : PK16MEZN0011340109444369',
                  style: GoogleFonts.inter(
                      fontSize: 14.sp, fontWeight: FontWeight.w600),
                )
              ],
            ),
            SizedBox(
              height: 22,
            ),

            Dropdown.buildTextField(
              label: 'TID',
              hint: 'Enter TID',
              controller: controller.tidController,
            ),
            SizedBox(
              height: 14,
            ),

            InkWell(
              onTap: () {
                _showImageSourceActionSheet(context, controller, 'bank_slip');
              },
              child: Container(
                width: Get.size.width.w,
                height: 134.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8.r),
                  image: controller.bankSlipImage.value != null
                      ? DecorationImage(
                          image: FileImage(controller.bankSlipImage.value!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: controller.bankSlipImage.value == null
                    ? Icon(Icons.camera_alt,
                        size: 30.sp, color: Colors.grey[700])
                    : null,
              ),
            ),

            SizedBox(height: 10.h),
            Text(
              'Bank Deposit Slip(20000 Rs.) Image',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 20.h),

            Center(
              child: Obx(
                () => controller.isLoading.value
                    ? CircularProgressIndicator(
                        color: kPrimaryColor,
                      )
                    : RoundButton(
                        onPressed: () {
                          controller.submitProfile();
                        },
                        text: 'Submit'),
              ),
            ),
            // Submit Button

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _showImageSourceActionSheet(
      BuildContext context, VerifyProfileController controller, String type) {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: kPrimaryColor,
              ),
              title: Text(
                'Gallery',
                style: GoogleFonts.inter(fontSize: 14.sp, color: kPrimaryColor),
              ),
              onTap: () {
                controller.pickImage(ImageSource.gallery, type);
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_camera,
                color: kPrimaryColor,
              ),
              title: Text(
                'Camera',
                style: GoogleFonts.inter(fontSize: 14.sp, color: kPrimaryColor),
              ),
              onTap: () {
                controller.pickImage(ImageSource.camera, type);
                Get.back();
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildPendingStatus() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 188.h,
          ),
          Icon(
            Icons.account_circle,
            size: 150.sp,
            color: kPrimaryColor,
          ),

          SizedBox(height: 20.h),
          // Status Text
          Text(
            'Your profile verification is pending...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6.h),
          // Instruction Text
          Text(
            'Please wait while we review your details.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedStatus() {
    return Padding(
      padding: EdgeInsets.all(1.sp),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 34.h,
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: fetchProfileDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: kPrimaryColor,
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text("Profile not found"));
              }

              final profileData = snapshot.data!;
              final companyLogo = profileData['userImageUrl'] ?? '';
              final companyName =
                  (profileData['companyName'] ?? 'N/A').toUpperCase();
              final ntn = (profileData['companyTNS'] ?? 'N/A').toUpperCase();
              final address = (profileData['address'] ?? 'N/A').toUpperCase();
              final uniqueId = (profileData['uniqueId'] ?? 'N/A').toUpperCase();
              final designation =
                  (profileData['designation'] ?? 'N/A').toUpperCase();
              final ownerName =
                  (profileData['ownerName'] ?? 'N/A').toUpperCase();
              final phoneNumber =
                  (profileData['userNumber'] ?? 'N/A').toUpperCase();

              return Column(
                children: [
                  SingleChildScrollView(
                    child: Screenshot(
                        controller: screenshotController,
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 2.h),
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                        
                                          Text(
                                            "MEMBERSHIP CARD",
                                            style: GoogleFonts.kameron(
                                              fontSize: 16.sp,
                                              color:
                                                  kPrimaryColor, // Apply kPrimaryColor to the header text
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(width: 8.w),
                                          Container(
                                            height: 50.h,
                                            width: 50.h,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                                border: Border.all(
                                                    color: Colors.black12)),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                              child: Image.asset(
                                                  'assets/images/appLogo.png'),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8.h,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Stack(
                                            children: [
                                              Container(
                                                height: 55.h,
                                                width: 55.h,
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade100,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Colors.black12),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          222.r),
                                                  child: companyLogo.isEmpty
                                                      ? const Icon(Icons.person,
                                                          size: 38)
                                                      : Image.network(
                                                          companyLogo,
                                                          fit: BoxFit.cover,
                                                          loadingBuilder:
                                                              (context, child,
                                                                  progress) {
                                                            if (progress ==
                                                                null)
                                                              return child;
                                                            return const Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            );
                                                          },
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return const Icon(
                                                                Icons.error);
                                                          },
                                                        ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 2.h,
                                                right: 2.w,
                                                child: Icon(
                                                  Icons.verified,
                                                  color: Colors.blue.shade600,
                                                  size: 18.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: 12.h),
                                          Expanded(
                                            child: Text(
                                              ownerName,
                                              style: GoogleFonts.kameron(
                                                color:
                                                    kPrimaryColor, // Apply kPrimaryColor to owner name
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 22.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            singleItemRow(Icons.window, companyName),
                                                SizedBox(height: 10.h),
                                                                          // Use the new function here
                                                                          singleItemRow(
                                        Icons.confirmation_num_outlined, ntn),
                                                                          SizedBox(height: 10.h),
                                                                          singleItemRow(Icons.work, designation),
                                                                          SizedBox(height: 10.h),
                                                                          // Use the new function here
                                                                          singleItemRow(Icons.location_pin, address),
                                                                          SizedBox(height: 10.h),
                                                                          Row(
                                                                            children: [
                                        Icon(Icons.call,
                                            size: 19, color: kPrimaryColor),
                                        SizedBox(width: 3),
                                        Flexible(
                                          child: Text(
                                            phoneNumber,
                                            style: GoogleFonts.kameron(
                                              color:
                                                  kPrimaryColor, // Apply kPrimaryColor to phone number
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                                                            ],
                                                                          ),
                                          ],
                                        ),
                                      ),
                                        Column(
                                            children: [
                                              Container(
                                                height: 50.h,
                                                width: 50.h,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: kPrimaryColor,
                                                      width: 0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.r),
                                                ),
                                                child: QrImageView(
                                                  data: uniqueId,
                                                  version: QrVersions.auto,
                                                  size: 48.sp,
                                                  foregroundColor:
                                                      kPrimaryColor,
                                                ),
                                              ),
                                              Text(
                                                uniqueId,
                                                style: GoogleFonts.kameron(
                                                  color:
                                                      kPrimaryColor, // Apply kPrimaryColor to owner name
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: 8.w),
                                    ],
                                  ),
                              
                                ],
                              ),
                            ),
                          ],
                        )),
                  ),
                  Container(
                    margin: EdgeInsets.all(14.r),
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Terms & Conditions',
                          style: GoogleFonts.kameron(
                            fontSize: 16.sp, // Use responsive font size
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10.h), // Responsive height
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• Points gathered in this card are non-transferable',
                                style: GoogleFonts.kameron(
                                  fontSize: 12.sp, // Responsive font size
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '• Points are valid only until date of expiry',
                                style: GoogleFonts.kameron(
                                  fontSize: 12.sp, // Responsive font size
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '• Points may only be used to claim exclusive perks',
                                style: GoogleFonts.kameron(
                                  fontSize: 12.sp, // Responsive font size
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '   and rewards from Memento Hospitality Group',
                                style: GoogleFonts.kameron(
                                  fontSize: 12.sp, // Responsive font size
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h), // Responsive height

                        // Member Signature Section
                        Row(
                          children: [
                            Text(
                              'Member Signature: ',
                              style: GoogleFonts.kameron(
                                fontSize: 15.sp, // Responsive font size
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1.h, // Responsive height
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h), // Responsive height

                        // Footer Section
                        Text(
                          'For inquiries on PSM\'s VIP program,\ncall +92 311 4376818',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.kameron(
                            fontSize: 12.sp, // Responsive font size
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final image = await screenshotController.capture();
                      if (image != null) {
                        final tempDir = await getTemporaryDirectory();
                        final imagePath = '${tempDir.path}/membership_card.png';
                        final file = File(imagePath);
                        await file.writeAsBytes(image);
                        XFile imageFile = XFile(imagePath);
                        Share.shareXFiles(
                          [imageFile],
                          text:
                              'Check out my membership card! Link: https://surl.li/iwpjzw',
                        );
                      }
                    },
                    icon: Icon(
                      Icons.share,
                      size: 20,
                      color: Colors.white,
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor),
                    label: Text(
                      'Share Card',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildRejectedStatus(Widget form) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.cancel_outlined,
                  size: 100.sp,
                  color: kPrimaryColor,
                ),
                SizedBox(height: 20.h),
                Text(
                  "Verification Failed",
                  style: GoogleFonts.inter(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Unfortunately, your profile verification was rejected.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(
                  height: 18.h,
                ),
              ],
            ),
          ),
          form
        ],
      ),
    );
  }
}

Widget singleItemRow(IconData icon, String text) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: kPrimaryColor, size: 20.sp),
      SizedBox(width: 4.w),
      Expanded(
        child: Text(
          text,
          style: GoogleFonts.kameron(
            color: kPrimaryColor, // Set text to kPrimaryColor
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
