import 'package:json_annotation/json_annotation.dart';

import '../models/tile.dart';

part 'board.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class Board {
  //Pontuação atual no tabuleiro
  final int score;
  //Melhor pontuação até agora
  final int best;
  //Lista atual de tiles mostrados no tabuleiro
  final List<Tile> tiles;
  //Indica se o jogo acabou ou não
  final bool over;
  //Indica se o jogo foi vencido ou não
  final bool won;
  //Mantém o estado do tabuleiro da rodada anterior, usado para a funcionalidade de desfazer
  final Board? undo;

  Board(this.score, this.best, this.tiles,
      {this.over = false, this.won = false, this.undo});

  //Cria um modelo para um novo jogo.
  Board.newGame(this.best, this.tiles)
      : score = 0,
        over = false,
        won = false,
        undo = null;

  //Cria uma cópia imutável do tabuleiro
  Board copyWith(
          {int? score,
          int? best,
          List<Tile>? tiles,
          bool? over,
          bool? won,
          Board? undo}) =>
      Board(score ?? this.score, best ?? this.best, tiles ?? this.tiles,
          over: over ?? this.over,
          won: won ?? this.won,
          undo: undo ?? this.undo);

  //Cria um Board a partir de dados em JSON
  factory Board.fromJson(Map<String, dynamic> json) => _$BoardFromJson(json);

  //Gera dados JSON a partir do Board
  Map<String, dynamic> toJson() => _$BoardToJson(this);
}
