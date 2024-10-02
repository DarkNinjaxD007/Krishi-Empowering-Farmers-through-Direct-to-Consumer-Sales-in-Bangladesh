class Product {
  final String uid;
  final String productName;
  final String productBrand;
  final String product_img;
  final String sellerName;
  final String sellerId;
  String product_amount;
  final int product_price;
  String total_price;

  Product(
      this.uid,
      this.productName,
      this.productBrand,
      this.product_img,
      this.sellerName,
      this.sellerId,
      this.product_amount,
      this.product_price,
      this.total_price
      );

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        json["uid"] as String,
        json["product_name"] as String,
        json["brand"] as String,
        json["product_img"] as String,
        json["sellerName"] as String,
        json["sellerId"] as String,
        json["product_amount"] as String,
        json["price"] as int,
        json["total_price"] as String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "productName": productName,
      "productBrand": productBrand,
      "product_img": product_img,
      "sellerName": sellerName,
      "sellerId": sellerId,
      "product_amount": product_amount,
      "product_price": product_price,
      "total_price": total_price
    };
  }

  @override
  String toString() {
    return 'Product{uid: $uid, productName: $productName, productBrand: $productBrand, product_img: $product_img, sellerName: $sellerName, sellerId: $sellerId, product_amount: $product_amount, product_price: $product_price, total_price: $total_price}';
  }
}
