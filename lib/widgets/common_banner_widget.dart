import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';

class CommonBannerWidget extends StatelessWidget {
  final String collectionName;

  const CommonBannerWidget({Key? key, required this.collectionName})
      : super(key: key);

  Stream<QuerySnapshot> fetchBannerStream() {
    return FirebaseFirestore.instance.collection(collectionName).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: fetchBannerStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                            child: SizedBox(
                          height: 26.h,
                          width: 26.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kPrimaryColor,
                          ),
                        ));
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Something went wrong!',
              style: GoogleFonts.inter(color: Colors.red, fontSize: 13.sp),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No banners available!',
              style: GoogleFonts.inter(fontSize: 13,color:Colors.white),
            ),
          );
        }

        // Extract image URLs from Firestore documents
        final imageUrls = snapshot.data!.docs
            .map((doc) => doc['imageUrl'] as String)
            .toList();

        return Swiper(
          itemCount: imageUrls.length,
          autoplay: true,
          autoplayDelay: 6000, // 6 seconds
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: SizedBox(
                        height: 26.0,
                        width: 26.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.orange,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return  Icon(Icons.error,color: Colors.white,);
                  },
                ),
              ),
            );
          },
          pagination: SwiperPagination(
            builder: DotSwiperPaginationBuilder(
              color: Colors.white,
              activeColor: Colors.orange,
              size: 5.sp,
              activeSize: 8.sp,
            ),
          ),
        );
      },
    );
  }
}
