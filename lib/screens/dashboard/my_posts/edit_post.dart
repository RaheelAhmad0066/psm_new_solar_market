import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/controllers/post/my_post_controller.dart';
import 'package:solar_market/controllers/profile/profile_controller.dart';
import 'package:solar_market/screens/dashboard/add_items/components/dropdown.dart';
import 'package:solar_market/utils/toas_message.dart';
import 'package:solar_market/widgets/round_button.dart';

class EditPostPage extends StatefulWidget {
  final Map<String, dynamic> post;
  final String postType;
  final String categoryType;

  EditPostPage(
      {required this.post, required this.postType, required this.categoryType});

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProfileController profileController = Get.put(ProfileController());

  TextEditingController tokenMoneyController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  final MyPostsController controller = Get.put(MyPostsController());

  String? selectedLocation;
  String? selectedQuantity;
  String? selectedItemType;
  String? selectedDeliveryDate;
  String availability = 'Ready Stock';

  int? minPrice;
  int? maxPrice;
  List<String> locationNames = [];
  final List<String> availabilities = ['Ready Stock', 'Delivery'];

  @override
  void initState() {
    super.initState();
    fetchPriceRange();
    fetchLocations();

    tokenMoneyController.text = widget.post['tokenMoney'];
    priceController.text = widget.post['price'].toString();
    availability = widget.post['availability'];
    selectedLocation = widget.post['location'];
    selectedItemType = widget.post['size'];
    selectedQuantity = widget.post['quantity'];
    selectedDeliveryDate = widget.post['deliveryDate'];
  }

  Future<void> fetchLocations() async {
    try {
      final snapshot = await _firestore.collection('locations').get();
      final List<String> fetchedLocations =
          snapshot.docs.map((doc) => doc['name'] as String).toList();

      setState(() {
        locationNames = fetchedLocations;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching locations: $e')),
      );
    }
  }

  Future<void> fetchPriceRange() async {
    try {
      final doc = await _firestore
          .collection('prices')
          .doc('ZroOKMANQ5EFQksWZN2j')
          .get();
      if (doc.exists) {
        setState(() {
          minPrice = doc['minPrice'];
          maxPrice = doc['maxPrice'];
        });
      }
    } catch (error) {
      print('Error fetching price range: $error');
    }
  }

  String? selectedChildName;

  List<String> childNames = [];

  void _showEditBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16.0,
                right: 16.0,
                top: 16.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Edit Post',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price in RS k',
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.inter(
                              // color: Color(0xFF626262),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            inputFormatters: [
                              widget.postType == 'userPanels'
                                  ? FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d*$'))
                                  : FilteringTextInputFormatter.digitsOnly,
                              widget.postType == 'userPanels'
                                  ? LengthLimitingTextInputFormatter(-1)
                                  : LengthLimitingTextInputFormatter(3),
                            ],
                            decoration: InputDecoration(
                              hintText: 'Enter Price',
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
                            )),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Dropdown.buildTextField(
                      controller: tokenMoneyController,
                      hint: 'Token Price',
                      label: 'Token Money',
                      fielType: TextInputType.number,
                    ),
                    SizedBox(height: 8.0),
                    Dropdown.buildDropdownFieldAlt(
                      hint: 'Select Location',
                      label: 'Location',
                      value: selectedLocation,
                      items: locationNames,
                      onChanged: (value) {
                        setState(() {
                          selectedLocation = value!;
                        });
                      },
                    ),
                    SizedBox(height: 8.0),
                    if (widget.postType == 'userPanels') ...[
                      Dropdown.buildDropdownFieldAlt(
                        hint: 'Select Type',
                        label: 'Type',
                        value: selectedItemType,
                        items: ['Container', 'Pallets'],
                        onChanged: (value) {
                          setState(() {
                            selectedItemType = value!;
                            selectedQuantity = null; // Reset quantity
                          });
                        },
                      ),
                      SizedBox(height: 8.0),
                      Dropdown.buildDropdownFieldAlt(
                        hint: 'Select Quantity',
                        label: 'Quantity',
                        value: selectedQuantity,
                        items: selectedItemType == 'Container'
                            ? List.generate(5, (index) => '${index + 1}')
                            : selectedItemType == 'Pallets'
                                ? List.generate(20, (index) => '${index + 1}')
                                : [],
                        onChanged: (value) {
                          setState(() {
                            selectedQuantity = value!;
                          });
                        },
                      ),
                    ] else ...[
                      Dropdown.buildDropdownFieldAlt(
                        hint: 'Select Quantity',
                        label: 'Quantity',
                        value: selectedQuantity,
                        items: List.generate(20, (index) => '${index + 1}'),
                        onChanged: (value) {
                          setState(() {
                            selectedQuantity = value!;
                          });
                        },
                      ),
                    ],
                    SizedBox(height: 8.0),
                    Dropdown.buildDropdownFieldAlt(
                      hint: 'Availability',
                      label: 'Availability',
                      value: availability,
                      items: availabilities,
                      onChanged: (value) {
                        setState(() {
                          availability = value!;
                        });
                      },
                    ),
                    if (availability == 'Delivery')
                      InkWell(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDeliveryDate =
                                  DateFormat('dd-MM-yyyy').format(pickedDate);
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                selectedDeliveryDate ?? 'Select Date',
                                style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    color: kblack,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 16.0),
                    RoundButton(
                      onPressed: () {
                        final priceText = priceController.text;
                        final enteredPrice = widget.postType == 'userPanels'
                            ? double.tryParse(priceText)
                            : int.tryParse(priceText);
                        if (widget.postType == 'userPanels' &&
                            (enteredPrice! < (minPrice ?? 0) ||
                                enteredPrice > (maxPrice ?? double.infinity))) {
                          MessageToast.showToast(
                              msg:
                                  'Price must be between $minPrice and $maxPrice');
                          return;
                        }
                        if ((widget.postType == 'userLithium' ||
                                widget.postType == 'userInverters') &&
                            priceText.length < 3) {
                          MessageToast.showToast(
                              msg:
                                  'Price must have a minimum of 3 digits.');
                          return;
                        }
                        if (availability == 'Delivery' &&
                            (selectedDeliveryDate == null ||
                                selectedDeliveryDate!.isEmpty)) {
                          MessageToast.showToast(
                            msg: 'Please select a delivery date.',
                          );
                          return;
                        }
                        if ((selectedItemType != null &&
                                selectedItemType!.isNotEmpty) &&
                            (selectedQuantity == null ||
                                selectedQuantity!.isEmpty)) {
                          MessageToast.showToast(
                              msg: 'Please select a quantity');
                          return;
                        }

                        var updatedData = {
                          'tokenMoney': tokenMoneyController.text,
                          'price': widget.postType == 'userPanels'
                              ? enteredPrice
                              : priceText,
                          'availability': availability,
                          if (availability == 'Delivery')
                            'deliveryDate': selectedDeliveryDate,
                          'location': selectedLocation,
                          'size': selectedItemType,
                          'quantity': selectedQuantity,
                        };

                        controller.editPost(
                          profileController.userPhone.value,
                          widget.post['itemId'],
                          updatedData,
                          widget.postType,
                        );

                        Navigator.pop(context);
                      },
                      text: 'Save',
                    ),
                    SizedBox(
                      height: 19,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _showEditBottomSheet(context);
      },
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              'Edit',
              style: GoogleFonts.inter(
                  fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
