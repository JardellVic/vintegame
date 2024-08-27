import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
Um Notifier para quando uma rodada começa, a fim de evitar que a próxima rodada comece antes que a atual termine.
Evita problemas de animação quando o usuário tenta mover as peças muito cedo.
*/

class RoundManager extends StateNotifier<bool> {
  RoundManager() : super(true);

  void end() {
    state = true;
  }

  void begin() {
    state = false;
  }
}

final roundManager = StateNotifierProvider<RoundManager, bool>((ref) {
  return RoundManager();
});
