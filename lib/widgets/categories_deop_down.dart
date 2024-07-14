import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:my_easy_pos/helpers/sql_helpert.dart';
import 'package:my_easy_pos/models/categories_data.dart';

class CategoriesDropDown extends StatefulWidget {
  final int? selecteValue;
  final void Function(int?)? onChanged;
  const CategoriesDropDown(
      {super.key, this.onChanged, required this.selecteValue});

  @override
  State<CategoriesDropDown> createState() => _CategoriesDropDownState();
}

class _CategoriesDropDownState extends State<CategoriesDropDown> {
  List<CategoryData>? categories;
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
    return categories == null
        ? Center(
            child: CircularProgressIndicator(),
          )
        : (categories?.isEmpty ?? false)
            ? Center(
                child: Text('not data found'),
              )
            : Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(),
                ),
                child: DropdownButton(
                    isExpanded: true,
                    underline: SizedBox(),
                    hint: Text(
                      'selecte category',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    value: widget.selecteValue,
                    items: [
                      for (var category in categories!)
                        DropdownMenuItem(
                          child: Text(category.name ?? 'no name'),
                          value: category.id,
                        )
                    ],
                    onChanged: widget.onChanged),
              );
  }
}
