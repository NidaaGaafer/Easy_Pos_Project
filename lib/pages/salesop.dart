import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:my_easy_pos/helpers/sql_helpert.dart';
import 'package:my_easy_pos/models/clients_data.dart';
import 'package:my_easy_pos/models/ordar_data.dart';
import 'package:my_easy_pos/models/order_item_data.dart';
import 'package:my_easy_pos/models/products_data.dart';
import 'package:my_easy_pos/widgets/button.dart';
import 'package:my_easy_pos/widgets/textfiled.dart';

class SaleOpsPage extends StatefulWidget {
  final OrderData? order;
  const SaleOpsPage({this.order, super.key});

  @override
  State<SaleOpsPage> createState() => _SaleOpsPageState();
}

class _SaleOpsPageState extends State<SaleOpsPage> {
  String? orderLabel;
  double? orderPrice;
  List<ProductData>? products;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<ClientData>? clients;
  List<OrderData> orders = [];
  List<OrderItemData> selectedOrderItem = [];
  var discountController = TextEditingController();

  @override
  void initState() {
    initPage();
    super.initState();
  }

  void initPage() {
    orderLabel = widget.order == null
        ? '#OR${DateTime.now().millisecondsSinceEpoch}'
        : widget.order?.id.toString();
    getProducts();
    getClientData();
    // getOrders();
  }

  void getProducts() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelpert>();
      var data = await sqlHelper.db!.rawQuery("""
      select P.* ,C.name as categoryName,C.description as categoryDesc 
      from products P
      inner join categories C
      where P.categoryId = C.id
      """);

      if (data.isNotEmpty) {
        products = [];
        for (var item in data) {
          products!.add(ProductData.fromJson(item));
        }
      } else {
        products = [];
      }
    } catch (e) {
      print('Error In get data $e');
      products = [];
    }
    setState(() {});
  }

  void getClientData() async {
    try {
      var sqlHelpert = GetIt.I.get<SqlHelpert>();
      var data = await sqlHelpert.db!.query('clients');

      if (data.isNotEmpty) {
        clients = [];
        for (var item in data) {
          clients!.add(ClientData.fromJson(item));
        }
      } else {
        clients = [];
      }
    } catch (e) {
      clients = [];
      print('error when get data $e');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.order == null ? 'Add New Sale' : 'Update Sale'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Label : $orderLabel',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                onAddClientClicked();
                              },
                              icon: Icon(Icons.add)),
                          Text(
                            'Add Client',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                onAddProductClicked();
                              },
                              icon: Icon(Icons.add)),
                          Text(
                            'Add Products',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Order Items',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      for (var orderItem in selectedOrderItem)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: Image.asset(
                              'assets/${orderItem.productData?.image ?? ''}',
                              height: 50,
                              width: 50,
                              fit: BoxFit.contain,
                            ),
                            title: Text(
                                '${orderItem.productData?.name ?? ''},${orderItem.productCount}X'),
                            trailing: Text(
                                '${(orderItem.productCount ?? 0) * (orderItem.productData?.price ?? 0)}'),
                          ),
                        ),
                      ////////////////////////////////////////////////
                      for (var order in orders)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: Text(
                              "${order.clientName ?? ''}",
                              style: TextStyle(fontSize: 20),
                            ),
                            title: Text(
                              "${order.clientAddress ?? ''}",
                            ),
                            subtitle: Text("${order.clientPhone ?? ''}"),
                          ),
                        ),
                      /////////////////////////////////////
                      Container(
                        child: Column(
                          children: [
                            Form(
                              key: formKey,
                              child: AppTextField(
                                label: 'discount %',
                                keyboardType: TextInputType.number,
                                inputformatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                controller: discountController!,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "price is required";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                            SizedBox(height: 10),
                            MyButton(
                                description: 'Submit',
                                onPressed: () {
                                  getDiscunt;
                                })
                          ],
                        ),
                        //child: Text('TODO: add discount textfield'),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Total Price : $calculateTotalPrice',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Total Price After Discount : $calculateDiscountPrice',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              MyButton(
                  onPressed: orders.isEmpty && selectedOrderItem.isEmpty
                      ? null
                      : () async {
                          await onSetOrder();
                        },
                  description: 'Add Order')
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onSetOrder() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelpert>();
      var orderId;
      if (widget.order != null) {
        for (var orderClient in orders) {
          orderId = await sqlHelper.db!.update(
              'orders',
              {
                'label': orderLabel,
                'discount': calculateDiscountPrice,
                'totalPrice': calculateTotalPrice,
                'clientId': orderClient.clientId
              },
              where: 'id =?',
              whereArgs: [widget.order?.id]);
        }
        var batch = sqlHelper.db!.batch();
        for (var orderItem in selectedOrderItem) {
          batch.update(
              'orderItems',
              {
                'orderId': orderId,
                'productId': orderItem.productId,
                'productCount': orderItem.productCount ?? 0,
              },
              where: 'id =?',
              whereArgs: [widget.order?.id]);
        }
        await batch.commit();
      } else {
        for (var orderClient in orders) {
          orderId = await sqlHelper.db!.insert('orders', {
            'label': orderLabel,
            'discount': calculateDiscountPrice,
            'totalPrice': calculateTotalPrice,
            'clientId': orderClient.clientId
          });
        }
        var batch = sqlHelper.db!.batch();
        for (var orderItem in selectedOrderItem) {
          batch.insert('orderItems', {
            'orderId': orderId,
            'productId': orderItem.productId,
            'productCount': orderItem.productCount ?? 0,
          });
        }
        await batch.commit();
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text('Order Set Successfully')));
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error In Create Order : $e')));
      print('Error In Create Order : $e');
    }
  }

  double get calculateTotalPrice {
    double total = 0;

    for (var orderItem in selectedOrderItem) {
      total = total +
          ((orderItem.productCount ?? 0) * (orderItem.productData?.price ?? 0));
    }

    return total;
  }

  double get todaySales {
    var totaTodaySales = 0.0;
    for (var i = 0; i < orders.length; i = i + 1) {
      totaTodaySales = totaTodaySales + (orders[i].totalPrice ?? 0);
    }

    return totaTodaySales;
  }

  String get getDiscunt {
    String discountRate;

    discountRate = discountController.text;
    setState(() {});
    return discountRate;
  }

  double get calculateDiscountPrice {
    double discount = 0;
    var discountRate = double.tryParse(getDiscunt) ?? 0;
    var totalPrice = calculateTotalPrice;
    discount = totalPrice - (totalPrice * (discountRate / 100));
    return discount;
  }

  void onAddProductClicked() async {
    await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStateEx) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: (products?.isEmpty ?? false)
                    ? Center(
                        child: Text('No Data Found'),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Products',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: ListView(
                              children: [
                                for (var product in products!)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: ListTile(
                                      leading: Image.asset(
                                        'assets/${product.image}',
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.contain,
                                      ),
                                      title: Text(product.name ?? 'No Name'),
                                      subtitle: getOrderItem(product.id!) ==
                                              null
                                          ? null
                                          : Row(
                                              children: [
                                                IconButton(
                                                    onPressed: getOrderItem(
                                                                    product
                                                                        .id!) !=
                                                                null &&
                                                            getOrderItem(product
                                                                        .id!)
                                                                    ?.productCount ==
                                                                1
                                                        ? null
                                                        : () {
                                                            var orderItem =
                                                                getOrderItem(
                                                                    product
                                                                        .id!);

                                                            orderItem
                                                                    ?.productCount =
                                                                (orderItem.productCount ??
                                                                        0) -
                                                                    1;
                                                            setStateEx(() {});
                                                          },
                                                    icon: Icon(Icons.remove)),
                                                Text(getOrderItem(product.id!)!
                                                    .productCount
                                                    .toString()),
                                                IconButton(
                                                    onPressed: () {
                                                      var orderItem =
                                                          getOrderItem(
                                                              product.id!);

                                                      if ((orderItem
                                                                  ?.productCount ??
                                                              0) <
                                                          (product.stock ??
                                                              0)) {
                                                        orderItem
                                                                ?.productCount =
                                                            (orderItem.productCount ??
                                                                    0) +
                                                                1;
                                                      }

                                                      setStateEx(() {});
                                                    },
                                                    icon: Icon(Icons.add)),
                                              ],
                                            ),
                                      trailing:
                                          getOrderItem(product.id!) == null
                                              ? IconButton(
                                                  onPressed: () {
                                                    onAddItem(product);
                                                    setStateEx(() {});
                                                  },
                                                  icon: Icon(Icons.add))
                                              : IconButton(
                                                  onPressed: () {
                                                    onDeleteItem(product.id!);
                                                    setStateEx(() {});
                                                  },
                                                  icon: Icon(Icons.delete)),
                                    ),
                                  )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          MyButton(
                              onPressed: () {
                                Navigator.pop(context);
                                orderPrice = calculateDiscountPrice;
                              },
                              description: 'Back')
                        ],
                      ),
              ),
            );
          });
        });

    setState(() {});
  }

