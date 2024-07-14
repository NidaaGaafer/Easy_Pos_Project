import 'package:flutter/material.dart';

class Hcard extends StatelessWidget {
  String str1;
  String str2;
  Hcard({required this.str1, required this.str2, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromARGB(255, 36, 34, 179),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              str1,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(width: 30),
            Text(
              str2,
              style: TextStyle(color: Color.fromARGB(255, 198, 205, 233)),
            )
          ],
        ),
      ),
    );
  }
}
