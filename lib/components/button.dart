import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const/colors.dart';

class ButtonWidget extends ConsumerWidget {
  const ButtonWidget(
      {super.key, this.text, this.icon, required this.onPressed});

  final String? text;
  final IconData? icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (icon != null) {
      // Widget de botão com ícone para o botão de desfazer e reiniciar o jogo.
      return Container(
        decoration: BoxDecoration(
            color: scoreColor, borderRadius: BorderRadius.circular(8.0)),
        child: IconButton(
            color: textColorWhite,
            onPressed: onPressed,
            icon: Icon(
              icon,
              size: 24.0,
            )),
      );
    }
    // Widget de botão com texto para o botão de novo jogo e tentar novamente.
    return ElevatedButton(
        style: ButtonStyle(
            padding:
                WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.all(16.0)),
            backgroundColor: WidgetStateProperty.all<Color>(buttonColor)),
        onPressed: onPressed,
        child: Text(
          text!,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ));
  }
}
