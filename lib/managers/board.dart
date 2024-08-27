// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/tile.dart';
import '../models/board.dart';

import 'next_direction.dart';
import 'round.dart';

class BoardManager extends StateNotifier<Board> {
// Usaremos esta lista para recuperar o índice correto quando o usuário deslizar para cima/baixo
// o que nos permitirá reutilizar a maior parte da lógica.
  final verticalOrder = [12, 8, 4, 0, 13, 9, 5, 1, 14, 10, 6, 2, 15, 11, 7, 3];

  final StateNotifierProviderRef ref;
  BoardManager(this.ref) : super(Board.newGame(0, [])) {
    // Carregue o último estado salvo ou inicie um novo jogo.
    load();
  }

  void load() async {
    // Acesse a caixa e obtenha o primeiro item no índice 0
    // que sempre será apenas um item do modelo Board
    // e aqui não precisamos chamar a função fromJson do modelo Board
    // para construir o modelo Board
    // em vez disso, o adaptador que adicionamos anteriormente fará isso automaticamente.
    var box = await Hive.openBox<Board>('boardBox');
    // Se não houver salvamento local, ele iniciará um novo jogo.
    state = box.get(0) ?? _newGame();
  }

  // Crie o estado de um novo jogo.
  Board _newGame() {
    return Board.newGame(state.best + state.score, [random([])]);
  }

// Inicie um novo jogo
  void newGame() {
    state = _newGame();
  }

// Verifique se os índices estão na mesma linha ou coluna no tabuleiro.
  bool _inRange(index, nextIndex) {
    return index < 4 && nextIndex < 4 ||
        index >= 4 && index < 8 && nextIndex >= 4 && nextIndex < 8 ||
        index >= 8 && index < 12 && nextIndex >= 8 && nextIndex < 12 ||
        index >= 12 && nextIndex >= 12;
  }

  Tile _calculate(Tile tile, List<Tile> tiles, direction) {
    bool asc =
        direction == SwipeDirection.left || direction == SwipeDirection.up;
    bool vert =
        direction == SwipeDirection.up || direction == SwipeDirection.down;
    // Obtenha o primeiro índice da esquerda na linha
    // Exemplo: para um deslizar para a esquerda, isso pode ser: 0, 4, 8, 12
    // para um deslizar para a direita, isso pode ser: 3, 7, 11, 15
    // dependendo de qual linha na coluna do tabuleiro precisamos
    // digamos que o tile.index = 6 (que é o 3º tile da esquerda e 2º da direita, na segunda linha)
    // ceil significa que sempre arredondará para o próximo número inteiro maior
    // NOTA: não confunda ceil com floor ou round, pois mesmo que o valor seja 2.1, a saída seria 3.
    // ((6 + 1) / 4) = 1.75
    // Ceil(1.75) = 2
    // Se for ascendente: 2 * 4 – 4 = 4, que é o primeiro índice da esquerda na segunda linha
    // Se for descendente: 2 * 4 – 1 = 7, que é o último índice da esquerda e o primeiro índice da direita na segunda linha
    // Se o usuário deslizar verticalmente, use a lista verticalOrder para recuperar o índice para cima/baixo, caso contrário, use o índice existente
    int index = vert ? verticalOrder[tile.index] : tile.index;
    int nextIndex = ((index + 1) / 4).ceil() * 4 - (asc ? 4 : 1);

    // Se a lista de novos tiles a serem renderizados não estiver vazia, obtenha o último tile
    // e se esse tile estiver na mesma linha que o tile atual, defina o próximo índice para o tile atual como após o último tile
    if (tiles.isNotEmpty) {
      var last = tiles.last;
      // Se o usuário deslizar verticalmente, use a lista verticalOrder para recuperar o índice para cima/baixo, caso contrário, use o índice existente
      var lastIndex = last.nextIndex ?? last.index;
      lastIndex = vert ? verticalOrder[lastIndex] : lastIndex;
      if (_inRange(index, lastIndex)) {
        // Se a ordem for ascendente, defina o tile após o último tile processado
        // Se a ordem for descendente, defina o tile antes do último tile processado
        nextIndex = lastIndex + (asc ? 1 : -1);
      }
    }

    // Retorne uma cópia imutável do tile atual com o novo próximo índice
    // que pode ser o índice superior esquerdo na linha ou o próximo índice do último tile + 1
    return tile.copyWith(
        nextIndex: vert ? verticalOrder.indexOf(nextIndex) : nextIndex);
  }

