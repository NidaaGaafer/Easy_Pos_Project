import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:my_easy_pos/helpers/sql_helpert.dart';
import 'package:my_easy_pos/models/ordar_data.dart';
import 'package:my_easy_pos/models/order_item_data.dart';
import 'package:my_easy_pos/models/products_data.dart';
import 'package:my_easy_pos/pages/salesop.dart';
import 'package:my_easy_pos/widgets/app_taple.dart';

class AllSales extends StatefulWidget {
  const AllSales({super.key});

  @override
  State<AllSales> createState() => _AllSalesState();
}

class _AllSalesState extends State<AllSales> {
  List<OrderItemData> selectedOrderItem = [];
  List<OrderData>? orders;
  bool sortValue = true;
  List<ProductData>? products;
  @override
  void initState() {
    getOrders();
    getProductData();
    super.initState();
  }
/////

  void getProductData() async {
    try {
      var sqlHelpert = GetIt.I.get<SqlHelpert>();
      var data = await sqlHelpert.db!.rawQuery("""
                   select P.*, C.name as categoryName, C.description as categoryDesc from products P
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
      products = [];
      print('error when get data $e');
    }
    setState(() {});
  }

  ///

  void getOrders() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelpert>();
      var data = await sqlHelper.db!.rawQuery("""
      select O.* ,C.name as clientName,C.phone as clientPhone,C.address as clientAddress 
      from orders O
      inner join clients C
      where O.clientId = C.id
      """);

      if (data.isNotEmpty) {
        orders = [];
        for (var item in data) {
          orders!.add(OrderData.fromJson(item));
        }
      } else {
        orders = [];
      }
    } catch (e) {
      print('Error In get data $e');
      orders = [];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Sales'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) async {
                var sqlHelper = GetIt.I.get<SqlHelpert>();
                await sqlHelper.db!.rawQuery("""
        SELECT * FROM orders
        WHERE label LIKE '%$value%';
          """);
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                labelText: 'Search',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
                child: AppTable(
                    minWidth: 1300,
                    columnNumber: 2,
                    sortAscending: sortValue,
                    columns: [
                      DataColumn(label: Text('Id')),
                      DataColumn(label: Text('Label')),
                      DataColumn(
                          label: Text('Total Price'),
                          onSort: (index, isAscending) {
                            sortValue = isAscending;
                            if (sortValue == false) {
                              orders!.sort((a, b) =>
                                  a.totalPrice!.compareTo(b.totalPrice!));
                            } else {
                              orders!.sort((a, b) =>
                                  b.totalPrice!.compareTo(a.totalPrice!));
                            }
                            setState(() {});
                          }),
                      DataColumn(label: Text('Discount')),
                      DataColumn(label: Text('Client Name')),
                      DataColumn(label: Text('Client phone')),
                      DataColumn(label: Text('Client Address')),
                      DataColumn(label: Center(child: Text('Actions'))),
                    ],
                    source: OrderDataSource(
                      ordersEx: orders,
                      onDelete: (order) {
                        deletRow(order.id!);
                      },
                      onShow: (OrderData) {},
                      onUpdate: (OrderData) async {
                        var result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => SaleOpsPage(
                              order: OrderData,
                            ),
                          ),
                        );
                        if (result ?? false) {
                          getOrders();
                        }
                      },
                    ))),
          ],
        ),
      ),
    );
  }

  Future<void> deletRow(int id) async {
    try {
      var dialogResult = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delet client'),
              content:
                  const Text('Are you sure you want to delete this order ?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('cancel'),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('Delete'))
              ],
            );
          });
      if (dialogResult ?? false) {
        var sqlHelpert = GetIt.I.get<SqlHelpert>();
        var result = await sqlHelpert.db!
            .delete('orders', where: 'id =?', whereArgs: [id]);
        if (result >= 0) {
          getOrders();
        }
      }
    } catch (e) {
      print('error when delet this row $e');
    }
  }

/////////////////
  Future<void> visabilatyProducts(int id) async {
    await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text('prodects in order'),
                    for (var orderItem in selectedOrderItem)
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: ListTile(
                            leading: Image.asset(
                              'assets/${orderItem.productData?.image ?? ''}',
                              height: 50,
                              width: 50,
                              fit: BoxFit.contain,
                            ),
                            title: Text('${orderItem.productData?.name ?? ''}'),
                            trailing: Text(
                                ' price: ${(orderItem.productData?.price)}'),
                          ))
                  ],
                ),
              ),
            );
          });
        });
  }

/////////////////

  OrderItemData? getOrderItem(int productId) {
    for (var item in selectedOrderItem) {
      if (item.productId == productId) {
        return item;
      }
    }
    return null;
  }
}

class SqlHelper {}

class OrderDataSource extends DataTableSource {
  List<OrderData>? ordersEx;

  void Function(OrderData) onShow;
  void Function(OrderData) onUpdate;
  void Function(OrderData) onDelete;
  OrderDataSource(
      {required this.ordersEx,
      required this.onShow,
      required this.onUpdate,
      required this.onDelete});

  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${ordersEx?[index].id}')),
      DataCell(Text('${ordersEx?[index].lebel}')),
      DataCell(Text('${ordersEx?[index].totalPrice}')),
      DataCell(Text('${ordersEx?[index].discount}')),
      DataCell(Text('${ordersEx?[index].clientName}')),
      DataCell(Text('${ordersEx?[index].clientPhone}')),
      DataCell(Text('${ordersEx?[index].clientAddress}')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () {
                onShow(ordersEx![index]);
              },
              icon: const Icon(Icons.visibility)),
          IconButton(
            onPressed: () {
              onUpdate(ordersEx![index]);
            },
            icon: Icon(Icons.edit),
          ),
          IconButton(
              onPressed: () {
                onDelete(ordersEx![index]);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              )),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => ordersEx?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
