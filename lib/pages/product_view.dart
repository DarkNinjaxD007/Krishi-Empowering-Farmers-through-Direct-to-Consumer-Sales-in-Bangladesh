import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_e_commerce_app/components/single_farmer_item.dart';
import 'package:flutter_e_commerce_app/helpers/network_info.dart';
import 'package:flutter_e_commerce_app/models/farmer_model.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../service/firestore_service.dart';

class ProductViewPage extends StatefulWidget {
  final DocumentSnapshot<Object?> documentSnapshot;
  const ProductViewPage({Key? key, required this.documentSnapshot}) : super(key: key);

  @override
  _ProductViewPageState createState() => _ProductViewPageState();
}

class _ProductViewPageState extends State<ProductViewPage> {
  double selectedAmount = 1.0;
  List<FarmerModel> farmerList = [];
  int? selectedFarmerIndex;
  late String totalPrice, unitPrice, seller_name;
  late NetworkInfo _networkInfo;


  @override
  void initState() {
    super.initState();
    _networkInfo = NetworkInfoImpl(InternetConnectionChecker());
    _initializeFarmerList();
    configLoading();
  }


  void configLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..boxShadow = <BoxShadow>[]
      ..progressColor = Colors.yellow
      ..backgroundColor = Colors.grey.withOpacity(0.2)
      ..indicatorColor = Colors.yellow
      ..textColor = Colors.yellow
      ..maskColor = Colors.grey.withOpacity(0.2)
      ..backgroundColor = Colors.transparent
      ..maskType = EasyLoadingMaskType.custom
      ..userInteractions = false
      ..dismissOnTap = false;
  }

  void _initializeFarmerList() {

    List<dynamic> productOwners = widget.documentSnapshot['product_owner'];
    farmerList = productOwners.map((owner) {
      return FarmerModel(
          owner['name'] ?? '',
          owner['uId'] ?? '',
          false
      );
    }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: MediaQuery
                  .of(context)
                  .size
                  .height * 0.6,
              elevation: 0,
              snap: true,
              floating: true,
              stretch: true,
              backgroundColor: Colors.grey.shade50,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                ],
                background: Center(
                  child: Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.7,
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Image.network(
                        widget.documentSnapshot['product_img'],
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(80),
                child: Transform.translate(
                  offset: Offset(0, 1),
                  child: Container(
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: true,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.documentSnapshot['product_name'],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    widget.documentSnapshot['brand'],
                                    style: TextStyle(
                                      color: Colors.orange.shade400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "\৳ " + widget.documentSnapshot['product_price']
                                    .toString() + '.00',
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            widget.documentSnapshot['product_details'],
                            style: TextStyle(
                              height: 1.5,
                              color: Colors.grey.shade800,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 10),
                         /* Text(
                            'পরিমান',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 18),
                          ),*/
                          _buildAmountSelector(),
                          SizedBox(height: 10),
                          Text(
                            'ফারমার লিস্ট :',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 18),
                          ),
                          Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            // Adjust width as needed
                            height: farmerList.length * 50.0,
                            // Adjust height based on item count and item height
                            child: ListView.builder(
                              itemCount: farmerList.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              // Allows the ListView to wrap its content
                              physics: const NeverScrollableScrollPhysics(),
                              // Disables scrolling
                              itemBuilder: (context, index) {
                                return SingleFarmerItem(
                                  index: index,
                                  farmer: farmerList[index],
                                  onSelected: (index) {
                                    setState(() {
                                      selectedFarmerIndex = index;
                                      for (int i = 0; i <
                                          farmerList.length; i++) {
                                        farmerList[i].isFarmerSelected =
                                        (i == selectedFarmerIndex);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                          ),


                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: MaterialButton(
                      onPressed: () async {

                        User? userCredential = await FirebaseAuth.instance
                            .currentUser;

                        if(!await _networkInfo.isConnected){
                          const snackbar = SnackBar(
                            content: Text("No internet available!"),
                            duration: Duration(seconds: 5),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(snackbar);
                          return;
                        }

                        if(userCredential == null){
                          const snackbar = SnackBar(
                            content: Text("No user is currently logged in."),
                            duration: Duration(seconds: 5),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(snackbar);
                          return;
                        }

                        if(selectedFarmerIndex == null){
                          const snackbar = SnackBar(
                            content: Text("First select a farmer!"),
                            duration: Duration(seconds: 5),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(snackbar);
                          return;
                        }



                        EasyLoading.show(status: "Update Cart...");

                        totalPrice = ((widget.documentSnapshot['product_price'] as int)*
                            selectedAmount.toInt()).toString();

                       await FirestoreServices.addItemToCart(
                            userCredential.uid,
                            DateTime.now().millisecondsSinceEpoch.toString(),
                            widget.documentSnapshot['product_name'],
                            widget.documentSnapshot['brand'],
                            widget.documentSnapshot['product_price'],
                            widget.documentSnapshot['product_img'],
                           (selectedAmount.toInt()).toString(),
                            totalPrice,
                            farmerList[selectedFarmerIndex!].farmerName,
                            farmerList[selectedFarmerIndex!].farmerId,
                            context);

                        Navigator.pop(context);
                        EasyLoading.dismiss();
                      },
                      height: 50,
                      elevation: 0,
                      splashColor: Colors.lightGreen[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.lightGreen[800],
                      child: const Center(
                        child: Text(
                          "কার্টে যোগ করুন",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAmountSelector() {
    return Column(
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
              selectedAmount = value;
            });
          },
        ),
      ],
    );
  }

}
