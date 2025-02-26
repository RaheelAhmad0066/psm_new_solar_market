import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:solar_market/utils/toas_message.dart';

class MyPostsController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var activePosts = <Map<String, dynamic>>[].obs;
  var oldPosts = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  Future<void> fetchUserPosts(String userPhoneNumber, String postType) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      QuerySnapshot snapshot = await firestore
          .collection('psmPosts')
          .doc(userPhoneNumber)
          .collection(postType)
          .get();

      // Filter posts into active and old
      activePosts.value = snapshot.docs
          .where((doc) =>
              (doc.data() as Map<String, dynamic>)['isShowing'] == true)
          .map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['itemId'] = doc.id;
        return data;
      }).toList();

      oldPosts.value = snapshot.docs
          .where((doc) =>
              (doc.data() as Map<String, dynamic>)['isShowing'] == false)
          .map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['itemId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      errorMessage.value = "Error fetching posts: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editPost(String userPhoneNumber, String postId,
      Map<String, dynamic> updatedData, String postType) async {
    try {
      // updatedData['createdAt'] = DateTime.now(); // Update the createdAt timestamp
      await firestore
          .collection('psmPosts')
          .doc(userPhoneNumber)
          .collection(postType)
          .doc(postId)
          .update(updatedData);
      MessageToast.showToast(msg: 'Post updated successfully!');
      fetchUserPosts(userPhoneNumber, postType);
    } catch (e) {
      MessageToast.showToast(msg: 'Error updating post: $e');
    }
  }

  Future<void> repostPost(String userPhoneNumber, Map<String, dynamic> postData,
      String postType) async {
    try {
      if (postData['isShowing'] == true) {
        MessageToast.showToast(msg: 'Active posts cannot be reposted.');
        return;
      }
      final user = FirebaseAuth.instance.currentUser;

      var userDoc = await firestore.collection('pmsUsers').doc(user!.uid).get();
      if (!userDoc.exists) {
        MessageToast.showToast(msg: 'User not found.');
        return;
      }

      var userData = userDoc.data();
      bool isVerified = userData?['isVerified'] ?? false;

      if (!isVerified) {
        DateTime today = DateTime.now();
        DateTime todayStart = DateTime(today.year, today.month, today.day);

        var repostsQuery = await firestore
            .collection('psmPosts')
            .doc(userPhoneNumber)
            .collection(postType)
            .where('createdAt', isGreaterThanOrEqualTo: todayStart)
            .get();

        if (repostsQuery.docs.length >= 5) {
          MessageToast.showToast(
              msg: 'Unverified users can only repost up to 5 posts per day.');
          return;
        }
      }

      var repostedPost = {
        ...postData,
        'createdAt': DateTime.now(),
        'itemId': DateTime.now().toString(),
        'isShowing': true,
      };

      await firestore
          .collection('psmPosts')
          .doc(userPhoneNumber)
          .collection(postType)
          .doc(DateTime.now().toString())
          .set(repostedPost);

      await firestore
          .collection('psmPosts')
          .doc(userPhoneNumber)
          .collection(postType)
          .doc(postData['itemId'])
          .delete();

      MessageToast.showToast(msg: 'Post reposted successfully!');
      fetchUserPosts(userPhoneNumber, postType);
    } catch (e) {
      MessageToast.showToast(msg: 'Error reposting post: $e');
    }
  }

  Future<void> deletePost(
      String userPhoneNumber, String postId, String postType) async {
    try {
      await firestore
          .collection('psmPosts')
          .doc(userPhoneNumber)
          .collection(postType)
          .doc(postId)
          .delete();
      MessageToast.showToast(msg: 'Post deleted successfully!');
      fetchUserPosts(userPhoneNumber, postType);
    } catch (e) {
      MessageToast.showToast(msg: 'Error deleting post: $e');
    }
  }

  Future<void> updaetToSold(String userPhoneNumber, String postId,
      Map<String, dynamic> updatedData, String postType) async {
    try {
      // updatedData['createdAt'] = DateTime.now(); // Update the createdAt timestamp
      await firestore
          .collection('psmPosts')
          .doc(userPhoneNumber)
          .collection(postType)
          .doc(postId)
          .update(updatedData);
      MessageToast.showToast(msg: 'Post updated to Sold!');
      fetchUserPosts(userPhoneNumber, postType);
    } catch (e) {
      MessageToast.showToast(msg: 'Error updating post: $e');
    }
  }

  Future<void> updaetToUnSold(String userPhoneNumber, String postId,
      Map<String, dynamic> updatedData, String postType) async {
    try {
      // updatedData['createdAt'] = DateTime.now(); // Update the createdAt timestamp
      await firestore
          .collection('psmPosts')
          .doc(userPhoneNumber)
          .collection(postType)
          .doc(postId)
          .update(updatedData);
      MessageToast.showToast(msg: 'Post updated to UnSold!');
      fetchUserPosts(userPhoneNumber, postType);
    } catch (e) {
      MessageToast.showToast(msg: 'Error updating post: $e');
    }
  }

  Future<void> updaetToBought(
      String userPhoneNumber, String postId, String postType) async {
    try {
      await firestore
          .collection('psmPosts')
          .doc(userPhoneNumber)
          .collection(postType)
          .doc(postId)
          .update({'bought': true});

      MessageToast.showToast(msg: 'Post updated to Bought!');
      fetchUserPosts(userPhoneNumber, postType);
    } catch (e) {
      MessageToast.showToast(msg: 'Error updating post: $e');
    }
  }

  Future<void> updaetTounBought(
      String userPhoneNumber, String postId, String postType) async {
    try {
      await firestore
          .collection('psmPosts')
          .doc(userPhoneNumber)
          .collection(postType)
          .doc(postId)
          .update({'bought': false});

      MessageToast.showToast(msg: 'Post updated to Bought!');
      fetchUserPosts(userPhoneNumber, postType);
    } catch (e) {
      MessageToast.showToast(msg: 'Error updating post: $e');
    }
  }
}
