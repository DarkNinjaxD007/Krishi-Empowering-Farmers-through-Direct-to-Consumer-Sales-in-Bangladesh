import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_e_commerce_app/pages/addproduct.dart';
import 'package:flutter_e_commerce_app/pages/cart.dart';
import 'package:flutter_e_commerce_app/pages/explore.dart';
import 'package:flutter_e_commerce_app/pages/farmer_order.dart';
import 'package:flutter_e_commerce_app/pages/profile.dart';
import 'package:flutter_e_commerce_app/pages/orders.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'firebase_options.dart';
import 'helpers/di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initAppModule();

  runApp(MaterialApp(
    home: const HomePage(),
    debugShowCheckedModeBanner: false,
    builder: EasyLoading.init(),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  int _selectedPage = 0;
  String? _userType;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  List<Widget> loggedOutPages = [
    const ExplorePage(),
    const ProfilePage(),
  ];

  List<Widget> consumerPages = [
    const ExplorePage(),
    const OrdersPage(),
    const CartPage(),
    const ProfilePage(),
  ];

  List<Widget> farmerPages = [
    AddFarmerProductPage(),
    const FarmerOrdersPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedPage = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    _checkLoginStatus();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _checkLoginStatus();
    });
    super.initState();
  }

  Future<void> _checkLoginStatus() async {
    if(mounted){
    setState(() {
      _isLoading = true;
    });}

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _isLoggedIn = true;
      await _fetchUserType(user);
    } else {
      _isLoggedIn = false;
      _userType = null;
    }
    if(mounted) {
      setState(() {
        _isLoading = false;
        _updatePagesBasedOnUserStatus();
      });
    }
  }

  Future<void> _fetchUserType(User user) async {
    try {
      print("Fetching user type for UID: ${user.uid}");
      final docRef = FirebaseFirestore.instance.collection('user').doc(user.uid);
      final doc = await docRef.get();

      if (doc.exists) {
        _userType = doc.data()?['type'] as String?;
        print("User type found: $_userType");
      } else {
        print("User document not found for UID: ${user.uid}");
        _userType = 'consumer'; // Default type if document does not exist
      }
    } catch (e) {
      print("Error fetching user type: $e");
      _userType = 'consumer'; // Default type in case of error
    }
  }

  void _updatePagesBasedOnUserStatus() {
    _selectedPage = 0; // Always reset to the first page when status changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(_selectedPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = !_isLoggedIn ? loggedOutPages : (_userType == 'farmer' ? farmerPages : consumerPages);

    return Scaffold(
      body: PageView(
        onPageChanged: (index) => setState(() {
          _selectedPage = index;
        }),
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: pages,
      ),
      bottomNavigationBar: FlashyTabBar(
        selectedIndex: _selectedPage,
        showElevation: false,
        onItemSelected: (index) => _onItemTapped(index),
        items: _getTabBarItems(),
      ),
    );
  }

  List<FlashyTabBarItem> _getTabBarItems() {
    if (!_isLoggedIn) {
      return [
        FlashyTabBarItem(
          icon: const Icon(Icons.home_outlined, size: 23),
          title: const Text('হোম'),
        ),
        FlashyTabBarItem(
          icon: const Icon(Icons.account_circle_outlined, size: 23),
          title: const Text('প্রোফাইল'),
        ),
      ];
    } else if (_userType == 'farmer') {
      return [
        FlashyTabBarItem(
          icon: const Icon(Icons.home_outlined, size: 23),
          title: const Text('হোম'),
        ),
        FlashyTabBarItem(
          icon: const Icon(Icons.local_grocery_store_outlined, size: 23),
          title: const Text('অর্ডার গুলো'),
        ),
        FlashyTabBarItem(
          icon: const Icon(Icons.account_circle_outlined, size: 23),
          title: const Text('প্রোফাইল'),
        ),
      ];
    } else {
      return [
        FlashyTabBarItem(
          icon: const Icon(Icons.home_outlined, size: 23),
          title: const Text('হোম'),
        ),
        FlashyTabBarItem(
          icon: const Icon(Icons.local_grocery_store_outlined, size: 23),
          title: const Text('অর্ডার গুলো'),
        ),
        FlashyTabBarItem(
          icon: const Icon(Icons.shopping_bag_outlined, size: 23),
          title: const Text('কার্ট'),
        ),
        FlashyTabBarItem(
          icon: const Icon(Icons.account_circle_outlined, size: 23),
          title: const Text('প্রোফাইল'),
        ),
      ];
    }
  }
}