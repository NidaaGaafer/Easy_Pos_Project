import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:my_easy_pos/helpers/sql_helpert.dart';
import 'package:my_easy_pos/models/products_data.dart';
//import 'package:my_easy_pos/pages/productOps.dart';
import 'package:my_easy_pos/pages/productsops.dart';
import 'package:my_easy_pos/widgets/app_taple.dart';
import 'package:my_easy_pos/widgets/search.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  bool sortValue = true;
  List<ProductData>? products;
  @override
  void initState() {
    getProductData();
    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Products Page"),
          actions: [
            IconButton(
                onPressed: () async {
                  var result = await Navigator.push(context,
                      MaterialPageRoute(builder: (ctx) => ProductsOpsPage()));
                  if (result ?? false) {
                    getProductData();
                  }
                },
                icon: Icon(Icons.add))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Search',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5)),
                  enabledBorder: OutlineInputBorder(),
                ),
                onChanged: (value) async {
                  var sqlHelper = GetIt.I.get<SqlHelpert>();
                  var result = await sqlHelper.db!.rawQuery("""
                  SELECT * FROM products
                  WHERE name LIKE '%$value%' OR description LIKE '%$value%';
                   """);
                  print('values:${result}');
                },
              ),
              SizedBox(height: 10),
              Expanded(
                  child: AppTable(
                minWidth: 1500,
                columnNumber: 3,
                sortAscending: sortValue,
                columns: [
                  DataColumn(label: Text('id')),
                  DataColumn(label: Text('name')),
                  DataColumn(label: Text('description')),
                  DataColumn(
                      label: Text('price'),
                      numeric: true,
                      onSort: (index, isAscending) {
                        sortValue = isAscending;
                        if (sortValue == false) {
                          products!
                              .sort((a, b) => a.price!.compareTo(b.price!));
                        } else {
                          products!
                              .sort((a, b) => b.price!.compareTo(a.price!));
                        }
                        setState(() {});
                      }),
                  DataColumn(label: Text('stock')),
                  DataColumn(label: Text('isAvaliable')),
                  DataColumn(label: Center(child: Text('image'))),
                  DataColumn(label: Text('categoryId')),
                  DataColumn(label: Text('categoryName')),
                  DataColumn(label: Text('categoryDesc')),
                  DataColumn(label: Text('actions')),
                ],
                source: DataProductSource(
                  addProduct: products,
                  onDelete: (ProductData) {
                    deletRow(ProductData.id!);
                  },
                  onUpdate: (ProductData) async {
                    var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => ProductsOpsPage(
                          productData: ProductData,
                        ),
                      ),
                    );
                    if (result ?? false) {
                      getProductData();
                    }
                  },
                  //getClientData
                ),
              )),
            ],
          ),
        ));
  }

  Future<void> deletRow(int id) async {
    try {
      var dialogResult = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delet products'),
              content:
                  const Text('Are you sure you want to delete this products ?'),
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
            .delete('products', where: 'id =?', whereArgs: [id]);
        if (result >= 0) {
          getProductData();
        }
      }
    } catch (e) {
      print('error when delet this row $e');
    }
  }
/*
  List<DataRow> getDataRow() {
    List<DataRow> rows = [];
    for (var product in products!) {
      rows.add(DataRow(cells: [
        DataCell(Text('${product.id}')),
      ]));
    }
    return rows;
  }
  */
}

class DataProductSource extends DataTableSource {
  List<ProductData>? addProduct;
  //void Function() getClientData;
  void Function(ProductData) onDelete;
  void Function(ProductData) onUpdate;
  DataProductSource(
      {required this.addProduct,
      //required this.getClientData,
      required this.onDelete,
      required this.onUpdate});
  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${addProduct?[index].id}')),
      DataCell(Text('${addProduct?[index].name}')),
      DataCell(Text('${addProduct?[index].description}')),
      DataCell(Text('${addProduct?[index].price}')),
      DataCell(Text('${addProduct?[index].stock}')),
      DataCell(Text('${addProduct?[index].isAvaliable}')),
      DataCell(Center(
          child: Image.asset(
        'assets/${addProduct?[index].image}',
        fit: BoxFit.contain,
      ))),
      DataCell(Text('${addProduct?[index].categoryId}')),
      DataCell(Text('${addProduct?[index].categoryName}')),
      DataCell(Text('${addProduct?[index].categoryDesc}')),
      DataCell(Row(
        children: [
          IconButton(
            onPressed: () {
              onDelete(addProduct![index]);
              //deletRow(addclients?[index].id ?? 0);
            },
            icon: Icon(Icons.delete),
            color: Colors.red,
          ),
          IconButton(
            onPressed: () {
              onUpdate(addProduct![index]);
            },
            icon: Icon(Icons.edit),
          )
        ],
      ))
    ]);
  }

  // hina can fi deletrow function

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => addProduct?.length ?? 0;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}
