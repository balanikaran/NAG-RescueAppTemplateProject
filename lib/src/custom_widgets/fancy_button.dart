import 'package:flutter/material.dart';

class FancyButton extends StatelessWidget {
  FancyButton({@required this.onPressed, this.text, this.color});

  final GestureTapCallback onPressed;
  final Text text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      fillColor: color,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 20.0,
        ),
        child: text,
      ),
      onPressed: onPressed,
      shape: StadiumBorder(),
    );
  }
}
