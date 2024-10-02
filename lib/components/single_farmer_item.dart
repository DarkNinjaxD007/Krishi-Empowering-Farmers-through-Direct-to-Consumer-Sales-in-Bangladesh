import 'package:flutter/material.dart';
import 'package:flutter_e_commerce_app/models/farmer_model.dart';

class SingleFarmerItem extends StatefulWidget {
  final int index;
  final FarmerModel farmer;
  final Function(int) onSelected;

  const SingleFarmerItem({
    Key? key,
    required this.index,
    required this.farmer,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<SingleFarmerItem> createState() => _SingleFarmerItemState();
}

class _SingleFarmerItemState extends State<SingleFarmerItem> {


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onSelected(widget.index);
      },
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.8,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: widget.farmer.isFarmerSelected ? Colors.lightGreen[800] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.farmer.isFarmerSelected ? Colors.green : Colors.grey,
          ),
        ),
        child: Text(
          textAlign: TextAlign.center,
          widget.farmer.farmerName,
          style: TextStyle(
            fontSize: 16,
            color: widget.farmer.isFarmerSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
