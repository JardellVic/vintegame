import 'package:hive_flutter/hive_flutter.dart';

import 'board.dart';

class BoardAdapter extends TypeAdapter<Board> {
  @override
  final typeId = 0;

  @override
  Board read(BinaryReader reader) {
    //Cria um modelo Board a partir do JSON ao ler os dados que estão sendo armazenados.
    return Board.fromJson(Map<String, dynamic>.from(reader.read()));
  }

  @override
  void write(BinaryWriter writer, Board obj) {
    //Armazena o modelo Board como JSON ao gravar os dados no banco de dados.
    writer.write(obj.toJson());
  }
}
