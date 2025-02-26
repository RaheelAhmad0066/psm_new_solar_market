// lib/controllers/profile_controller.dart

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:solar_market/controllers/notifications.dart';
import 'package:solar_market/controllers/profile/profile_controller.dart';
import 'package:solar_market/screens/dashboard/dashboard_screen.dart';
import 'package:solar_market/utils/toas_message.dart';

class VerifyProfileController extends GetxController {
  //
  final TextEditingController compNameController = TextEditingController();
  final TextEditingController compTnsController = TextEditingController();
  final TextEditingController compLocationController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController designationController = TextEditingController();

  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController ibanController = TextEditingController();
  final TextEditingController tidController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController uniqueIdController = TextEditingController();
  ProfileController profileController = Get.put(ProfileController());
  var userImage = Rx<File?>(null);
  var cnicFrontImage = Rx<File?>(null);
  var cnicBackImage = Rx<File?>(null);
  var bankSlipImage = Rx<File?>(null);

  var isLoading = false.obs;

  var uniqueId = ''.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();

    uniqueId.value = profileController.uniqueId.value;
    uniqueIdController.text = uniqueId.value;
  }

  Future<void> pickImage(ImageSource source, String type) async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: source, imageQuality: 50);
      if (pickedFile != null) {
        File file = File(pickedFile.path);
        if (type == 'user') {
          userImage.value = file;
        } else if (type == 'cnic_front') {
          cnicFrontImage.value = file;
        } else if (type == 'cnic_back') {
          cnicBackImage.value = file;
        } else if (type == 'bank_slip') {
          bankSlipImage.value = file;
        }
      }
      update();
    } catch (e) {
      MessageToast.showToast(msg: 'Error picking image: $e');
    }
  }

  Future<String?> uploadImage(File file, String path) async {
    try {
      Reference ref = FirebaseStorage.instance.ref().child(path);
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      MessageToast.showToast(msg: 'Error uploading image: $e');
      return null;
    }
  }

  Future<void> submitProfile() async {
    if (compNameController.text.trim().isEmpty) {
      MessageToast.showToast(msg: 'Company Name is required');
      return;
    }
    if (compTnsController.text.trim().isEmpty) {
      MessageToast.showToast(msg: 'Company NTN/INC is required');
      return;
    }
    if (compLocationController.text.trim().isEmpty) {
      MessageToast.showToast(msg: 'Company Location is required');
      return;
    }
    if (addressController.text.trim().isEmpty) {
      MessageToast.showToast(msg: 'Address is required');
      return;
    }
    if (designationController.text.trim().isEmpty) {
      MessageToast.showToast(msg: 'Designation is required');
      return;
    }
    if (ownerNameController.text.trim().isEmpty) {
      MessageToast.showToast(msg: 'Owner Name is required');
      return;
    }
    //
    if (bankNameController.text.trim().isEmpty) {
      MessageToast.showToast(msg: 'Bank Name is required');
      return;
    }
    if (accountNumberController.text.trim().isEmpty) {
      MessageToast.showToast(msg: 'Account number is required');
      return;
    }
    if (ibanController.text.trim().isEmpty) {
      MessageToast.showToast(msg: 'IBAN is required');
      return;
    }
    if (tidController.text.trim().isEmpty) {
      MessageToast.showToast(msg: 'TID is required');
      return;
    }
    //
    if (uniqueIdController.text.trim().isEmpty) {
      MessageToast.showToast(msg: 'User ID is required');
      return;
    }

    if (userImage.value == null) {
      MessageToast.showToast(msg: 'User image is required');
      return;
    }
    if (cnicFrontImage.value == null) {
      MessageToast.showToast(msg: 'CNIC front image is required');
      return;
    }
    if (cnicBackImage.value == null) {
      MessageToast.showToast(msg: 'CNIC back image is required');
      return;
    }

    isLoading.value = true;

    try {
      String userImageUrl = await uploadImage(
              userImage.value!, 'user_images/${uniqueId.value}.jpg') ??
          '';
      String cnicFrontUrl = await uploadImage(cnicFrontImage.value!,
              'cnic_images/front_${uniqueId.value}.jpg') ??
          '';
      String cnicBackUrl = await uploadImage(
              cnicBackImage.value!, 'cnic_images/back_${uniqueId.value}.jpg') ??
          '';
      String bankDepositSlip = await uploadImage(
              bankSlipImage.value!, 'bank_slip${uniqueId.value}.jpg') ??
          '';

      if (userImageUrl.isEmpty ||
          cnicFrontUrl.isEmpty ||
          cnicBackUrl.isEmpty ||
          bankDepositSlip.isEmpty) {
        MessageToast.showToast(msg: 'Failed to upload images');
        isLoading.value = false;
        return;
      }

      Map<String, dynamic> data = {
        'companyName': compNameController.text.trim(),
        'companyTNS': compTnsController.text.trim(),
        'companyLocation': compLocationController.text.trim(),
        'address': addressController.text.trim(),
        'designation': designationController.text.trim(),
        'ownerName': ownerNameController.text.trim(),
        'bankName': bankNameController.text.trim(),
        'iban': ibanController.text.trim(),
        'accountNumber': accountNumberController.text.trim(),
        'tid': tidController.text.trim(),
        'bankSlip': bankDepositSlip,
        'uniqueId': uniqueId.value,
        'userNumber': profileController.userPhone.value,
        'userImageUrl': userImageUrl,
        'cnicFrontUrl': cnicFrontUrl,
        'isVerified': false,
        'cnicBackUrl': cnicBackUrl,
        'timestamp': FieldValue.serverTimestamp(),
      };
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('psmProfiles')
          .doc(userId)
          .set(data);

      await FirebaseFirestore.instance
          .collection('pmsUsers')
          .doc(userId)
          .update({
        'profileStatus': 'pending',
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
            title: 'Verification Request!',
            body:
                '${profileController.userName.value} Requested for profile verification',
            data: {},
          );
        } else {
          MessageToast.showToast(msg: 'Admin FCM token not found.');
        }
      } else {
        MessageToast.showToast(msg: 'Admin details not found.');
      }
      MessageToast.showToast(msg: 'Your Information Submitted Successfully');
      Get.offAll(() => Dashboard());

      // clearFields();
    } catch (e) {
      MessageToast.showToast(msg: 'Error submitting profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clearFields() {
    compNameController.clear();
    compTnsController.clear();
    compLocationController.clear();
    addressController.clear();
    designationController.clear();
    ownerNameController.clear();
    userImage.value = null;
    cnicFrontImage.value = null;
    cnicBackImage.value = null;
  }

  @override
  void onClose() {
    compNameController.dispose();
    compTnsController.dispose();
    compLocationController.dispose();
    addressController.dispose();
    designationController.dispose();
    ownerNameController.dispose();
    uniqueIdController.dispose();
    super.onClose();
  }
}
