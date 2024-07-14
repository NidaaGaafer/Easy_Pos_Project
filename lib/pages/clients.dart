import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:my_easy_pos/helpers/sql_helpert.dart';
import 'package:my_easy_pos/models/clients_data.dart';
import 'package:my_easy_pos/pages/clientops.dart';
import 'package:my_easy_pos/widgets/app_taple.dart';
import 'package:my_easy_pos/widgets/search.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  TextEditingController filterController = TextEditingController();
  bool sortValue = true;
  var allClient = [];
  var items = [];
  List<ClientData>? clients;
  @override
  void initState() {
    getClientData();
    super.initState();
  }

  void getClientData() async {
    try {
      var sqlHelpert = GetIt.I.get<SqlHelpert>();
      var data = await sqlHelpert.db!.query('clients');

      if (data.isNotEmpty) {
        clients = [];
        for (var item in data) {
          clients!.add(ClientData.fromJson(item));
          items = clients!;
        }
      } else {
        clients = [];
        items = clients!;
      }
    } catch (e) {
      clients = [];
      items = clients!;
      print('error when get data $e');
    }
    setState(() {});
  }

  void filterSearch(String qury) async {
    var dumyFilter = allClient;
    if (qury.isNotEmpty) {
      var dumyListData = [];
      dumyFilter!.forEach((item) {
        var client = ClientData.fromJson(item);
        if (client.name!.toLowerCase().contains(qury.toLowerCase())) {
          dumyListData.add(item);
        }
      });
      setState(() {
        items = [];
        items.addAll(dumyListData);
      });
      return;
    } else {
      setState(() {
        items = [];
        items = allClient;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Client Page"),
          actions: [
            IconButton(
                onPressed: () async {
                  var result = await Navigator.push(context,
                      MaterialPageRoute(builder: (ctx) => ClientOpsPage()));
                  if (result ?? false) {
                    getClientData();
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
                  SELECT * FROM clients
                  WHERE name LIKE '%$value%' OR phone LIKE '%$value%';
                   """);
                  print('values:${result}');
                },
              ),
              SizedBox(height: 10),
              Expanded(
                  child: AppTable(
                columnNumber: 1,
                sortAscending: sortValue,
                columns: [
                  DataColumn(label: Text('id')),
                  DataColumn(
                      label: Text('name'),
                      onSort: (index, isAscending) {
                        sortValue = isAscending;
                        if (sortValue == false) {
                          clients!.sort((a, b) => a.name!.compareTo(b.name!));
                        } else {
                          clients!.sort((a, b) => b.name!.compareTo(a.name!));
                        }
                        setState(() {});
                      }),
                  DataColumn(label: Text('email')),
                  DataColumn(label: Text('phone')),
                  DataColumn(label: Text('address')),
                  DataColumn(label: Text('actions')),
                ],
                source: DataClientSource(
                  addclients: clients,
                  onDelete: (ClientData) {
                    deletRow(ClientData.id!);
                  },
                  onUpdate: (ClientData) async {
                    var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => ClientOpsPage(
                          clientData: ClientData,
                        ),
                      ),
                    );
                    if (result ?? false) {
                      getClientData();
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
            .delete('clients', where: 'id =?', whereArgs: [id]);
        if (result >= 0) {
          getClientData();
        }
      }
    } catch (e) {
      print('error when delet this row $e');
    }
  }
}

class DataClientSource extends DataTableSource {
  List<ClientData>? addclients;
  //void Function() getClientData;
  void Function(ClientData) onDelete;
  void Function(ClientData) onUpdate;
  DataClientSource(
      {required this.addclients,
      //required this.getClientData,
      required this.onDelete,
      required this.onUpdate});
  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${addclients?[index].id}')),
      DataCell(Text('${addclients?[index].name}')),
      DataCell(Text('${addclients?[index].email}')),
      DataCell(Text('${addclients?[index].address}')),
      DataCell(Text('${addclients?[index].phone}')),
      DataCell(Row(
        children: [
          IconButton(
            onPressed: () {
              onDelete(addclients![index]);
              //deletRow(addclients?[index].id ?? 0);
            },
            icon: Icon(Icons.delete),
            color: Colors.red,
          ),
          IconButton(
            onPressed: () {
              onUpdate(addclients![index]);
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
  int get rowCount => addclients?.length ?? 0;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}
