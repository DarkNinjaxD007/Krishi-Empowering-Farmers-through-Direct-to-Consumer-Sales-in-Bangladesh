import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../helpers/network_info.dart';
import '../models/order_model.dart';
import '../models/product.dart';
import '../service/firestore_service.dart';
import 'order_success.dart';

class PaymentPage extends StatefulWidget {
  final List<Product> cartItems;
  final double totalPrice;

  const PaymentPage({Key? key, required this.cartItems, required this.totalPrice}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedPaymentMethod;
  bool _isLoading = false;
  TextEditingController addressController = new TextEditingController();
  late NetworkInfo _networkInfo;


  @override
  void initState() {
    _networkInfo = NetworkInfoImpl(InternetConnectionChecker());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('চেকআউট', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('মোট পরিশোধ করতে হবে', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('৳${widget.totalPrice + 85}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              const Text('পেমেন্ট পদ্ধতি নির্বাচন করুন', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              buildPaymentOption(context, "1",'ক্যাশ ওন ডেলিভারি', Icons.account_balance),
              buildPaymentOption(context, "2", 'অনলাইন পেমেন্ট', Icons.money),
             /* buildPaymentOption(context, 'ক্রেডিট কার্ড', Icons.credit_card),
              buildPaymentOption(context, 'ক্যাশ অন ডেলিভারি', Icons.money),*/
              const SizedBox(height: 30),
              const Text('ঠিকানা দিন', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8,),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'ঠিকানা',
                  hintText: 'ঠিকানা লিখুন',
                ),
              ),
              const SizedBox(height: 30),
              MaterialButton(
                onPressed: () async{
                  if(addressController.text.isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('অর্ডার এর ঠিকানা দিন')));
                    return;
                  }
                  if(selectedPaymentMethod != null && selectedPaymentMethod == "1"){

                    if(!await _networkInfo.isConnected){
                      const snackbar = SnackBar(
                        content: Text("No internet available!"),
                        duration: Duration(seconds: 5),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      return;
                    }
                    await confirmOrder(widget.cartItems, "");
                  }else if(selectedPaymentMethod != null && selectedPaymentMethod == "2"){

                    if(!await _networkInfo.isConnected){
                      const snackbar = SnackBar(
                        content: Text("No internet available!"),
                        duration: Duration(seconds: 5),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      return;
                    }

                    String cartItemName = widget.cartItems.map((product) => product.productName).join(', ');

                    Sslcommerz sslcommerz = Sslcommerz(
                        initializer: SSLCommerzInitialization(
                            currency: SSLCurrencyType.BDT,
                            product_category: cartItemName,
                            multi_card_name: "visa,master,bkash",
                            sdkType: SSLCSdkType.TESTBOX,
                            store_id: "mobil5fe45035efe16",
                            store_passwd: "mobil5fe45035efe16@ssl",
                            total_amount: widget.totalPrice + 85,
                            tran_id: DateTime.now().millisecondsSinceEpoch.toString()));

                    try {
                      SSLCTransactionInfoModel result = await sslcommerz.payNow();
                      if (result is PlatformException) {
                        debugPrint(result.status);
                      } else {
                        if (result.status!.toLowerCase() == "failed") {
                          print('Transaction is Failed....');
                          await Fluttertoast.showToast(
                              msg: "Transaction is Failed....",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else {
                          if(result.status!.toLowerCase() == "closed"){
                            await Fluttertoast.showToast(
                              msg:
                              "পেমেন্ট সফল হয়নি",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          }else{
                            await confirmOrder(widget.cartItems, result.cardType.toString() );
                            await Fluttertoast.showToast(
                              msg:
                              "Transaction is ${result.status} and Amount is ${result.amount}",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          }
                        }
                      }
                    } catch (e) {
                      debugPrint(e.toString());
                    }

                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a payment method')),
                    );
                  }
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
                    "পরিশোধ করুন",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPaymentOption(BuildContext context,String id, String title, IconData icon) {
    final isSelected = selectedPaymentMethod == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = id;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? Colors.lightGreen[50] : Colors.white,
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: isSelected ? Colors.lightGreen[800] : Colors.grey),
            const SizedBox(width: 15),
            Text(title, style: TextStyle(fontSize: 18, color: isSelected ? Colors.lightGreen[800] : Colors.black)),
          ],
        ),
      ),
    );
  }



  Future<void> confirmOrder(List<Product> cartItems, String cardType) async{

    setState(() {
      _isLoading = true;
    });

    for(Product product in cartItems){
      var timeStamp  = DateTime.now().millisecondsSinceEpoch;
      FirestoreServices.saveOrders(OrderModel(timeStamp.toString(), product.sellerId, FirebaseAuth.instance.currentUser!.uid,FirebaseAuth.instance.currentUser!.displayName!,FirebaseAuth.instance.currentUser!.phoneNumber!,product.productName, product.sellerName, product.product_amount, product.product_price, product.total_price, "Pending", selectedPaymentMethod == 1 && cardType.isEmpty ? "ক্যাশ ওন ডেলিভারি": cardType, addressController.text.toString(), 0));
    }
    FirestoreServices.removeAllCartItemsFromFirestore();

    setState(() {
      _isLoading = false;
    });
    if(!_isLoading){
      Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderSuccess()));
    }


  }
}
