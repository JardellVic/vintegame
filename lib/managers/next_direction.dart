import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';

/*
Caso o usuário deslize muito rápido, evitamos que a próxima rodada comece até que a rodada atual termine. Fazemos isso usando o RoundManager,
mas, em vez de cancelar essa rodada, iremos colocá-la em uma fila para que a rodada comece automaticamente assim que a atual terminar.
Dessa forma, evitamos que o usuário tenha a sensação de que o jogo está travando ou lento.
*/

class NextDirectionManager extends StateNotifier<SwipeDirection?> {
  NextDirectionManager() : super(null);

  void queue(direction) {
    state = direction;
  }

  void clear() {
    state = null;
  }
}

final nextDirectionManager =
    StateNotifierProvider<NextDirectionManager, SwipeDirection?>((ref) {
  return NextDirectionManager();
});
