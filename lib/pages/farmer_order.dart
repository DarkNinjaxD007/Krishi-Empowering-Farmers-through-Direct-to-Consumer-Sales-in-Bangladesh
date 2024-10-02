import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_e_commerce_app/models/order_model.dart';

class FarmerOrdersPage extends StatefulWidget {
  const FarmerOrdersPage({Key? key}) : super(key: key);

  @override
  _FarmerOrdersPageState createState() => _FarmerOrdersPageState();
}

class _FarmerOrdersPageState extends State<FarmerOrdersPage> {
  String selectedStatus = 'সব';
  String userFullName = "";


  @override
  void initState() {
    super.initState();
    getFarmerName();
  }

  Future<void> getFarmerName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('user').doc(user.uid).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      setState(() {
        userFullName = userData['fullName'] as String;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseAuth.instance.currentUser?.uid != null
            ? FirebaseFirestore.instance
            .collection('Order')
            .where('sellerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid.toString())
            .snapshots()
            : null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching orders.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('অর্ডার পাওয়া যায় নি'));
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
              return FarmerOrderItem(orderModel: filteredOrders[index]);
            },
          );
        },
      ),
    );
  }
}

class FarmerOrderItem extends StatefulWidget {
  final OrderModel orderModel;

  const FarmerOrderItem({super.key, required this.orderModel});

  @override
  _FarmerOrderItemState createState() => _FarmerOrderItemState();
}

class _FarmerOrderItemState extends State<FarmerOrderItem> {
  bool _isLoading = false;

  Future<void> _updateOrderStatus(String newStatus) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('Order')
          .doc(widget.orderModel.orderId)
          .update({'orderStatus': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অর্ডার স্ট্যাটাস আপডেট করা হয়েছে')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('স্ট্যাটাস আপডেট করা যায় নি: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
            Text(
              widget.orderModel.productName,
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text('অর্ডার আইডি: ${widget.orderModel.orderId}'),
            const SizedBox(height: 8.0),
            Text('কাস্টমার: ${widget.orderModel.customerName}'),
            const SizedBox(height: 8.0),
            Text('ফোন নাম্বার: ${widget.orderModel.phoneNumber}'),
            const SizedBox(height: 8.0),
            widget.orderModel.shippingAddress.isNotEmpty ?
            Text('ডেলিভারি ঠিকানা: ${widget.orderModel.shippingAddress}') : const SizedBox(height: 1.0),
            const SizedBox(height: 8.0),
            Text('পরিমান: ${widget.orderModel.product_amount}'),
            const SizedBox(height: 8.0),
            Text('মোট দাম: \৳${widget.orderModel.total_price}'),
            const SizedBox(height: 8.0),
            Text('স্ট্যাটাস: ${widget.orderModel.orderStatus}'),
            const SizedBox(height: 8.0),
            if (widget.orderModel.orderStatus == 'পেন্ডিং')
              ElevatedButton(
                onPressed: _isLoading ? null : () => _updateOrderStatus('অর্ডার নেয়া হয়েছে'),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('কনফার্ম অর্ডার'),
              ),
            if (widget.orderModel.orderStatus == 'অর্ডার নেয়া হয়েছে')
              ElevatedButton(
                onPressed: _isLoading ? null : () => _updateOrderStatus('অন দা ওয়ে'),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('অর্ডার ছেড়ে দিন'),
              ),
            if (widget.orderModel.orderStatus == 'অন দা ওয়ে')
              ElevatedButton(
                onPressed: _isLoading ? null : () => _updateOrderStatus('ডেলিভারি সম্পন্ন'),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('ডেলিভারি সম্পন্ন'),
              ),
          ],
        ),
      ),
    );
  }
}
