import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/controllers/bidding_controller.dart';
import 'package:solar_market/controllers/contact_cntroller/contact_us_controller.dart';
import 'package:solar_market/controllers/profile/profile_controller.dart';
import 'package:solar_market/screens/dashboard/add_items/components/dropdown.dart';
import 'package:solar_market/widgets/round_button.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  ProfileController profileController = Get.put(ProfileController());
  BiddingController biddingController = Get.put(BiddingController());
  ContactUsController contactUsController = Get.put(ContactUsController());

  @override
  void initState() {
    super.initState();
    print("Unique ID: ${profileController.uniqueId.value}"); // Debugging
    contactUsController.nameController.text = profileController.userName.value;
    contactUsController.phoneController.text =
        profileController.userPhone.value;
  }

  Future<Map<String, dynamic>?> fetchAdminDetails() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('adminDetail')
          .doc(
              '1ROrGLxapOhGfuCip6A6') // Replace 'adminId' with your admin document ID
          .get();

      if (snapshot.exists) {
        return snapshot.data();
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching admin details: $e");
      return null;
    }
  }

  // Function to launch an email
  Future<void> launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    // if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
    // } else {
    //   debugPrint('Could not launch email.');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Contact Us',
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
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      profileController.isBanned.value
                          ? Center(
                              child: Column(children: [
                                Icon(Icons.block,
                                    color: Colors.red, size: 66.sp),
                                SizedBox(height: 20.h),
                                Text(
                                  'You are banned from using this app. Please contact to customer service',
                                  style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 44,
                                ),
                              ]),
                            )
                          : SizedBox.shrink(),

                      Dropdown.buildTextField(
                          controller: contactUsController.nameController,
                          label: 'Name',
                          hint: 'Enter your Name'),
                      SizedBox(height: 10),
                      // Dropdown.buildTextField(
                      //     controller: _emailController,
                      //     label: 'Email',
                      //     hint: 'Enter your email'),
                      // SizedBox(height: 10),
                      Dropdown.buildTextField(
                          controller: contactUsController.phoneController,
                          label: 'Phone Number',
                          fielType: TextInputType.number,
                          hint: 'Enter your phone number'),
                      SizedBox(height: 10),
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
                          Obx(
                            () => TextFormField(
                              initialValue: profileController.uniqueId.value,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: 'Your Id',
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
                                    borderSide:
                                        BorderSide(color: Colors.black26)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.black38)),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10),
                      Obx(
              () =>  Dropdown.buildDropdownFieldAlt(
                label: "Select Subject",
                hint: "Choose a subject",
                value: contactUsController.selectedSubject.value.isEmpty
                    ? null
                    : contactUsController.selectedSubject.value,
                items: contactUsController.subjects,
                onChanged: (value) {
                  contactUsController.selectedSubject.value = value!;
                },
              ),
            ),

                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller:
                                contactUsController.descriptionController,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Enter description',
                              hintStyle: GoogleFonts.inter(
                                color: Color(0xFF626262),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide:
                                      BorderSide(color: Colors.black26)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide:
                                      BorderSide(color: Colors.black38)),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Obx(
                          () => contactUsController.isLoading.value
                              ? Center(
                                  child: CircularProgressIndicator(
                                  color: kPrimaryColor,
                                ))
                              : RoundButton(
                                  onPressed: () {
                                    contactUsController
                                        .submitForm(context);
                                        
                                  },
                                  text: 'Submit',
                                ),
                        ),
                      ),

                      FutureBuilder<Map<String, dynamic>?>(
                        future: fetchAdminDetails(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: Padding(
                              padding: EdgeInsets.only(top: 44.h),
                              child: CircularProgressIndicator(
                                color: kPrimaryColor,
                              ),
                            ));
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text(
                              'Error loading admin details.',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: Colors.red,
                              ),
                            ));
                          } else if (!snapshot.hasData ||
                              snapshot.data == null) {
                            return Center(
                                child: Text(
                              'Admin details not found.',
                              style: GoogleFonts.inter(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: kPrimaryColor,
                              ),
                            ));
                          }

                          final adminData = snapshot.data!;
                          final email =
                              adminData['email'] ?? 'No email provided';
                          final phone = adminData['phoneNumber'] ??
                              'No phone number provided';

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 28.h),
                              Text(
                                'Contact:',
                                style: GoogleFonts.inter(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 20.h),
                              InkWell(
                                onTap: () {
                                  if (email != 'No email provided') {
                                    launchEmail(email);
                                  }
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.email, color: kPrimaryColor),
                                    SizedBox(
                                      width: 13.sp,
                                    ),
                                    Text(
                                      email,
                                      style: GoogleFonts.inter(
                                          fontSize: 15.sp,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 18.h,
                              ),
                              InkWell(
                                onTap: () {
                                  if (phone != 'No phone number provided') {
                                    biddingController.makeCall(phone);
                                    // launchPhone(phone);
                                  }
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.phone, color: kPrimaryColor),
                                    SizedBox(
                                      width: 13.sp,
                                    ),
                                    Text(
                                      phone,
                                      style: GoogleFonts.inter(
                                          fontSize: 15.sp,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 22,
                              )
                            ],
                          );
                        },
                      ),
                    ]))));
  }
}
