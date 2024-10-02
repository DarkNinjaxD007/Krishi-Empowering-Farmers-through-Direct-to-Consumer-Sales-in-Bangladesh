import 'dart:convert';

String orderModelListToJson(List<OrderModel> data) {
  final jsonData = data.map((item) => item.toJson()).toList();
  return json.encode(jsonData);
}
class OrderModel {
  final String orderId;
  final String sellerId;
  final String customerId;
  final String customerName;
  final String phoneNumber;
  final String productName;
  final String sellerName;
  final String product_amount;
  final int product_price;
  String total_price;
  String orderStatus;
  String paymentType;
  String shippingAddress;
  double orderRating;

  OrderModel(
      this.orderId,
      this.sellerId,
      this.customerId,
      this.customerName,
      this.phoneNumber,
      this.productName,
      this.sellerName,
      this.product_amount,
      this.product_price,
      this.total_price,
      this.orderStatus,
      this.paymentType,
      this.shippingAddress,
      this.orderRating,
      );

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
        json["orderId"] as String,
        json["sellerId"] as String,
        json["customerId"] as String,
        json["customerName"] as String,
        json["phoneNumber"] as String,
        json["productName"] as String,
        json["sellerName"] as String,
        json["product_amount"] as String,
        json["product_price"] as int,
        json["total_price"] as String,
        json["orderStatus"] as String,
        json["paymentType"] as String,
        json["shippingAddress"] as String,
        (json['orderRating'] as num).toDouble()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "sellerId": productName,
      "customerId": customerId,
      "customerName": customerName,
      "phoneNumber": phoneNumber,
      "productName": productName,
      "sellerName": sellerName,
      "product_amount": product_amount,
      "product_price": product_price,
      "total_price": total_price,
      "orderStatus": orderStatus,
      "paymentType": paymentType,
      "shippingAddress": shippingAddress,
      "orderRating": orderRating,
    };
  }

  @override
  String toString() {
    return 'OrderModel{orderId: $orderId, sellerId: $sellerId, customerId: $customerId, customerName: $customerName, phoneNumber: $phoneNumber, productName: $productName, sellerName: $sellerName, product_amount: $product_amount, product_price: $product_price, total_price: $total_price, orderStatus: $orderStatus, paymentType: $paymentType, shippingAddress: $shippingAddress, orderRating: $orderRating}';
  }
}
