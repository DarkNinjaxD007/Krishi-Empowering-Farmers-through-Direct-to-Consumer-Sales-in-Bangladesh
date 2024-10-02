import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_e_commerce_app/service/firestore_service.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../animation/FadeAnimation.dart';
import '../models/product.dart';
import 'payment.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with TickerProviderStateMixin {
  late List<Product> cartItems = [];
  int totalPrice = 0;

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  Future<void> fetchItems() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    var query = await FirebaseFirestore.instance
        .collection("user")
        .doc(user.uid)
        .collection("cart_item")
        .get();
    for (var cartItem in query.docs) {
      Product product = Product.fromJson(cartItem.data() as Map<String, dynamic>);
      cartItems.add(product);
    }

    if (mounted) {
      setState(() {
        totalPrice = cartItems.fold(0, (sum, item) => sum + double.parse(item.total_price).toInt());
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text('কার্ট', style: TextStyle(color: Colors.black)),
        ),
        body: const Center(child: Text('No user is currently logged in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('কার্ট', style: TextStyle(color: Colors.black)),
      ),
      body: cartItems.isNotEmpty ? buildCartContent() : buildEmptyCart(),
    );
  }

  Widget buildCartContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: MediaQuery.of(context).size.height * 0.5,
            child: FadeAnimation(
              1.4,
              AnimatedList(
                key: _listKey,
                scrollDirection: Axis.vertical,
                initialItemCount: cartItems.length,
                itemBuilder: (context, index, animation) {
                  return Slidable(
                    key: Key(cartItems[index].toString()),
                    startActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (BuildContext context) {
                            removeItem(index);
                          },
                          backgroundColor: Colors.red.withOpacity(0.15),
                          foregroundColor: Colors.red,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: cartItem(cartItems[index], index, animation),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          FadeAnimation(
            1.2,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('শিপিং চার্জ + প্লাটফর্ম ফি', style: TextStyle(fontSize: 18)),
                  Text('\৳80 + 5', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          FadeAnimation(
            1.3,
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: DottedBorder(
                color: Colors.grey.shade400,
                dashPattern: const [10, 10],
                padding: const EdgeInsets.all(0),
                child: Container(),
              ),
            ),
          ),
          FadeAnimation(
            1.3,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('মোট', style: TextStyle(fontSize: 18)),
                  Text('\৳${totalPrice + 85}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          FadeAnimation(
            1.4,
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: MaterialButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPage(cartItems: cartItems, totalPrice: totalPrice.toDouble(),)));
                },
                height: 45,
                elevation: 0,
                splashColor: Colors.lightGreen[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.lightGreen[800],
                child: const Center(
                  child: Text(
                    "চেকআউট",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'আপনার কার্টে কিছু নেই',
            style: TextStyle(fontSize: 24, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void removeItem(int index) async {
    if (index < 0 || index >= cartItems.length) return;

    final removedProduct = cartItems[index];

    if (_listKey.currentState != null) {
      _listKey.currentState!.removeItem(
        index,
            (context, animation) => SizeTransition(
          sizeFactor: animation,
          child: cartItem(cartItems[index], index, animation),
        ),
        duration: const Duration(milliseconds: 300),
      );
    }

    await FirestoreServices.removeItemFromFirestore(removedProduct);
    totalPrice -= int.parse(cartItems[index].total_price);
    cartItems.removeAt(index);
    if (mounted) {
      setState(() {});
    }
  }

  Widget cartItem(Product product, int index, Animation<double> animation) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(context, MaterialPageRoute(builder: (context) => ProductViewPage(product: product)));
      },
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    product.product_img,
                    fit: BoxFit.cover,
                    height: 80,
                    width: 80,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.productBrand,
                      style: TextStyle(
                        color: Colors.lightGreen.shade400,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '\৳${product.product_price}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product.sellerName,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  buildQuantityButtons(product, index),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildQuantityButtons(Product product, int index) {
    return Row(
      children: <Widget>[
        buildQuantityButton(Icons.remove, product, index, false),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            product.product_amount,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        buildQuantityButton(Icons.add, product, index, true),
      ],
    );
  }

  Widget buildQuantityButton(IconData icon, Product product, int index, bool increment) {
    return GestureDetector(
      onTap: () {
        setState(() {
          int currentAmount = int.parse(product.product_amount);
          if (increment) {
            currentAmount++;
            totalPrice += product.product_price;
          } else {
            if (currentAmount > 1) {
              currentAmount--;
              totalPrice -= product.product_price;
            }
          }
          product.product_amount = currentAmount.toString();
          product.total_price = (currentAmount * product.product_price).toString();
          FirestoreServices.updateItemInFirestore(product);
        });
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}
