
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FetchInvertersController extends GetxController {

 FirebaseFirestore firestore = FirebaseFirestore.instance;

  var allData = <Map<String, dynamic>>[].obs;
  var filteredData = <Map<String, dynamic>>[].obs;
  var paginatedData = <Map<String, dynamic>>[].obs;

  var brands = <String>[].obs;
  var selectedBrand = 'All'.obs;

  var isLoading = true.obs;
  var isLoadingBrands = false.obs;
  var isLoadingMore = false.obs;
  var hasMoreData = true.obs;

  var errorMessage = ''.obs;

  var userImages = <String, String>{}.obs;
  var userVerificationStatus = <String, bool>{}.obs;
  var userRoles = <String, String>{}.obs;

  final int itemsPerPage = 8;
  var currentPage = 1.obs;
  DocumentSnapshot? lastDocument;

  @override
  void onInit() {
    super.onInit();
    fetchBrands();
    fetchInverter(fetchLimit: itemsPerPage);
  }

  Future<void> fetchBrands() async {
    try {
      isLoadingBrands.value = true;

      QuerySnapshot snapshot = await firestore
          .collection('inverterBrands')
          .orderBy('brandNumber', descending: false)
          .get();

      brands.value = ['All'];
      brands.addAll(
          snapshot.docs.map((doc) => (doc['brandName'] ?? '').toString()).toList());
    } catch (e) {
      errorMessage.value = "Error fetching brands: $e";
    } finally {
      isLoadingBrands.value = false;
    }
  }

  Future<void> fetchInverter(
      {bool isLoadMore = false, int fetchLimit = 10}) async {
    try {
      if (!isLoadMore) {
        isLoading.value = true;
        errorMessage.value = '';
        allData.clear();
        filteredData.clear();
        paginatedData.clear();
        lastDocument = null;
      } else {
        isLoadingMore.value = true;
      }

      Query query = firestore
          .collection('psmPosts')
          .orderBy('created_at', descending: true)
          .limit(fetchLimit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      QuerySnapshot mainCollectionSnapshot = await query.get();
      if (mainCollectionSnapshot.docs.isEmpty) return;

      List<Map<String, dynamic>> posts = [];
      Set<String> userIds = {};

      await Future.wait(mainCollectionSnapshot.docs.map((doc) async {
        String docId = doc.id;
        lastDocument = doc;

        QuerySnapshot subCollectionSnapshot = await firestore
            .collection('psmPosts')
            .doc(docId)
            .collection('userInverters')
            .orderBy('price', descending: false)
            .where('isShowing', isEqualTo: true)
            .get();

        for (var subDoc in subCollectionSnapshot.docs) {
          var data = subDoc.data() as Map<String, dynamic>;
          String userId = data['userId'];
          userIds.add(userId);

          // Auto-expire outdated panels
          if (_shouldExpirePanel(data)) {
            await _expirePanel(docId, subDoc.id);
          } else {
            posts.add(data);
          }
        }
      }));

      await fetchUserDetails(userIds);

      allData.addAll(posts);

      _sortPostsByPSMOfficialAndPrice();

      filterByBrand(selectedBrand.value);
    } catch (e) {
      errorMessage.value = "Error fetching posts: $e";
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void _sortPostsByPSMOfficialAndPrice() {
    List<Map<String, dynamic>> psmOfficialPosts = [];
    List<Map<String, dynamic>> otherPosts = [];

    for (var post in allData) {
      if (post['userName'] == 'PSM Official') {
        psmOfficialPosts.add(post);
      } else {
        otherPosts.add(post);
      }
    }

    otherPosts.sort((a, b) {
      double priceA = a['price'] is double
          ? a['price']
          : double.tryParse(a['price'].toString()) ?? 0;
      double priceB = b['price'] is double
          ? b['price']
          : double.tryParse(b['price'].toString()) ?? 0;
      return priceA.compareTo(priceB);
    });

    allData.value = [...psmOfficialPosts, ...otherPosts];
  }

  bool _shouldExpirePanel(Map<String, dynamic> data) {
    Timestamp createdAt = data['createdAt'];
    DateTime postDateTime = createdAt.toDate();
    DateTime currentDateTime = DateTime.now();
    return currentDateTime.difference(postDateTime).inHours >= 24;
  }

  Future<void> _expirePanel(String docId, String subDocId) async {
    await firestore
        .collection('psmPosts')
        .doc(docId)
        .collection('userInverters')
        .doc(subDocId)
        .update({'isShowing': false, 'status': 'hadShown'});
  }

 Future<void> fetchUserDetails(Set<String> userIds) async {
    try {
      if (userIds.isEmpty) return;

      QuerySnapshot snapshot = await firestore
          .collection('pmsUsers')
          .where(FieldPath.documentId, whereIn: userIds.toList())
          .get();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        userImages[doc.id] = data['image'] ?? 'default';
        userVerificationStatus[doc.id] = data['isVerified'] ?? false;
                userRoles[doc.id] = data['tag'] ?? 'default'; // Fetch user type

      }
    } catch (e) {
      for (var userId in userIds) {
        userImages[userId] = 'default';
        userVerificationStatus[userId] = false;
                userRoles[userId] = 'user'; // Default user type

      }
    }
  }

  void filterByBrand(String brand) {
    selectedBrand.value = brand;

    if (brand == 'All') {
      filteredData.value = List<Map<String, dynamic>>.from(allData);
    } else {
      filteredData.value = allData.where((data) {
        String postBrand = (data['brand'] ?? '').toString().toLowerCase();
        String selectedBrandLower = brand.toLowerCase();
        return postBrand == selectedBrandLower;
      }).toList();
    }

    resetPagination();
  }

  void resetPagination() {
    currentPage.value = 1;
    paginatedData.value = filteredData.take(itemsPerPage).toList();
  }

  void loadMoreItems() async {
    if (isLoadingMore.value || paginatedData.length >= filteredData.length) {
      return;
    }

    isLoadingMore.value = true;

await Future.delayed(const Duration(milliseconds: 1500));
    //  await Future.delayed(const Duration(seconds: 2));


    int start = currentPage.value * itemsPerPage;
    int end = start + itemsPerPage;

    if (start < filteredData.length) {
      end = (end > filteredData.length) ? filteredData.length : end;
      paginatedData.addAll(filteredData.sublist(start, end));
      currentPage.value++;
    }
      hasMoreData.value = paginatedData.length < filteredData.length;


    isLoadingMore.value = false;
  }
}
