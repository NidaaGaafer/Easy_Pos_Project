class ExchangeRateData {
  int? id;
  double? usd;
  double? sar;
  ExchangeRateData.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    usd = data['usd'];
    sar = data['sar'];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "usd": usd,
      "sar": sar,
    };
  }
}
