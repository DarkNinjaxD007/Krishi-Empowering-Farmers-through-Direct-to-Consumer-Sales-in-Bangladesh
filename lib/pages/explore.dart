import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_e_commerce_app/pages/filter_product_page.dart';
import 'package:flutter_e_commerce_app/pages/product_view.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../animation/FadeAnimation.dart';
import '../components/single_farmer_item.dart';
import '../helpers/network_info.dart';
import '../models/farmer_model.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({ Key? key }) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _isScrolled = false;
  List<dynamic> productList = [];



  List<Color> colors = [
    Colors.black,
    Colors.purple,
    Colors.lightGreen.shade200,
    Colors.blueGrey,
    const Color(0xFFFFC1D9),
  ];

  double selectedAmount = 1.0;
  late NetworkInfo _networkInfo;
  var selectedRange = const RangeValues(10.00, 1500.00);
  late String totalPrice, unitPrice, amount, seller_name;
  String filterValue = "";
  String address = "";


  CollectionReference mostPopularRef = FirebaseFirestore.instance.collection("Most Popular");
  CollectionReference forYouRef = FirebaseFirestore.instance.collection("for yourself");
  CollectionReference allProductRef = FirebaseFirestore.instance.collection("All Product");

  @override
  void initState() {
    _scrollController = ScrollController();
   // _scrollController.addListener(_listenToScrollChange);
    _networkInfo = NetworkInfoImpl(InternetConnectionChecker());
    _getUserLocations();

    super.initState();
  }


  void _getUserLocations() async{

    var user = FirebaseAuth.instance.currentUser;
    if (user != null){
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("user")
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          address = userDoc.get('address') ?? ''; // Update state
        });
      } else {
        print("User document does not exist");
      }
    }


  }

  void _listenToScrollChange() {
    if (_scrollController.offset >= 100.0) {
      setState(() {
        _isScrolled = true;
      });
    } else {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            elevation: 0,
            pinned: true,
            floating: true,
            stretch: true,
            backgroundColor: Colors.grey.shade50,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double minExtent = MediaQuery.of(context).padding.top + kToolbarHeight;
                final double maxExtent = constraints.maxHeight;
                final double currentExtent = constraints.biggest.height;
                final double deltaExtent = maxExtent - minExtent;
                final double t = (1.0 - (currentExtent - minExtent) / deltaExtent).clamp(0.0, 1.0);

                final double logoHeight = lerpDouble(120, 40, t)!;
                final double fontSize = lerpDouble(20, 18, t)!;

                return FlexibleSpaceBar(
                  centerTitle: true,
                  title: SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: logoHeight,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: Semantics(
                                      label: 'Created by Md Soliman Ali',
                                      child: Image.asset(
                                        'assets/images/logo.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "কৃষিতে আপনাকে স্বাগতম",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset("assets/images/background.png", fit: BoxFit.cover),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            bottom: AppBar(
              toolbarHeight: 70,
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Row(
                children: [
                  Expanded(
                    child: FadeAnimation(1.4, Container(
                      height: 50,
                      child: TextField(
                        readOnly: false,
                        onChanged: (value){
                          filterValue = value;
                          setState(() {

                          });
                        },
                        cursorColor: Colors.grey,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.search, color: Colors.black),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none
                          ),
                          hintText: "আপনার পছন্দের পণ্যটি বাছাই করুন",
                          hintStyle: const TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(width: 10),
                  FadeAnimation(1.5, Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: IconButton(
                      onPressed: () {
                        showFilterModal();
                      },
                      icon: const Icon(Icons.filter_list, color: Colors.black, size: 30,),
                    ),
                  ))
                ],
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate([

            filterValue.isNotEmpty ?  ShowFilterProduct(filterValue, context, address) :

                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: const EdgeInsets.only(top: 20, left: 20),
                        color: Colors.white,
                        height: 330,
                        child: Column(
                            children: [
                              FadeAnimation(1.4, const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('বহুল প্রচলিত পণ্য', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
                                  Padding(
                                    padding: EdgeInsets.only(right: 20.0),
                                    child: Text('সব দেখুন', style: TextStyle(color: Colors.black, fontSize: 14),),
                                  ),
                                ],
                              )),
                              const SizedBox(height: 10,),
                              Expanded(
                                  child: StreamBuilder(
                                    stream: address.isNotEmpty ?mostPopularRef
                                        .where('locations', arrayContains: address) // Use arrayContains instead of isEqualTo
                                        .snapshots() : mostPopularRef.snapshots(),
                                    builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapShot) {
                                      if (streamSnapShot.hasData) {
                                        if (streamSnapShot.data!.docs.isEmpty) {
                                          return const Center(child: Text("কোন পণ্য পাওয়া যায় নি")); // Optional: Handle empty state
                                        }
                                        return ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: streamSnapShot.data!.docs.length,
                                          itemBuilder: (context, index) {
                                            final DocumentSnapshot documentSnapshot =
                                            streamSnapShot.data!.docs[index];
                                            return productCart(documentSnapshot, context);
                                          },
                                        );
                                      }
                                      return const Center(child: CircularProgressIndicator());
                                    },
                                  )
                              )
                            ]
                        )
                    ),
                    Container(
                        color: Colors.white,
                        padding: const EdgeInsets.only(top: 20, left: 20),
                        height: 180,
                        child: Column(
                            children: [
                              FadeAnimation(1.4, const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('আপনার জন্য', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
                                  Padding(
                                    padding: EdgeInsets.only(right: 20.0),
                                    child: Text('সব দেখুন', style: TextStyle(color: Colors.black, fontSize: 14),),
                                  ),
                                ],
                              )),
                              const SizedBox(height: 10,),
                              Expanded(
                                  child: StreamBuilder(
                                    stream:address.isNotEmpty ? forYouRef.where('locations', arrayContains: address) // Filter by address in the 'locations' array
                                        .snapshots() : forYouRef.snapshots(),
                                    builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapShot) {
                                      if (streamSnapShot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                      }

                                      if (streamSnapShot.hasError) {
                                        return Center(child: Text("Something went wrong: ${streamSnapShot.error}"));
                                      }

                                      if (streamSnapShot.hasData) {
                                        final documents = streamSnapShot.data!.docs;

                                        if (documents.isEmpty) {
                                          return const Center(child: Text("কোন পণ্য পাওয়া যায় নি"));
                                        }

                                        return ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: documents.length,
                                          itemBuilder: (context, index) {
                                            final DocumentSnapshot forYouDocumentSnapshot = documents[index];
                                            return forYou(forYouDocumentSnapshot);
                                          },
                                        );
                                      }

                                      return const Center(child: CircularProgressIndicator());
                                    },
                                  )
                              )
                            ]
                        )
                    ),
                    Container(
                        color: Colors.white,
                        padding: const EdgeInsets.only(top: 20, left: 20),
                        height: 330,
                        child: Column(
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('নতুন পণ্য', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
                                  Padding(
                                    padding: EdgeInsets.only(right: 20.0),
                                    child: Text('সব দেখুন', style: TextStyle(color: Colors.black, fontSize: 14),),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Expanded(
                                  child: StreamBuilder(
                                    stream: address.isNotEmpty ? allProductRef.where('locations', arrayContains: address) // Filter by address in the 'locations' array
                                        .snapshots() : allProductRef.snapshots(),
                                    builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapShot) {
                                      if (streamSnapShot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                      }

                                      if (streamSnapShot.hasError) {
                                        return Center(child: Text("Something went wrong: ${streamSnapShot.error}"));
                                      }

                                      if (streamSnapShot.hasData) {
                                        final documents = streamSnapShot.data!.docs;

                                        if (documents.isEmpty) {
                                          return const Center(child: Text("কোন পণ্য পাওয়া যায় নি"));
                                        }

                                        return ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: documents.length,
                                          itemBuilder: (context, index) {
                                            final DocumentSnapshot documentSnapshot = documents[index];
                                            return productCart(documentSnapshot, context);
                                          },
                                        );
                                      }

                                      return const Center(child: CircularProgressIndicator());
                                    },
                                  )

                              )
                            ]
                        )
                    ),
                  ],
                )

            ]),
          )
        ]
    );
  }


  Widget ShowFilterProduct(String filterValue, BuildContext context, String address) {
    return FutureBuilder(
      future: _getFilteredProducts(filterValue, address), // Method that returns your filtered products
      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a centered CircularProgressIndicator while waiting for the data
          return const Padding(
            padding: EdgeInsets.only(top: 52.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          // Show an error message in the center if there's an error
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 52.0),
            child: Center(
              child: Text(
                'কোন পণ্য পাওয়া যায় নি',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // If there are filtered products, display them using AlignedGridView
        final filteredProducts = snapshot.data!;
        return AlignedGridView.count(
          crossAxisCount: 2,
          shrinkWrap: true, // Avoid expanding beyond its content
          physics: const NeverScrollableScrollPhysics(), // Let the Slider handle the scrolling
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            return FilterproductCart(filteredProducts[index], context);
          },
        );
      },
    );
  }


  Widget FilterproductCart(DocumentSnapshot<Object?> documentSnapshot, BuildContext context) {
    return FadeAnimation(
      1.5,
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductViewPage(documentSnapshot: documentSnapshot),
            ),
          );
        },
        child: Stack(
          children: [
            Container(
              width: MediaQuery.sizeOf(context).width,
              margin: const EdgeInsets.only( bottom: 16, right: 8, left: 8),
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
                    const SizedBox(height: 8),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            documentSnapshot['brand'],
                            style: TextStyle(
                              color: Colors.lightGreen.shade400,
                              fontSize: 14,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),

                        ],
                      ),
                    ),
                    Text(
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
                  ],
                ),
              ),
            ),
            // Top-right positioned card icon
            Positioned(
              right: 4, // Adjust positioning
              top: 4, // Adjust positioning
              child: MaterialButton(
                color: Colors.black,
                minWidth: 30,
                height: 30,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                onPressed: () {
                  addToCartModal(documentSnapshot, context);
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
      ),
    );
  }




  Future<List<DocumentSnapshot>> _getFilteredProducts(String filterValue, String address) async {
    // Fetch snapshots from all collections
    QuerySnapshot mostPopularSnapshot = await FirebaseFirestore.instance.collection('Most Popular').get();
    QuerySnapshot forYourselfSnapshot = await FirebaseFirestore.instance.collection('for yourself').get();
    QuerySnapshot allProductSnapshot = await FirebaseFirestore.instance.collection('All Product').get();

    // Combine all snapshots into a list
    List<QuerySnapshot> snapshots = [mostPopularSnapshot, forYourselfSnapshot, allProductSnapshot];
    List<DocumentSnapshot> filteredProducts = [];

    // Convert the filterValue into a set of keywords
    List<String> filterKeywords = filterValue.toLowerCase().split(' ');

    for (var snapshot in snapshots) {
      for (var doc in snapshot.docs) {
        final product = doc.data() as Map<String, dynamic>;

        String productName = product['product_name']?.toString().toLowerCase() ?? '';
        String brandName = product['brand']?.toString().toLowerCase() ?? '';

        // Combine product name and brand into one string for easier keyword matching
        String combinedText = '$productName $brandName';

        // Check if any of the filter keywords are present in the combined text
        bool matchFound = filterKeywords.any((keyword) => combinedText.contains(keyword));

        bool locationMatches = true;
        if (address != "") {
          List<dynamic> locations = product['locations'] ?? [];
          locationMatches = locations.contains(address);
        }

        // Add the document if the keyword matches and, if address is provided, the location matches
        if (matchFound && locationMatches) {
          filteredProducts.add(doc);
        }
      }
    }
    return filteredProducts;
  }





  productCart(DocumentSnapshot<Object?> documentSnapshot, BuildContext context) {
    return AspectRatio(
      aspectRatio: 1 / 1,
      child: FadeAnimation(
        1.5,
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProductViewPage(documentSnapshot: documentSnapshot,)));
          },
          child: Container(
            margin: const EdgeInsets.only(right: 20, bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(5, 10),
                  blurRadius: 15,
                  color: Colors.grey.shade200,
                )
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 150,
                  child: Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            documentSnapshot['product_img'],
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      // Add to cart button
                      Positioned(
                        right: 5,
                        bottom: 5,
                        child: MaterialButton(
                          color: Colors.black,
                          minWidth: 45,
                          height: 45,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          onPressed: () {
                            addToCartModal(documentSnapshot,context);
                          },
                          padding: const EdgeInsets.all(5),
                          child: const Center(
                            child: Icon(
                              Icons.shopping_cart,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  documentSnapshot['product_name'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2, // Adjust this based on your needs
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        documentSnapshot['brand'],
                        style: TextStyle(
                          color: Colors.lightGreen.shade400,
                          fontSize: 14,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1, // Adjust this based on your needs
                      ),
                    ),
                    Text(
                      "\৳ " + documentSnapshot['product_price'].toString() + '.00',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1, // Adjust this based on your needs
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  forYou(DocumentSnapshot<Object?> forYoudocumentSnapshot) {
    return AspectRatio(
      aspectRatio: 3 / 1,
      child: FadeAnimation(
        1.5,
        GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProductViewPage(documentSnapshot: forYoudocumentSnapshot,)));
          },
          child: Container(
            margin: const EdgeInsets.only(right: 20, bottom: 25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(5, 10),
                  blurRadius: 15,
                  color: Colors.grey.shade200,
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      forYoudocumentSnapshot['product_img'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          forYoudocumentSnapshot['product_name'],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Flexible(
                        child: Text(
                          forYoudocumentSnapshot['brand'],
                          style: TextStyle(
                            color: Colors.lightGreen.shade400,
                            fontSize: MediaQuery.of(context).size.width * 0.032,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          "\৳ " + forYoudocumentSnapshot['product_price'].toString() + '.00',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width * 0.045,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
      ),
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Filter', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
                        MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          minWidth: 40,
                          height: 40,
                          color: Colors.grey.shade300,
                          elevation: 0,
                          padding: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)
                          ),
                          child: const Icon(Icons.close, color: Colors.black,),
                        )
                      ],
                    ),
                    // Slider Price Renge filter
                    const SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('প্রাইস রেঞ্জ', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('\৳ ${selectedRange.start.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12),),
                            Text(" - ", style: TextStyle(color: Colors.grey.shade500)),
                            Text('\৳ ${selectedRange.end.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12),),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    RangeSlider(
                        values: selectedRange,
                        min: 0.00,
                        max: 2000.00,
                        divisions: 100,
                        inactiveColor: Colors.grey.shade300,
                        activeColor: Colors.lightGreen[800],
                        labels: RangeLabels('\৳ ${selectedRange.start.toStringAsFixed(2)}', '\৳ ${selectedRange.end.toStringAsFixed(2)}',),
                        onChanged: (RangeValues values) {
                          setState(() => selectedRange = values);
                        }
                    ),
                    const SizedBox(height: 20,),
                    button('ফিল্টার করুন', () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FilterProductPage(rangeValues: selectedRange, address: address),
                        ),
                      );
                    })
                  ],
                ),
              );
            }
        );
      },
    );
  }

  Future<void> addToCartModal(DocumentSnapshot<Object?> documentSnapshot, BuildContext mContext) async {
    List<FarmerModel> farmerList = [];
    int? selectedFarmerIndex;
    selectedAmount = 1.0;

    List<dynamic> productOwners = documentSnapshot['product_owner'];
    farmerList = productOwners.map((owner) => FarmerModel(owner['name'], owner['uId'], false)).toList();

    return showModalBottomSheet(
      context: mContext,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 80, // Add padding to bottom for button space
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAmountSelector(setState),
                    const SizedBox(height: 10),
                    Text(
                      'ফারমার লিস্ট :',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Expanded( // Ensures ListView takes available space
                      child: ListView.builder(
                        itemCount: farmerList.length,
                        shrinkWrap: true,
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
              ),
              Positioned(
                bottom: 20, // Position the button at the bottom
                left: 20,
                right: 20,
                child: button('কার্টে যোগ করুন', () async {
                  // Your add to cart logic
                }),
              ),
            ],
          );
        },
      ),
    );
  }



  Widget _buildAmountSelector(void Function(void Function()) setState) {
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
}
