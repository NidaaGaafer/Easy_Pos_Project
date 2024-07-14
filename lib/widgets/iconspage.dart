import 'package:flutter/material.dart';

class HomeIcons extends StatelessWidget {
  Color color;
  IconData icon;
  String label;
  void Function()? onPressed;
  HomeIcons(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onPressed,
      super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Card(
        color: Colors.white,
        surfaceTintColor: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(.2),
              child: Icon(
                icon,
                color: color,
              ),
              radius: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
