import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/screens/auth/login_screen.dart';
import 'package:solar_market/utils/toas_message.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  RxBool isLoading = false.obs;
  RxBool isgogleLoading = false.obs;
  RxBool isUpdating = false.obs;
  final RxBool isAppleLoading = false.obs;
  RxBool isimageUpload = false.obs;
  RxString errorMessage = ''.obs;

  RxString userName = ''.obs;
  RxString email = ''.obs;
  RxString uniqueId = ''.obs;
  RxString tag = ''.obs;
  RxString userDescription = ''.obs;
  RxString userPhone = ''.obs;
  RxString userImage = ''.obs;
  RxString fcmToken = ''.obs;
  RxString profileStatus = ''.obs;
  RxString joiningDate = ''.obs;
  RxBool isVerified = false.obs;
  RxBool isBanned = false.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final RxBool isPhoneVerified = false.obs;
  final RxBool isGoogleVerified = false.obs;
  final RxBool isAppleVerified = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkVerificationStatus();

    fetchUserData();
  }

  final picker = ImagePicker();
  XFile? _image;
  XFile? get image => _image;

  Future<File> compressImage(File file) async {
    final img.Image? originalImage = img.decodeImage(await file.readAsBytes());
    if (originalImage == null) throw 'Error decoding image';

    final img.Image compressedImage = img.copyResize(originalImage, width: 512);

    final Directory tempDir = await getTemporaryDirectory();
    final String compressedImagePath = '${tempDir.path}/compressed_image.jpg';
    final File compressedFile = File(compressedImagePath)
      ..writeAsBytesSync(img.encodeJpg(compressedImage, quality: 70));
    return compressedFile;
  }

  Future pickGalleryImage() async {
    isimageUpload.value = true;
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      final compressedFile = await compressImage(File(_image!.path));
      await uploadUserProfilePicture(compressedFile);
    }
    isimageUpload.value = false;
  }

  Future pickCameraImage() async {
    isimageUpload.value = true;
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      final compressedFile = await compressImage(File(_image!.path));
      await uploadUserProfilePicture(compressedFile);
    }
    isimageUpload.value = false;
  }

  void pickImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: Colors.white,
          content: SizedBox(
            height: 120,
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    pickCameraImage();
                    Get.back();
                  },
                  leading: const Icon(
                    Icons.camera_alt,
                    color: kPrimaryColor,
                  ),
                  title: Text(
                    'Camera',
                    style: GoogleFonts.inter(
                        fontSize: 14.sp, fontWeight: FontWeight.w500),
                  ),
                ),
                ListTile(
                  onTap: () {
                    pickGalleryImage();
                    Get.back();
                  },
                  leading: const Icon(
                    Icons.image,
                    color: kPrimaryColor,
                  ),
                  title: Text(
                    'Gallery',
                    style: GoogleFonts.inter(
                        fontSize: 14.sp, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> uploadUserProfilePicture(File file) async {
    isimageUpload.value = true;
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage
          .ref('ProfileImages/${FirebaseAuth.instance.currentUser!.uid}');
      await ref.putFile(file.absolute);
      String imageUrl = await ref.getDownloadURL();
      await FirebaseAuth.instance.currentUser!.updatePhotoURL(imageUrl);
      await FirebaseFirestore.instance
          .collection('pmsUsers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'image': imageUrl}).then((value) {
        MessageToast.showToast(
          msg: 'Profile updated',
        );
        // Get.snackbar('Success', 'User profile updated');
        isimageUpload.value = false;
        _image = null;
      });
      userImage.value = imageUrl;
    } on FirebaseException catch (e) {
      isimageUpload.value = false;
      MessageToast.showToast(
        msg: e.message ?? 'Image upload failed',
      );
    }
  }

  void fetchUserData() async {
    try {
      isLoading.value = true;
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;
        final userDoc =
            await _firestore.collection('pmsUsers').doc(userId).get();

        if (userDoc.exists) {
          final data = userDoc.data()!;
          userName.value = data['fullName'] ?? '';
          email.value = data['email'] ?? '';
          userPhone.value = data['phoneNumber'] ?? '';
          userImage.value = data['image'] ?? '';
          userDescription.value = data['description'] ?? '';
          uniqueId.value = data['uniqueId'] ?? '';
          tag.value = data['tag'] ?? '';
          fcmToken.value = data['fcmToken'] ?? '';
          isVerified.value = data['isVerified'];
          isBanned.value = data['isBanned'];
          profileStatus.value = data['profileStatus'] ?? '';
          final Timestamp? timestamp = data['createdAt'];
          if (timestamp != null) {
            final DateTime dateTime = timestamp.toDate();
            joiningDate.value = DateFormat('dd/MM/yyyy').format(dateTime);
          } else {
            joiningDate.value = 'N/A';
          }

          nameController.text = userName.value;
          descriptionController.text = userDescription.value;
        } else {
          errorMessage.value = 'User not found.';
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to load user data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void updateUserName() async {
    try {
      isUpdating.value = true;
      final userId = FirebaseAuth.instance.currentUser!.uid;

      await _firestore.collection('pmsUsers').doc(userId).update({
        'fullName': nameController.text.trim(),
        'description': descriptionController.text.trim(),
      }).whenComplete(() {
        Get.back();
      });
      userName.value = nameController.text.trim();
      userDescription.value = descriptionController.text.trim();
      MessageToast.showToast(
        msg: 'User information updated',
      );
      // Get.back();
    } catch (e) {
      MessageToast.showToast(
        msg: e.toString(),
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> logOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _googleSignIn.signOut();

      await FirebaseMessaging.instance.deleteToken();

      Get.offAll(() => const LoginScreen());
    } catch (e) {
      Get.snackbar('Error', 'Failed to log out. Please try again.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  //  LINKING OF GOOGLE

  // Check phone and Google verification statuses
  void checkVerificationStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc =
          await _firestore.collection('pmsUsers').doc(user.uid).get();

      if (userDoc.exists) {
        isPhoneVerified.value = userDoc['isPhoneVerified'] ?? false;
        isGoogleVerified.value = userDoc['isGoogleVerified'] ?? false;
      } else {
        isPhoneVerified.value = false;
        isGoogleVerified.value = false;
      }
    }
  }

  // Function to update phone verification status
  void updatePhoneNumberInFirestore(String phoneNumber) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('pmsUsers').doc(user.uid).update({
        'phoneNumber': phoneNumber,
        'isPhoneVerified': true,
      });
      isPhoneVerified.value = true;
    }
  }

  // Function to link Google account
  Future<void> linkGoogleAccount() async {
    isgogleLoading.value = true; // Start loading

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await currentUser.linkWithCredential(credential);

        await _firestore.collection('pmsUsers').doc(currentUser.uid).update({
          'email': googleUser.email,
          // 'fullName': googleUser.displayName ?? '',
          'isGoogleVerified': true,
        });
        email.value = googleUser.email;
        // userName.value = googleUser.displayName ?? '';

        isGoogleVerified.value = true;
        Get.snackbar("Success", "Google account linked successfully!",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to link Google account.';
      if (e.code == 'credential-already-in-use') {
        errorMessage = 'This Google account is already linked to another user.';
      } else if (e.code == 'provider-already-linked') {
        errorMessage = 'Google account is already linked.';
      } else if (e.code == 'requires-recent-login') {
        errorMessage = 'Please re-authenticate and try again.';
      }
      await GoogleSignIn().signOut();

      Get.snackbar("Error", errorMessage,
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      await GoogleSignIn().signOut();

      Get.snackbar("Error", "An unexpected error occurred.",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isgogleLoading.value = false; // Stop loading after the process
    }
  }

// APPLE SECTION
  Future<void> linkAppleAccount() async {
    isAppleLoading.value = true; // Start loading

    try {
      // 1. Perform the Apple Sign-In request
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 2. Generate OAuth credentials for linking with Firebase
      final OAuthCredential credential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // 3. Link the credentials with the current Firebase user
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Link the Apple account with the current Firebase account
        await currentUser.linkWithCredential(credential);

        // Update Firestore with Apple account information
        await _firestore.collection('pmsUsers').doc(currentUser.uid).update({
          'email': appleCredential.email,
          // 'fullName': appleCredential.givenName ?? '',
          'isAppleVerified': true,
        });
        email.value = appleCredential.email??'';

        // Update the app state
        isAppleVerified.value = true;
        Get.snackbar("Success", "Apple account linked successfully!",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar("Error", "No user signed in.",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to link Apple account.';
      if (e.code == 'credential-already-in-use') {
        errorMessage = 'This Apple account is already linked to another user.';
      } else if (e.code == 'provider-already-linked') {
        errorMessage = 'Apple account is already linked.';
      } else if (e.code == 'requires-recent-login') {
        errorMessage = 'Please re-authenticate and try again.';
      }
      Get.snackbar("Error", errorMessage,
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred.",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isAppleLoading.value = false; // Stop loading after the process
    }
  }

// DELETING SECTION

  Future<void> deleteAccount() async {
    User? user = _auth.currentUser;

    if (user != null) {
      isLoading.value = true;

      try {
        // await _firestore.collection('pmsUsers').doc(user.uid).delete();
        await _firestore.collection('psmProfiles').doc(user.uid).delete();

        await deleteUserPosts();
        await deleteUserBids();
        await deleteFollowData(user.uid);
        await _deleteUserNotifications(user.uid);
       await _auth.currentUser?.delete();

        // await user.delete();

        MessageToast.showToast(msg: "Account deleted successfully.");
        isLoading.value = false;

        Get.offAll(() => const LoginScreen());
      } catch (e) {
        isLoading.value = false;

        if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
          MessageToast.showToast(
              msg: "Please re-authenticate to delete your account.");
          logOut();
        } else {
          MessageToast.showToast(
              msg: "An error occurred while deleting your account.");
        }
      }
    } else {
      MessageToast.showToast(msg: "No user found. Please log in again.");
    }
  }

  Future<void> deleteUserPosts() async {
    try {
      await _deletePosts('userPanels');
      await _deletePosts('userInverters');
      await _deletePosts('userLithium');

      MessageToast.showToast(msg: "All user posts deleted successfully.");
    } catch (e) {
      MessageToast.showToast(msg: "Error deleting user posts: $e");
    }
  }

  Future<void> _deletePosts(String collection) async {
    QuerySnapshot snapshot = await _firestore
        .collection('psmPosts')
        .doc(userPhone.value)
        .collection(collection)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> deleteUserBids() async {
    isLoading.value = true;

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print('No user is currently signed in.');
        MessageToast.showToast(msg: 'No user is currently signed in.');
        return;
      }

      final userBidsSnapshot = await _firestore
          .collection('psmBids')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      for (var doc in userBidsSnapshot.docs) {
        await doc.reference.delete();
      }

      print('All bids by the user have been deleted successfully.');
    } catch (e) {
      print('Error deleting user bids: $e');
      MessageToast.showToast(msg: 'Error deleting bids. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteFollowData(String userId) async {
    try {
      print('Deleting follow data for user: $userId');

      DocumentSnapshot userSnapshot =
          await _firestore.collection('pmsUsers').doc(userId).get();

      if (!userSnapshot.exists) {
        print('User document does not exist for userId: $userId');
        return;
      }

      List<dynamic> following = List.from(userSnapshot['following'] ?? []);
      List<dynamic> followers = List.from(userSnapshot['followers'] ?? []);

      // Remove user from other users' followers lists before deleting user data
      for (String followingUserId in following) {
        DocumentSnapshot followingUserSnapshot =
            await _firestore.collection('pmsUsers').doc(followingUserId).get();

        if (followingUserSnapshot.exists) {
          List<dynamic> followersList =
              List.from(followingUserSnapshot['followers'] ?? []);

          // Remove the object where userId matches
          followersList.removeWhere((follower) =>
              follower is Map<String, dynamic> && follower['userId'] == userId);

          await _firestore.collection('pmsUsers').doc(followingUserId).update({
            'followers': followersList,
            'followersCount': FieldValue.increment(-1),
          });
        }
      }

      // Remove user from other users' following lists
      for (var follower in followers) {
        String followerUserId = follower['userId'];

        DocumentSnapshot followerSnapshot =
            await _firestore.collection('pmsUsers').doc(followerUserId).get();

        if (followerSnapshot.exists) {
          List<dynamic> followingList =
              List.from(followerSnapshot['following'] ?? []);

          followingList.remove(userId);

          await _firestore.collection('pmsUsers').doc(followerUserId).update({
            'following': followingList,
            'followingCount': FieldValue.increment(-1),
          });
        }
      }

      // Delete the user document AFTER updating all other users
      await _firestore.collection('pmsUsers').doc(userId).delete();
      print('User document deleted successfully');

      // Delete from Firebase Authentication
      await _auth.currentUser?.delete();
      print('User deleted from Firebase Authentication');

      print('Follow data deleted successfully');
    } catch (e) {
      print('Error in deleteFollowData: $e');
    }
  }

  // Helper function to delete all notifications associated with the user
  Future<void> _deleteUserNotifications(String userId) async {
    try {
      // Delete notifications where the user is the sender (currentUserId)
      QuerySnapshot senderNotifications = await _firestore
          .collection('psmNotifications')
          .where('currentUserId', isEqualTo: userId)
          .get();

      for (var doc in senderNotifications.docs) {
        await doc.reference.delete();
      }

      // Delete notifications where the user is the receiver (toSenderId)
      QuerySnapshot receiverNotifications = await _firestore
          .collection('psmNotifications')
          .where('toSenderId', isEqualTo: userId)
          .get();

      for (var doc in receiverNotifications.docs) {
        await doc.reference.delete();
      }

      if (kDebugMode) {
        print('All notifications for user $userId deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting notifications: $e');
      }
    }
  }
}
