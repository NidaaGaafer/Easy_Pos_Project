import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:my_easy_pos/helpers/sql_helpert.dart';
import 'package:my_easy_pos/models/categories_data.dart';
import 'package:my_easy_pos/pages/categoriesops.dart';
import 'package:my_easy_pos/widgets/app_taple.dart';
import 'package:my_easy_pos/widgets/search.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<CategoryData>? categories;
  bool sortValue = true;
  @override
  void initState() {
    getCategoryData();
    super.initState();
  }

  void getCategoryData() async {
    try {
      var sqlHelpert = GetIt.I.get<SqlHelpert>();
      var data = await sqlHelpert.db!.query('categories');

      if (data.isNotEmpty) {
        categories = [];
        for (var item in data) {
          categories!.add(CategoryData.fromJson(item));
        }
      } else {
        categories = [];
      }
    } catch (e) {
      categories = [];
      print('error when get data $e');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Categoris Page"),
          actions: [
            IconButton(
                onPressed: () async {
                  var result = await Navigator.push(context,
                      MaterialPageRoute(builder: (ctx) => CategoriesOpsPage()));
                  if (result ?? false) {
                    getCategoryData();
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
                  SELECT * FROM categories
                  WHERE name LIKE '%$value%' OR description LIKE '%$value%';
                   """);
                  print('values:${result}');
                },
              ),
              SizedBox(height: 10),
              Expanded(
                  child: AppTable(
                columnNumber: 2,
                sortAscending: sortValue,
                columns: [
                  DataColumn(label: Text('id')),
                  DataColumn(label: Text('name')),
                  DataColumn(
                    label: Text('description'),
                    onSort: (index, isAscending) {
                      sortValue = isAscending;
                      if (sortValue == false) {
                        categories!.sort(
                            (a, b) => a.description!.compareTo(b.description!));
                      } else {
                        categories!.sort(
                            (a, b) => b.description!.compareTo(a.description!));
                      }
                      setState(() {});
                    },
                  ),
                  DataColumn(label: Text('actions')),
                ],
                source: DataCategorySource(
                  addCategory: categories,
                  onDelete: (CategoryData) {
                    deletRow(CategoryData.id!);
                  },
                  onUpdate: (CategoryData) async {
                    var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => CategoriesOpsPage(
                          categoryData: CategoryData,
                        ),
                      ),
                    );
                    if (result ?? false) {
                      getCategoryData();
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
              title: const Text('Delet client'),
              content:
                  const Text('Are you sure you want to delete this client ?'),
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
            .delete('categories', where: 'id =?', whereArgs: [id]);
        if (result >= 0) {
          getCategoryData();
        }
      }
    } catch (e) {
      print('error when delet this row $e');
    }
  }
}

class DataCategorySource extends DataTableSource {
  List<CategoryData>? addCategory;
  //void Function() getClientData;
  void Function(CategoryData) onDelete;
  void Function(CategoryData) onUpdate;
  DataCategorySource(
      {required this.addCategory,
      //required this.getClientData,
      required this.onDelete,
      required this.onUpdate});
  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${addCategory?[index].id}')),
      DataCell(Text('${addCategory?[index].name}')),
      DataCell(Text('${addCategory?[index].description}')),
      DataCell(Row(
        children: [
          IconButton(
            onPressed: () {
              onDelete(addCategory![index]);
              //deletRow(addclients?[index].id ?? 0);
            },
            icon: Icon(Icons.delete),
            color: Colors.red,
          ),
          IconButton(
            onPressed: () {
              onUpdate(addCategory![index]);
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
  int get rowCount => addCategory?.length ?? 0;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}
