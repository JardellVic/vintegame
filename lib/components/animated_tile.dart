import 'package:flutter/material.dart';

import '../models/tile.dart';

class AnimatedTile extends AnimatedWidget {
  // Usamos Listenable.merge para atualizar o widget animado quando ambos os controladores mudam
  AnimatedTile(
      {super.key,
      required this.moveAnimation,
      required this.scaleAnimation,
      required this.tile,
      required this.child,
      required this.size})
      : super(listenable: Listenable.merge([moveAnimation, scaleAnimation]));

  final Tile tile;
  final Widget child;
  final CurvedAnimation moveAnimation;
  final CurvedAnimation scaleAnimation;
  final double size;

  // Obtém a posição superior atual com base no índice atual do tile
  late final double _top = tile.getTop(size);
  // Obtém a posição esquerda atual com base no índice atual do tile
  late final double _left = tile.getLeft(size);
  // Obtém a próxima posição superior com base no próximo índice do tile
  late final double _nextTop = tile.getNextTop(size) ?? _top;
  // Obtém a próxima posição esquerda com base no próximo índice do tile
  late final double _nextLeft = tile.getNextLeft(size) ?? _left;

  // Tween para mover o tile de cima para baixo
  late final Animation<double> top = Tween<double>(
        begin: _top,
        end: _nextTop,
      ).animate(
        moveAnimation,
      ),
      // Tween para mover o tile da esquerda para a direita
      left = Tween<double>(
        begin: _left,
        end: _nextLeft,
      ).animate(
        moveAnimation,
      ),
      // Tween de escala para dar um efeito de "pop" quando uma mesclagem acontece
      scale = TweenSequence<double>(
        <TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1.0, end: 1.5)
                .chain(CurveTween(curve: Curves.easeOut)),
            weight: 50.0,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1.5, end: 1.0)
                .chain(CurveTween(curve: Curves.easeIn)),
            weight: 50.0,
          ),
        ],
      ).animate(
        scaleAnimation,
      );

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: top.value,
        left: left.value,
        // Usa a animação de escala apenas se o tile foi mesclado
        child: tile.merged
            ? ScaleTransition(
                scale: scale,
                child: child,
              )
            : child);
  }
}
