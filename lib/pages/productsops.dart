import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:my_easy_pos/helpers/sql_helpert.dart';
import 'package:my_easy_pos/models/products_data.dart';
import 'package:my_easy_pos/widgets/button.dart';
import 'package:my_easy_pos/widgets/categories_deop_down.dart';
import 'package:my_easy_pos/widgets/textfiled.dart';

class ProductsOpsPage extends StatefulWidget {
  final ProductData? productData;
  const ProductsOpsPage({super.key, this.productData});

  @override
  State<ProductsOpsPage> createState() => _ProductsOpsPageState();
}

class _ProductsOpsPageState extends State<ProductsOpsPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController? nameController;
  TextEditingController? descriptionController;
  TextEditingController? priceController;
  TextEditingController? stokController;
  TextEditingController? imageController;
  bool? isAvaliabel = false;
  int? selectedCateoryId;
  @override
  void initState() {
    initialData();
    super.initState();
  }

  void initialData() {
    nameController = TextEditingController(text: widget.productData?.name);
    descriptionController =
        TextEditingController(text: widget.productData?.description);
    priceController =
        TextEditingController(text: '${widget.productData?.price ?? ' '}');
    stokController =
        TextEditingController(text: '${widget.productData?.stock ?? " "}');
    imageController = TextEditingController(text: widget.productData?.image);
    isAvaliabel = widget.productData?.isAvaliable ?? false;
    selectedCateoryId = widget.productData?.categoryId;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productData != null
            ? 'Update Information'
            : ' Add New Product'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Form(
            key: formKey,
            child: Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    AppTextField(
                      label: 'Name',
                      controller: nameController!,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please Enter Name of Product";
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    AppTextField(
                      label: 'Decreption',
                      controller: descriptionController!,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return " the description is required";
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    AppTextField(
                      label: 'price',
                      keyboardType: TextInputType.number,
                      inputformatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: priceController!,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "price is required";
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    AppTextField(
                      label: 'stock',
                      controller: stokController!,
                      keyboardType: TextInputType.number,
                      inputformatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return " the stock is required";
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    AppTextField(
                      label: 'image',
                      controller: imageController!,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return " the  image is Required";
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Switch(
                            value: isAvaliabel!,
                            onChanged: (value) {
                              setState(() {
                                isAvaliabel = value;
                              });
                            }),
                        Text('Is Avaliabel')
                      ],
                    ),
                    CategoriesDropDown(
                      selecteValue: selectedCateoryId,
                      onChanged: (categoryId) {
                        setState(() {
                          selectedCateoryId = categoryId;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    MyButton(
                      description: 'Submit',
                      onPressed: () async {
                        await addproduct();
                      },
                    )
                  ],
                ),
              ),
            )),
      ),
    );
  }

  Future<void> addproduct() async {
    try {
      if (formKey.currentState!.validate()) {
        var sqlHelper = GetIt.I.get<SqlHelpert>();
        if (widget.productData != null) {
          await sqlHelper.db!.update(
              'products',
              {
                'name': nameController?.text,
                'description': descriptionController?.text,
                'price': priceController?.text,
                'stock': stokController?.text,
                'image': imageController?.text,
                'isAvaliable': isAvaliabel == true ? 1 : 0,
                'categoryId': selectedCateoryId
              },
              where: 'id =?',
              whereArgs: [widget.productData?.id]);
        } else {
          await sqlHelper.db!.insert('products', {
            'name': nameController?.text,
            'description': descriptionController?.text,
            'price': priceController?.text,
            'stock': stokController?.text,
            'image': imageController?.text,
            'isAvaliable': isAvaliabel == true ? 1 : 0,
            'categoryId': selectedCateoryId,
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
        content: Text('not Success Adding Operation '),
        backgroundColor: Colors.red,
      ));
      print("error in adding product $e");
    }
  }
}
