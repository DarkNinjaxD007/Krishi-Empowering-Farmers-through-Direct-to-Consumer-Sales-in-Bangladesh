import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_e_commerce_app/models/order_model.dart';

import '../models/product.dart';

class FirestoreServices {


  static saveUser(String name, email, password, dynamic uid, String address,
      phoneNumber, String role, String profilePhotoUrl) async {
    await FirebaseFirestore.instance.collection('user').doc(uid).set({
      'uId': uid,
      'email': email,
      'password': password,
      'fullName': name,
      'address': address,
      'phone_number': phoneNumber,
      'type': role,
      'profilePhotoUrl': profilePhotoUrl,
    });
  }

  static addItemToCart(
      dynamic userId,
      String pId,
      String productName,
      String brand,
      dynamic price,
      String productImg,
      String productAmount,
      String totalPrice,
      String sellerName,
      String sellerId,
      BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .collection('cart_item')
        .doc(pId.toString())
        .set({
      'uid': pId,
      'product_name': productName,
      'brand': brand,
      'price': price,
      'product_img': productImg,
      'product_amount': productAmount,
      'total_price': totalPrice,
      'sellerName': sellerName,
      'sellerId': sellerId,
    });
  }

  static saveOrders(OrderModel order) async {
    try {
      await FirebaseFirestore.instance
          .collection('Order')
          .doc(order.orderId)
          .set({
        'orderId': order.orderId,
        'sellerId': order.sellerId,
        'customerId': order.customerId,
        'customerName': order.customerName,
        'phone_number' : order.phoneNumber,
        'productName': order.productName,
        'sellerName': order.sellerName,
        'product_amount': order.product_amount,
        'product_price': order.product_price,
        'total_price': order.total_price,
        'orderStatus': order.orderStatus,
        'paymentType': order.paymentType,
        'shippingAddress': order.shippingAddress,
        'orderRating': order.orderRating,
      });
      if (kDebugMode) {
        print('Order saved successfully.');
      }
    } catch (e) {
      print('Failed to save order: $e');
    }
  }


 static Future<void> removeAllCartItemsFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final cartCollection = FirebaseFirestore.instance
            .collection("user")
            .doc(user.uid)
            .collection("cart_item");

        final snapshot = await cartCollection.get();

        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }

        if (kDebugMode) {
          print('All items removed from Firestore successfully.');
        }
      } else {
        if (kDebugMode) {
          print('No user is currently logged in.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing all items from Firestore: $e');
      }
    }
  }


 static Future<void> removeItemFromFirestore(Product product) async {
    try {
      await FirebaseFirestore.instance
          .collection("user")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("cart_item")
          .doc(product.uid)
          .delete();
      if (kDebugMode) {
        print('Item removed from Firestore successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing item from Firestore: $e');
      }
    }
  }

 static Future<void> updateItemInFirestore(Product product) async {
    try {
      await FirebaseFirestore.instance
          .collection("user")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("cart_item")
          .doc(product.uid)
          .update(product.toJson());
      if (kDebugMode) {
        print('Item updated in Firestore successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating item in Firestore: $e');
      }
    }
  }



}