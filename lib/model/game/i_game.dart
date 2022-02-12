
import 'package:flutter/foundation.dart';

abstract class IGame extends ChangeNotifier {
  bool get isPaused;
  bool get isGameLost;
  bool get isStarted;
  int get period;
  LoopResult loop();
}

enum LoopResult { ok, needStartBefore, needStop, needRefresh }
