import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_market/controllers/profile/profile_controller.dart';
import 'package:solar_market/utils/auth_gate.dart';
import 'package:solar_market/utils/toas_message.dart';

import '../notifications.dart';

class ContactUsController extends GetxController {
  RxBool isLoading = false.obs;
  RxString selectedSubject = ''.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  ProfileController profileController = Get.put(ProfileController());

  final List<String> subjects = [
    'Technical Support',
    'Message',
    'Complaint',
    'Advice',
  ];

  Future<Map<String, dynamic>?> fetchAdminDetails() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('adminDetail')
          .doc('1ROrGLxapOhGfuCip6A6')
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

  bool validateFields(BuildContext context) {
    if (nameController.text.trim().isEmpty) {
      MessageToast.showToast(msg: 'Please enter your name.');
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      MessageToast.showToast(msg: 'Please enter your phone number.');
      return false;
    }
    if (selectedSubject.value.isEmpty) {
      MessageToast.showToast(msg: 'Please select a subject.');
      return false;
    }
    if (descriptionController.text.trim().isEmpty) {
      MessageToast.showToast(msg: 'Please enter a description.');
      return false;
    }
    return true;
  }

  // Submit form
  Future<void> submitForm(BuildContext context) async {
    if (!validateFields(context)) return;

    isLoading.value = true;

    try {
      await FirebaseFirestore.instance
          .collection('contact_us')
          .doc(DateTime.now().toString())
          .set({
        'name': nameController.text.trim(),
        'read': false,
        'id': DateTime.now().toString(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'uniqueId': profileController.uniqueId.value,
        'subject': selectedSubject.value,
        'description': descriptionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      }).whenComplete(() {
        if (profileController.isBanned.value) {
          Get.to(() => RequestReceivedScreen());
        } else {
          Get.back();
        }
      });
      final adminSnapshot = await FirebaseFirestore.instance
          .collection('adminDetail')
          .doc('9jQGdhx4zQfEgWfmLjHHlx6Xq0r2')
          .get();

      if (adminSnapshot.exists) {
        String? fcmToken = adminSnapshot.data()?['fcmToken'];

        if (fcmToken != null && fcmToken.isNotEmpty) {
          LocalNotificationService.sendNotificationUsingApi(
            token: fcmToken,
            title: 'Contact us request!',
            body: '${profileController.userName.value} sent a Contact us request',
            data: {},
          );
        } else {
          MessageToast.showToast(msg: 'Admin FCM token not found.');
        }
      } else {
        MessageToast.showToast(msg: 'Admin details not found.');
      }
      if (profileController.isBanned.value) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('contactSubmitted', true);
      }

      MessageToast.showToast(msg: 'Message sent successfully!');
    } catch (e) {
      MessageToast.showToast(msg: 'Failed to submit form. Try again.');
    } finally {
      isLoading.value = false;
    }
  }
}