//===============================================================
  void onAddClientClicked() async {
    await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStateEx1) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: (clients?.isEmpty ?? false)
                    ? Center(
                        child: Text('No Data Found'),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Clients',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: ListView(
                              children: [
                                for (var client in clients!)
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: ListTile(
                                          leading:
                                              Text(client.name ?? 'No Name'),
                                          title: Text(
                                              client.address ?? 'No Address'),
                                          subtitle:
                                              Text(client.phone ?? 'No Phone'),
                                          trailing: getClientItem(client.id!) ==
                                                  null
                                              ? IconButton(
                                                  onPressed: () {
                                                    onAddClient(client);
                                                    setStateEx1(() {});
                                                  },
                                                  icon: Icon(Icons.add))
                                              : IconButton(
                                                  onPressed: () {
                                                    onDeleteClient(client.id!);
                                                    setStateEx1(() {});
                                                  },
                                                  icon: Icon(Icons.delete))))
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          MyButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              description: 'Back')
                        ],
                      ),
              ),
            );
          });
        });

    setState(() {});
  }

  OrderItemData? getOrderItem(int productId) {
    for (var item in selectedOrderItem) {
      if (item.productId == productId) {
        return item;
      }
    }
    return null;
  }

  void onAddItem(ProductData product) {
    selectedOrderItem.add(OrderItemData(
        productId: product.id, productCount: 1, productData: product));
  }

  void onDeleteItem(int productId) {
    for (var i = 0; i < (selectedOrderItem.length); i++) {
      if (selectedOrderItem[i].productId == productId) {
        selectedOrderItem.removeAt(i);
        break;
      }
    }
  }
///////////////////////////////////

  OrderData? getClientItem(int clienttId) {
    for (var item in orders) {
      if (item.clientId == clienttId) {
        return item;
      }
    }
    return null;
  }

  void onAddClient(ClientData client) {
    orders.add(OrderData(
        clientId: client.id,
        clientName: client.name,
        clientAddress: client.address));
  }

  void onDeleteClient(int clientId) {
    for (var i = 0; i < (orders.length); i++) {
      if (orders[i].clientId == clientId) {
        orders.removeAt(i);
        break;
      }
    }
  }
}
