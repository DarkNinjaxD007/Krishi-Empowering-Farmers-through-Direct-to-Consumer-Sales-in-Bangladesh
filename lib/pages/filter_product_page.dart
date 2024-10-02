import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../animation/FadeAnimation.dart';
import '../components/single_farmer_item.dart';
import '../helpers/network_info.dart';
import '../models/farmer_model.dart';
import '../service/firestore_service.dart';

class FilterProductPage extends StatefulWidget {
  final RangeValues rangeValues;
  final String address;

  const FilterProductPage({super.key, required this.rangeValues, required this.address});

  @override
  State<FilterProductPage> createState() => _FilterProductPageState();
}

class _FilterProductPageState extends State<FilterProductPage> {
  List<DocumentSnapshot> _filteredProducts = [];
  double selectedAmount = 1.0;
  late NetworkInfo _networkInfo;
  int _selectedSize = 0;
  late String totalPrice = '';
  late String unitPrice = '';
  late String amount = '';
  late String seller_name = '';

  @override
  void initState() {
    super.initState();
    _networkInfo = NetworkInfoImpl(InternetConnectionChecker());
    loadFilterProducts(widget.address);
  }

  void loadFilterProducts(String address) async {
    try {
      // Fetch data from collections
      QuerySnapshot mostPopularSnapshot =
      await FirebaseFirestore.instance.collection('Most Popular').get();
      QuerySnapshot forYourselfSnapshot =
      await FirebaseFirestore.instance.collection('for yourself').get();
      QuerySnapshot allProductSnapshot =
      await FirebaseFirestore.instance.collection('All Product').get();

      // Combine all snapshots into a single list of documents
      List<DocumentSnapshot> allProducts = [
        ...mostPopularSnapshot.docs,
        ...forYourselfSnapshot.docs,
        ...allProductSnapshot.docs
      ];

      // Filter products based on rangeValues (price range) and address
      List<DocumentSnapshot> filteredProducts = allProducts.where((product) {
        double productPrice = product['product_price'].toDouble(); // Convert price to double

        // Check if price falls within the specified range
        bool isPriceInRange = productPrice >= widget.rangeValues.start &&
            productPrice <= widget.rangeValues.end;

        // Check if address matches, if provided
        bool isAddressMatch = true;
        if (address != "") {
          List<dynamic> locations = product['locations'] ?? [];
          isAddressMatch = locations.contains(address);
        }

        // Return true if both price is in range and address matches (if provided)
        return isPriceInRange && isAddressMatch;
      }).toList();

      // Update state with filtered products
      setState(() {
        _filteredProducts = filteredProducts;
      });
    } catch (e) {
      // Handle any errors that occur during fetching or filtering
      print("Error fetching products: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // Change your color here
        ),
        title:
            const Text("Filter Product", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightGreen,
      ),
      body: _filteredProducts.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: AlignedGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 4,
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  return FilterproductCart(_filteredProducts[index], context,
                      selectedAmount, _networkInfo, _selectedSize, totalPrice);
                },
              ),
            )
          : const Center(
              child: Text('No products found in this range'),
            ),
    );
  }
}

