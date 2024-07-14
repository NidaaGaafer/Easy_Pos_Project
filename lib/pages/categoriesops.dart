import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:my_easy_pos/helpers/sql_helpert.dart';
import 'package:my_easy_pos/models/categories_data.dart';
import 'package:my_easy_pos/widgets/button.dart';
import 'package:my_easy_pos/widgets/textfiled.dart';

class CategoriesOpsPage extends StatefulWidget {
  final CategoryData? categoryData;
  const CategoriesOpsPage({super.key, this.categoryData});

  @override
  State<CategoriesOpsPage> createState() => _CategoriesOpsPageState();
}

class _CategoriesOpsPageState extends State<CategoriesOpsPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController? nameController;
  TextEditingController? descriptionController;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.categoryData?.name);
    descriptionController =
        TextEditingController(text: widget.categoryData?.description);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryData != null
            ? 'Update Information'
            : ' Add New Categoriey'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(height: 20),
                AppTextField(
                  label: 'Name',
                  controller: nameController!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "the name Name of Category is Required";
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 10),
                AppTextField(
                  label: 'Description',
                  controller: descriptionController!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "The Description is Required";
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 10),
                MyButton(
                  description: 'Submit',
                  onPressed: () async {
                    await addCategory();
                  },
                )
              ],
            )),
      ),
    );
  }

  Future<void> addCategory() async {
    try {
      if (formKey.currentState!.validate()) {
        var sqlHelper = GetIt.I.get<SqlHelpert>();
        if (widget.categoryData != null) {
          // Update client information
          await sqlHelper.db!.update(
              'categories',
              {
                'name': nameController?.text,
                'description': descriptionController?.text,
              },
              where: 'id =?',
              whereArgs: [widget.categoryData?.id]);
        } else {
          await sqlHelper.db!.insert('categories', {
            'name': nameController?.text,
            'description': descriptionController?.text,
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Success Adding Operation'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Success Adding Operation'),
        backgroundColor: Colors.red,
      ));
    }
  }
}
