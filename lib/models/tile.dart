import 'package:json_annotation/json_annotation.dart';

part 'tile.g.dart';

@JsonSerializable(anyMap: true)
class Tile {
  //ID único usado como ValueKey para o TileWidget
  final String id;
  //O número no tile
  final int value;
  //O índice do tile no tabuleiro a partir do qual a posição do tile será calculada
  final int index;
  //O próximo índice do tile no tabuleiro
  final int? nextIndex;
  //Indica se o tile foi mesclado com outro tile
  final bool merged;

  Tile(this.id, this.value, this.index, {this.nextIndex, this.merged = false});

  //Calcula a posição atual do topo com base no índice atual
  double getTop(double size) {
    var i = ((index + 1) / 4).ceil();
    return ((i - 1) * size) + (12.0 * i);
  }

  //Calcula a posição atual à esquerda com base no índice atual
  double getLeft(double size) {
    var i = (index - (((index + 1) / 4).ceil() * 4 - 4));
    return (i * size) + (12.0 * (i + 1));
  }

  //Calcula a próxima posição do topo com base no próximo índice
  double? getNextTop(double size) {
    if (nextIndex == null) return null;
    var i = ((nextIndex! + 1) / 4).ceil();
    return ((i - 1) * size) + (12.0 * i);
  }

  //Calcula a próxima posição à esquerda com base no próximo índice
  double? getNextLeft(double size) {
    if (nextIndex == null) return null;
    var i = (nextIndex! - (((nextIndex! + 1) / 4).ceil() * 4 - 4));
    return (i * size) + (12.0 * (i + 1));
  }

  //Cria uma cópia imutável do tile
  Tile copyWith(
          {String? id, int? value, int? index, int? nextIndex, bool? merged}) =>
      Tile(id ?? this.id, value ?? this.value, index ?? this.index,
          nextIndex: nextIndex ?? this.nextIndex,
          merged: merged ?? this.merged);

  //Cria um Tile a partir de dados em JSON
  factory Tile.fromJson(Map<String, dynamic> json) => _$TileFromJson(json);

  //Gera dados JSON a partir do Tile
  Map<String, dynamic> toJson() => _$TileToJson(this);
}