Widget FilterproductCart(
    DocumentSnapshot<Object?> documentSnapshot,
    BuildContext context,
    double selectedAmount,
    NetworkInfo networkInfo,
    int selectedSize,
    String totalPrice) {
  return FadeAnimation(
    1.5,
    Stack(
      children: [
        Container(
          width: MediaQuery.sizeOf(context).width,
          margin: const EdgeInsets.only(bottom: 16, right: 12, left: 12),
          decoration: BoxDecoration(
            color: Colors.white, // Set background to white
            borderRadius: BorderRadius.circular(8), // Rounded corners
            border: Border.all(
              color: Colors.grey.shade300, // Border color
              width: 2, // 2dp stroke
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: Card(
            elevation: 0, // Set elevation to 0 since we have a border
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Container(
                  height: 80,
                  width: MediaQuery.sizeOf(context).width,
                  margin: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      documentSnapshot['product_img'],
                      fit: BoxFit.fill,
                      height: 100,
                      width: 100,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  margin: const EdgeInsets.only(left: 8, right: 8),
                  child: Text(
                    documentSnapshot['product_name'],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  margin: const EdgeInsets.only(left: 8, right: 8),
                  child: Text(
                    documentSnapshot['brand'],
                    style: TextStyle(
                      color: Colors.lightGreen.shade400,
                      fontSize: 14,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  margin: const EdgeInsets.only(left: 8, right: 8),
                  child: Text(
                    "\৳ ${documentSnapshot['product_price'].toString()}.00",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Top-right positioned card icon
        Positioned(
          right: 16, // Adjust positioning
          top: 4, // Adjust positioning
          child: MaterialButton(
            color: Colors.black,
            minWidth: 30,
            height: 30,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            onPressed: () {
              addToCartModal(documentSnapshot, context, selectedAmount,
                  networkInfo, selectedSize ,totalPrice);
            },
            padding: const EdgeInsets.all(5),
            child: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    ),
  );
}




Future<void> addToCartModal(
    DocumentSnapshot<Object?> documentSnapshot,
    BuildContext mContext,
    double selectedAmount,
    NetworkInfo networkInfo,
    int selectedSize,
    String totaPrice) async {
  List<FarmerModel> farmerList = [];
  int? selectedFarmerIndex;

  List<dynamic> productOwners = documentSnapshot['product_owner'];
  farmerList = productOwners.map((owner) => FarmerModel(owner['name'],owner['uId'], false)).toList();



  return showModalBottomSheet(
    context: mContext,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        // Declare a local variable for the slider's amount to ensure it's updated properly
        double localSelectedAmount = selectedAmount;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(40.0),
              topLeft: Radius.circular(40.0),
            ),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pass the local state variable and setState to the _buildAmountSelector
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'পরিমান',
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
                          ),
                          Text(
                            selectedAmount.round().toString(),
                            style: TextStyle(color: Colors.lightGreen[800], fontSize: 18),
                          ),
                        ],
                      ),
                      Slider(
                        value: selectedAmount,
                        min: 1,
                        max: 100,
                        divisions: 99,
                        activeColor: Colors.lightGreen[800],
                        inactiveColor: Colors.grey.shade300,
                        label: selectedAmount.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            selectedAmount = value; // Update the slider value using setState
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ফারমার লিস্ট :',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: farmerList.length * 50.0,
                    child: ListView.builder(
                      itemCount: farmerList.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return SingleFarmerItem(
                          index: index,
                          farmer: farmerList[index],
                          onSelected: (index) {
                            setState(() {
                              selectedFarmerIndex = index;
                              for (int i = 0; i < farmerList.length; i++) {
                                farmerList[i].isFarmerSelected = (i == selectedFarmerIndex);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              button('কার্টে যোগ করুন', () async {
                User? userCredential = await FirebaseAuth.instance.currentUser;

                if (!await networkInfo.isConnected) {
                  const snackbar = SnackBar(
                    content: Text("No internet available!"),
                    duration: Duration(seconds: 5),
                  );
                  ScaffoldMessenger.of(mContext).showSnackBar(snackbar);
                  return;
                }

                if (userCredential == null) {
                  const snackbar = SnackBar(
                    content: Text("No user is currently logged in."),
                    duration: Duration(seconds: 5),
                  );
                  ScaffoldMessenger.of(mContext).showSnackBar(snackbar);
                  return;
                }

                if (selectedFarmerIndex == null) {
                  const snackbar = SnackBar(
                    content: Text("First select a farmer!"),
                    duration: Duration(seconds: 5),
                  );
                  ScaffoldMessenger.of(mContext).showSnackBar(snackbar);
                  Navigator.pop(context);
                  return;
                }

                totaPrice = (((documentSnapshot['product_price'] as int) *
                    selectedAmount).toInt()).toString();

                await FirestoreServices.addItemToCart(
                  userCredential.uid,
                  DateTime.now().millisecondsSinceEpoch.toString(),
                  documentSnapshot['product_name'],
                  documentSnapshot['brand'],
                  documentSnapshot['product_price'],
                  documentSnapshot['product_img'],
                  (selectedAmount.toInt()).toString(),
                  totaPrice,
                  farmerList[selectedFarmerIndex!].farmerName,
                  farmerList[selectedFarmerIndex!].farmerId,
                  mContext,
                );

                Navigator.pop(context);

                final snackbar = SnackBar(
                  content: const Text("পণ্যটি কার্টে যোগ করা হয়েছে"),
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {},
                  ),
                );

                ScaffoldMessenger.of(mContext).showSnackBar(snackbar);
              }),
            ],
          ),
        );
      },
    ),
  );
}

/*Widget _buildAmountSelector(StateSetter setState, double selectedAmount) {
  return ;
}*/


button(String text, Function onPressed) {
  return MaterialButton(
    onPressed: () => onPressed(),
    height: 50,
    elevation: 0,
    splashColor: Colors.lightGreen[700],
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
    ),
    color: Colors.lightGreen[800],
    child: Center(
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18),),
    ),
  );
}
