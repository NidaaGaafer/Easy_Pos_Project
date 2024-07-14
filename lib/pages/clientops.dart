import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:my_easy_pos/helpers/sql_helpert.dart';
import 'package:my_easy_pos/models/clients_data.dart';
import 'package:my_easy_pos/widgets/button.dart';
import 'package:my_easy_pos/widgets/search.dart';
import 'package:my_easy_pos/widgets/textfiled.dart';

class ClientOpsPage extends StatefulWidget {
  final ClientData? clientData;
  const ClientOpsPage({super.key, this.clientData});

  @override
  State<ClientOpsPage> createState() => _ClientOpsPageState();
}

class _ClientOpsPageState extends State<ClientOpsPage> {
  TextEditingController? nameController;
  TextEditingController? emailController;
  TextEditingController? phoneController;
  TextEditingController? addressController;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    nameController = TextEditingController(text: widget.clientData?.name);
    emailController = TextEditingController(text: widget.clientData?.email);
    phoneController = TextEditingController(text: widget.clientData?.phone);
    addressController = TextEditingController(text: widget.clientData?.address);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clientData != null
            ? 'Update Information'
            : ' Add New Clint'),
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
                      return "Please Enter Your Name";
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 10),
                AppTextField(
                  label: 'Email',
                  controller: emailController!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please Enter Your Email";
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 10),
                AppTextField(
                  label: 'address',
                  controller: addressController!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please Enter Your Phone";
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 10),
                AppTextField(
                  label: 'Phone',
                  controller: phoneController!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please Enter Your Phone";
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 10),
                MyButton(
                  description: 'Submit',
                  onPressed: () async {
                    await addClient();
                  },
                )
              ],
            )),
      ),
    );
  }

  Future<void> addClient() async {
    try {
      if (formKey.currentState!.validate()) {
        var sqlHelper = GetIt.I.get<SqlHelpert>();
        if (widget.clientData != null) {
          // Update client information
          await sqlHelper.db!.update(
              'clients',
              {
                'name': nameController?.text,
                'email': emailController?.text,
                'phone': phoneController?.text,
                'address': addressController?.text,
              },
              where: 'id =?',
              whereArgs: [widget.clientData?.id]);
        } else {
          await sqlHelper.db!.insert('clients', {
            'name': nameController?.text,
            'email': emailController?.text,
            'phone': phoneController?.text,
            'address': addressController?.text,
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
