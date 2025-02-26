import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/controllers/panels/ad_panel_controller.dart';
import 'package:solar_market/controllers/profile/profile_controller.dart';
import 'package:solar_market/screens/dashboard/add_items/components/dropdown.dart';
import 'package:solar_market/utils/toas_message.dart';
import 'package:solar_market/widgets/round_button.dart';

class AddPanel extends StatefulWidget {
  const AddPanel({super.key});

  @override
  State<AddPanel> createState() => _AddPanelState();
}

class _AddPanelState extends State<AddPanel> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();

    fetchBrands();

    fetchLocations();
    fetchPriceRange();
  }

  Future<void> fetchBrands() async {
    try {
      QuerySnapshot snapshot =
          await _db.collection('panelBrands').orderBy('brandNumber').get();
      if (mounted) {
        setState(() {
          brands =
              snapshot.docs.map((doc) => doc['brandName'] as String).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        // Get.snackbar('Error', 'Failed to fetch brands: $e',
        //     snackPosition: SnackPosition.BOTTOM,
        //     backgroundColor: Colors.red,
        //     colorText: Colors.white);
      }
      print(e);
    }
  }

  Future<void> fetchNames(String brandName) async {
    try {
      QuerySnapshot brandSnapshot = await _db
          .collection('panelBrands')
          .where('brandName', isEqualTo: brandName)
          .get();

      if (brandSnapshot.docs.isNotEmpty) {
        String brandId = brandSnapshot.docs.first.id;
        QuerySnapshot childSnapshot = await _db
            .collection('panelBrands')
            .doc(brandId)
            .collection('children')
            .get();

        if (mounted) {
          setState(() {
            names = {
              for (var doc in childSnapshot.docs)
                doc['childName']: List<String>.from(doc['models'] ?? []),
            };
            selectedName = null;
            selectedChildName = null;
            childNames = [];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        // Get.snackbar('Error', 'Failed to fetch names: $e',
        //     snackPosition: SnackPosition.BOTTOM,
        //     backgroundColor: Colors.red,
        //     colorText: Colors.white);
      }
    }
  }

  void fetchChildNames(String name) {
    if (mounted) {
      setState(() {
        childNames = names[name] ?? [];
        selectedChildName = null;
      });
    }
  }

  String? selectedBrand;
  String? selectedName;
  String? selectedChildName;

  Map<String, dynamic> names = {};
  List<String> childNames = [];
  List<String> brands = [];
  List<String> locationNames = [];

  String? selectedType;
  String? selectedContainer;
  String? selectedQuantity;
  String? selectedAvailability;
  String? selectedLocation;
  int? minPrice;
  int? maxPrice;

  final TextEditingController priceController = TextEditingController();
  final TextEditingController tokenMoneyController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  final AddPanelController addPanelController = Get.put(AddPanelController());
  final ProfileController profileController = Get.put(ProfileController());
  final List<String> types = ['Seller', 'Buyer'];

  final List<String> containers = ['Container', 'Pallets'];
  List<String> quantities = [];
  final List<String> availabilities = ['Ready Stock', 'Delivery'];

  // Function to fetch locations from Firestore
  Future<void> fetchLocations() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('locations').get();
      final List<String> fetchedLocations = snapshot.docs
          .map((doc) => doc['name'] as String) // Extracting 'name' field
          .toList();

      setState(() {
        locationNames = fetchedLocations;
      });
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error fetching locations: $e')),
      // );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      setState(() {
        dateController.text = formattedDate;
      });
    }
  }

  Future<void> fetchPriceRange() async {
    try {
      final doc = await FirebaseFirestore.instance
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
      print(error);
    }
  }

  void updateQuantities(String? containerType) {
    setState(() {
      if (containerType == 'Container') {
        quantities =
            List<String>.generate(5, (index) => (index + 1).toString());
      } else if (containerType == 'Pallets') {
        quantities =
            List<String>.generate(20, (index) => (index + 1).toString());
      } else {
        quantities = [];
      }
      selectedQuantity = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Dropdown.buildDropdownFieldAlt(
              label: 'Type',
              hint: 'Select Type',
              value: selectedType,
              items: types,
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
              },
            ),

            const SizedBox(height: 16),

            Dropdown.buildDropdownFieldAlt(
              label: 'Brand',
              hint: 'Select Brand',
              value: brands.contains(selectedBrand) ? selectedBrand : null,
              items: brands,
              onChanged: (value) {
                setState(() {
                  selectedBrand = value;
                  selectedName = null;
                  selectedChildName = null;
                  names.clear();
                  childNames.clear();
                  fetchNames(value!);
                });
              },
            ),
            SizedBox(height: 16),

            // Dropdown for Names
            Dropdown.buildDropdownFieldAlt(
              label: 'Name',
              hint: 'Select Name',
              value: names.keys.contains(selectedName) ? selectedName : null,
              items: names.keys.toList(),
              onChanged: (value) {
                setState(() {
                  selectedName = value;
                  selectedChildName = null;
                  childNames.clear();
                  fetchChildNames(value!);
                });
              },
            ),
            SizedBox(height: 16),

            // Dropdown for Child Names
            if (childNames.isNotEmpty)
              Dropdown.buildDropdownFieldAlt(
                label: 'Model',
                hint: 'Select model',
                value: childNames.contains(selectedChildName)
                    ? selectedChildName
                    : null,
                items: childNames,
                onChanged: (value) {
                  setState(() {
                    selectedChildName = value;
                  });
                },
              ),
            if (childNames.isNotEmpty) SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Dropdown.buildDropdownFieldAlt(
                    label: 'Container/Pallets',
                    hint: 'Select Container',
                    value: selectedContainer,
                    items: containers,
                    onChanged: (value) {
                      setState(() {
                        selectedContainer = value;
                        updateQuantities(value);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Dropdown.buildDropdownFieldAlt(
                    label: 'Quantity/Piece',
                    hint: 'Select Quantity',
                    value: selectedQuantity,
                    items: quantities,
                    onChanged: (value) {
                      setState(() {
                        selectedQuantity = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Dropdown.buildTextField(
                    hint: 'Enter Price',
                    label: 'Price range: $minPrice - $maxPrice',
                    controller: priceController,
                    fielType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Dropdown.buildDropdownFieldAlt(
                    label: 'Location',
                    hint: 'Select location',
                    value: selectedLocation,
                    items: locationNames,
                    onChanged: (value) {
                      setState(() {
                        selectedLocation = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Dropdown.buildDropdownFieldAlt(
              label: 'Availability',
              hint: 'Select Availability',
              value: selectedAvailability,
              items: availabilities,
              onChanged: (value) {
                setState(() {
                  selectedAvailability = value;
                });
              },
            ),
            if (selectedAvailability ==
                'Delivery') // Check if availability is "Delivery"

              SizedBox(height: 16),
            if (selectedAvailability ==
                'Delivery') // Check if availability is "Delivery"

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Date',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: dateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Select Date',
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
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            if (selectedType == 'Seller')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Token Money',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                      controller: tokenMoneyController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.inter(
                        // color: Color(0xFF626262),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
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
            const SizedBox(height: 24),
            Obx(() => addPanelController.isLoading.value
                ? CircularProgressIndicator(
                    color: kPrimaryColor,
                  )
                : Center(
                    child: RoundButton(
                        onPressed: () {
                          if (selectedType == null) {
                            MessageToast.showToast(
                                msg: 'Please select the type.');
                            return;
                          }
                          if (selectedBrand == null) {
                            MessageToast.showToast(
                                msg: 'Please select the brand.');
                            return;
                          }
                          if (selectedName == null) {
                            MessageToast.showToast(
                                msg: 'Please select the name.');
                            return;
                          }
                          if (selectedChildName == null) {
                            MessageToast.showToast(
                                msg: 'Please select the model.');
                            return;
                          }
                          if (selectedContainer == null) {
                            MessageToast.showToast(
                                msg: 'Please select the Container/Pallets.');
                            return;
                          }

                          if (selectedLocation == null) {
                            MessageToast.showToast(
                                msg: 'Please select the location.');
                            return;
                          }
                          if (selectedAvailability == null) {
                            MessageToast.showToast(
                                msg: 'Please select the availability.');
                            return;
                          }
                          if (selectedAvailability == 'Delivery' &&
                              dateController.text.isEmpty) {
                            MessageToast.showToast(
                                msg: 'Please select the delivery date.');
                            return;
                          }
                          if (selectedQuantity == null) {
                            MessageToast.showToast(
                                msg: 'Please select the quantity.');
                            return;
                          }
                          if (selectedType == 'Seller' &&
                              tokenMoneyController.text.isEmpty) {
                            MessageToast.showToast(
                                msg: 'Please enter the token money.');
                            return;
                          }

                          final double? price =
                              double.tryParse(priceController.text);
                          if (price == null ||
                              price < minPrice! ||
                              price > maxPrice!) {
                            MessageToast.showToast(
                                msg:
                                    'Price must be between $minPrice and $maxPrice.');
                            return;
                          }

                          // Prepare Panel Data
                          final panelData = {
                            'type': selectedType,
                            'userId': FirebaseAuth.instance.currentUser!.uid,
                            'brand': selectedBrand,
                            'itemId': DateTime.now().toString(),
                            'name': selectedName,
                            'model': selectedChildName,
                            'size': selectedContainer,
                            'deliveryDate': dateController.text,
                            'quantity': selectedQuantity,
                            'price': price,
                            'userName': profileController.userName.value,
                            // 'userImage': profileController.userImage.value,
                            'userNumber': profileController.userPhone.value,
                            'bought': false,
                            'sold': false,
                            'isShowing': true,
                            'bidding': 'pending',
                            'location': selectedLocation,
                            'status': 'active',
                            'availability': selectedAvailability,
                            'tokenMoney': tokenMoneyController.text,
                            'createdAt': DateTime.now(),
                          };

                          addPanelController.addPanel(
                              userPhoneNumber:
                                  profileController.userPhone.value,
                              panelData: panelData,
                              context: context);
                        },
                        text: 'Submit'))),

            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
