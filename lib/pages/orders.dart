import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_e_commerce_app/models/order_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String selectedStatus = 'সব';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: DropdownButton<String>(
          value: selectedStatus,
          onChanged: (String? newValue) {
            setState(() {
              selectedStatus = newValue!;
            });
          },
          items: <String>['সব', 'পেন্ডিং', 'অর্ডার নেয়া হয়েছে', 'অন দা ওয়ে', 'ডেলিভারি সম্পন্ন']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
      body: user == null
          ? const Center(child: Text('No user is currently logged in.'))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Order')
            .where('customerId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching orders.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('অর্ডার পাওয়া যায় নি.'));
          }

          List<OrderModel> orders = snapshot.data!.docs.map((doc) {
            return OrderModel.fromJson(doc.data() as Map<String, dynamic>);
          }).toList();

          List<OrderModel> filteredOrders = selectedStatus == 'সব'
              ? orders
              : orders.where((order) => order.orderStatus == selectedStatus).toList();

          return ListView.builder(
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              return OrderItem(orderModel: filteredOrders[index]);
            },
          );
        },
      ),
    );
  }
}

class OrderItem extends StatefulWidget {
  final OrderModel orderModel;

  const OrderItem({super.key, required this.orderModel});

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  double _rating = 0;
  bool _ratingSubmitted = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.orderModel.orderRating;
    _ratingSubmitted = widget.orderModel.orderRating > 0;
  }

  Future<void> _submitRating() async {
    setState(() {
      _ratingSubmitted = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('Order')
          .doc(widget.orderModel.orderId)
          .update({'orderRating': _rating});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('রেটিং সাবমিট করা হয়েছে'),
        ),
      );
    } catch (e) {
      setState(() {
        _ratingSubmitted = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('রেটিং সাবমিট করা যায় নি: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.orderModel.productName,
                  style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  'অর্ডার আইডি: ${widget.orderModel.orderId}',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('সরবরাহক: ${widget.orderModel.sellerName}'),
                    ],
                  ),
                ),
                Text(
                  'মোট দাম: \৳${widget.orderModel.total_price}',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('স্ট্যাটাস: ${widget.orderModel.orderStatus}'),
                          Text(
                            'পরিমাণ: ${widget.orderModel.product_amount}',
                            style: const TextStyle(fontSize: 14.0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0,
                          end: getStatusProgress(widget.orderModel.orderStatus),
                        ),
                        duration: const Duration(seconds: 1),
                        builder: (context, value, child) {
                          return LinearProgressIndicator(
                            value: value,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.orderModel.orderStatus == 'ডেলিভারি সম্পন্ন' && !_ratingSubmitted) ...[
              const SizedBox(height: 8.0),
              const Text('রেটিং দিন:'),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: _submitRating,
                child: const Text('সাবমিট'),
              ),
            ] else if (_ratingSubmitted) ...[
              const SizedBox(height: 8.0),
              RatingBarIndicator(
                rating: _rating,
                itemBuilder: (context, index) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 24.0,
              ),
            ],
          ],
        ),
      ),
    );
  }

  double getStatusProgress(String status) {
    switch (status) {
      case 'ডেলিভারি সম্পন্ন':
        return 1.0;
      case 'অন দা ওয়ে':
        return 0.66;
      case 'অর্ডার নেয়া হয়েছে':
        return 0.33;
      default: 'পেন্ডিং';
        return 0.0;
    }
  }
}

