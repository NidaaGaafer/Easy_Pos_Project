import 'package:my_easy_pos/models/products_data.dart';

class OrderItemData {
  int? orderId;
  int? productId;
  int? productCount;
  ProductData? productData;

  OrderItemData(
      {this.orderId, this.productCount, this.productData, this.productId});

  OrderItemData.fromJson(Map<String, dynamic> data) {
    orderId = data['orderId'];
    productId = data['productId'];
    productCount = data['productCount'];
    productData = ProductData.fromJson(data);
  }
}