  // Mova o tile na direção
  bool move(SwipeDirection direction) {
    bool asc =
        direction == SwipeDirection.left || direction == SwipeDirection.up;
    bool vert =
        direction == SwipeDirection.up || direction == SwipeDirection.down;
    // Ordena a lista de tiles por índice.
    // Se o usuário deslizar verticalmente, use a lista verticalOrder para recuperar o índice para cima/baixo
    state.tiles.sort(((a, b) =>
        (asc ? 1 : -1) *
        (vert
            ? verticalOrder[a.index].compareTo(verticalOrder[b.index])
            : a.index.compareTo(b.index))));

    List<Tile> tiles = [];

    for (int i = 0, l = state.tiles.length; i < l; i++) {
      var tile = state.tiles[i];

      // Calcula o próximo índice para o tile atual.
      tile = _calculate(tile, tiles, direction);
      tiles.add(tile);

      if (i + 1 < l) {
        var next = state.tiles[i + 1];
        // Atribua o próximo índice ou índice do tile atual ao próximo tile se for permitido movê-lo.
        if (tile.value == next.value) {
          // Se o usuário deslizar verticalmente, use a lista verticalOrder para recuperar o índice para cima/baixo, caso contrário, use o índice existente
          var index = vert ? verticalOrder[tile.index] : tile.index,
              nextIndex = vert ? verticalOrder[next.index] : next.index;
          if (_inRange(index, nextIndex)) {
            tiles.add(next.copyWith(nextIndex: tile.nextIndex));
            // Pule a próxima iteração se o próximo tile já tiver sido atribuído um nextIndex.
            i += 1;
            continue;
          }
        }
      }
    }

    // Atribua uma cópia imutável do novo estado do tabuleiro e acione a reconstrução.
    state = state.copyWith(tiles: tiles, undo: state);
    return true;
  }

// Gera tiles em locais aleatórios no tabuleiro
  Tile random(List<int> indexes) {
    var i = 0;
    var rng = Random();
    do {
      i = rng.nextInt(16);
    } while (indexes.contains(i));

    return Tile(const Uuid().v4(), 2, i);
  }

  /// Mescla tiles
  void merge() {
    List<Tile> tiles = [];
    var tilesMoved = false;
    List<int> indexes = [];
    var score = state.score;

    for (int i = 0, l = state.tiles.length; i < l; i++) {
      var tile = state.tiles[i];

      var value = tile.value, merged = false;

      if (i + 1 < l) {
        // Soma o valor dos dois tiles com o mesmo índice e marca o tile como mesclado, pulando a próxima iteração.
        var next = state.tiles[i + 1];
        if (tile.nextIndex == next.nextIndex ||
            tile.index == next.nextIndex && tile.nextIndex == null) {
          value = tile.value + next.value;
          merged = true;
          score += tile.value;
          i += 1;
        }
      }

      if (merged || tile.nextIndex != null && tile.index != tile.nextIndex) {
        tilesMoved = true;
      }

      tiles.add(tile.copyWith(
          index: tile.nextIndex ?? tile.index,
          nextIndex: null,
          value: value,
          merged: merged));
      indexes.add(tiles.last.index);
    }

    // Se tiles foram movidos, gere um novo tile em uma posição aleatória das posições disponíveis no tabuleiro.
    if (tilesMoved) {
      tiles.add(random(indexes));
    }
    state = state.copyWith(score: score, tiles: tiles);
  }

