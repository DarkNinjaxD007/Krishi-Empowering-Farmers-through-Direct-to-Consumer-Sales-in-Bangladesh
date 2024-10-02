
import 'dart:convert';

String farmerModel(FarmerModel farmerModel) => json.encode(farmerModel.toJson());

class FarmerModel {
  final String farmerName;
  final String farmerId;
  bool isFarmerSelected;

  FarmerModel( this.farmerName, this.farmerId, this.isFarmerSelected);

  // Convert a FarmerModel object into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'farmerName': farmerName,
      'farmerId': farmerId,
      'isFarmerSelected': isFarmerSelected,
    };
  }

  // Create a FarmerModel object from a JSON map.
  factory FarmerModel.fromJson(Map<String, dynamic> json) {
    return FarmerModel(
      json['farmerName'] as String,
      json['farmerId'] as String,
      json['isFarmerSelected'] as bool,
    );
  }
}
