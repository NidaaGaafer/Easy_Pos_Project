class OrderData {
  int? id;
  String? lebel;
  double? totalPrice;
  double? discount;
  int? clientId;
  String? clientName;
  String? clientPhone;
  String? clientAddress;
  OrderData(
      {this.id,
      this.lebel,
      this.totalPrice,
      this.discount,
      this.clientId,
      this.clientName,
      this.clientPhone,
      this.clientAddress});

  OrderData.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    lebel = data['label'];
    totalPrice = data['totalPrice'];
    discount = data['discount'];
    clientId = data['clientId'];
    clientName = data['clientName'];
    clientPhone = data['clientPhone'];
    clientAddress = data['clientAddress'];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "label": lebel,
      "totalPrice": totalPrice,
      "discount": discount,
      "clientId": clientId,
    };
  }
}
