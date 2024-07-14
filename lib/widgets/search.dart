import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:my_easy_pos/helpers/sql_helpert.dart';

class SearchTextField extends StatelessWidget {
  final String tableName;
  const SearchTextField({required this.tableName, super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search),
        labelText: 'Search',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        enabledBorder: OutlineInputBorder(),
      ),
      onChanged: (value) async {
        var sqlHelpert = GetIt.I.get<SqlHelpert>();
        var result = await sqlHelpert.db!.rawQuery("""
                  select * from $tableName where name like '%$value%' or 
                  email like '%$value% or
                  phone like '%$value%
                  """);
        print("$result");
      },
    );
  }
}
