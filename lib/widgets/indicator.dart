import 'package:flutter/material.dart';

/// widget che rappresenta gli indicatori nella legenda delle statistiche
class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color, // colore dell'indicatore
    required this.text, // testo affiancato nella legenda
    this.size = 16, // size del font
    this.textColor, // colore del testo
  });

  final Color color;
  final String text;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration( // rappresenta un cerchio colorato
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
}