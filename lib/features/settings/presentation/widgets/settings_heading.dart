import 'package:flutter/material.dart';

class SettingsHeading extends StatelessWidget {
  final String text;

  const SettingsHeading({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
