import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  late String name;
  late String sellerId;
  late String buyerId;
  late String sellerName;
  late String buyerName;
  late Timestamp timestamp;
  late List<double> coordinates;

  Item({this.name = "", this.sellerId = "", this.buyerId = "", this.sellerName = "", this.buyerName = "", required this.timestamp, this.coordinates = const []});

  Map<String, dynamic> toMap () {
    return {
      'name': name,
      'sellerId': sellerId,
      'buyerId': buyerId,
      'sellerName': sellerName,
      'buyerName': buyerName,
      'timestamp': timestamp,
      'coordinates': coordinates
    };
  }
}