  // Finaliza a rodada, vence ou perde o jogo.
  void _endRound() {
    var gameOver = true, gameWon = false;
    List<Tile> tiles = [];

    // Se não há mais espaços vazios no tabuleiro
    if (state.tiles.length == 16) {
      state.tiles.sort(((a, b) => a.index.compareTo(b.index)));

      for (int i = 0, l = state.tiles.length; i < l; i++) {
        var tile = state.tiles[i];

        // Se há um tile com valor 2048, o jogo é vencido.
        if (tile.value == 2048) {
          gameWon = true;
        }

        var x = (i - (((i + 1) / 4).ceil() * 4 - 4));

        if (x > 0 && i - 1 >= 0) {
          // Se o tile pode ser mesclado com o tile à esquerda, o jogo não está perdido.
          var left = state.tiles[i - 1];
          if (tile.value == left.value) {
            gameOver = false;
          }
        }

        if (x < 3 && i + 1 < l) {
          // Se o tile pode ser mesclado com o tile à direita, o jogo não está perdido.
          var right = state.tiles[i + 1];
          if (tile.value == right.value) {
            gameOver = false;
          }
        }

        if (i - 4 >= 0) {
          // Se o tile pode ser mesclado com o tile acima, o jogo não está perdido.
          var top = state.tiles[i - 4];
          if (tile.value == top.value) {
            gameOver = false;
          }
        }

        if (i + 4 < l) {
          // Se o tile pode ser mesclado com o tile abaixo, o jogo não está perdido.
          var bottom = state.tiles[i + 4];
          if (tile.value == bottom.value) {
            gameOver = false;
          }
        }
        // Define o tile como mesclado: false
        tiles.add(tile.copyWith(merged: false));
      }
    } else {
      // Ainda há espaço no tabuleiro para adicionar um tile, então o jogo não está perdido.
      gameOver = false;
      for (var tile in state.tiles) {
        // Se há um tile com valor 2048, o jogo é vencido.
        if (tile.value == 2048) {
          gameWon = true;
        }
        // Define o tile como mesclado: false
        tiles.add(tile.copyWith(merged: false));
      }
    }

    state = state.copyWith(tiles: tiles, won: gameWon, over: gameOver);
  }

  // Marque o mesclado como falso após a animação de mesclagem ser concluída.
  bool endRound() {
    // Finalize a rodada.
    _endRound();
    ref.read(roundManager.notifier).end();

    // Se o jogador se moveu muito rápido antes que a animação/transição atual fosse concluída, inicie o movimento para a próxima direção
    var nextDirection = ref.read(nextDirectionManager);
    if (nextDirection != null) {
      move(nextDirection);
      ref.read(nextDirectionManager.notifier).clear();
      return true;
    }
    return false;
  }

  // Desfaz apenas uma rodada
  void undo() {
    if (state.undo != null) {
      state = state.copyWith(
          score: state.undo!.score,
          best: state.undo!.best,
          tiles: state.undo!.tiles);
    }
  }

  // Mova os tiles usando as teclas de seta no teclado.
  bool onKey(RawKeyEvent event) {
    SwipeDirection? direction;
    if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
      direction = SwipeDirection.right;
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
      direction = SwipeDirection.left;
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
      direction = SwipeDirection.up;
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
      direction = SwipeDirection.down;
    }

    if (direction != null) {
      move(direction);
      return true;
    }
    return false;
  }

  void save() async {
    // Aqui não precisamos chamar a função toJson do modelo de tabuleiro
    // para converter os dados para JSON
    // em vez disso, o adaptador que adicionamos anteriormente fará isso automaticamente.
    var box = await Hive.openBox<Board>('boardBox');
    try {
      box.putAt(0, state);
    } catch (e) {
      box.add(state);
    }
  }
}

final boardManager = StateNotifierProvider<BoardManager, Board>((ref) {
  return BoardManager(ref);
});
