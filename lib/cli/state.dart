class Cli {
  State state;
  static final _cache = <String, Cli>{};

  Cli._create({required this.state}) {
    _next();
  }

  factory Cli({required State state}) =>
      _cache.putIfAbsent(state.toString(), () => Cli._create(state: state));

  void _next() {
    state.handler(context: this);
    if (state.isReady) _next();
  }
}

abstract class State<T> {
  late State? previous;
  late T service;
  bool isReady = false;

  /// Executes state actions
  void handler({required Cli context});
}

abstract class Menu extends State {
  /// Checks if [option] is between [min] and [max], and return it as integer
  int checkOption({required String? option, int min = 0, required int max}) {
    if (option == null || option.isEmpty) return -1;

    try {
      int optionI = int.parse(option);

      if (optionI >= min && optionI <= max) {
        return optionI;
      } else {
        return -1;
      }
    } catch (e) {
      return -1;
    }
  }

  /// Checks if [option] is listed on [listChars] or between [min] and [max], and return it as string
  String? checkOptionWithChar(
      {required String? option,
      int min = 0,
      required int max,
      required List<String?> listChars,
      bool zero = false}) {
    if (option == null || option.isEmpty) return null;

    try {
      option = option.toLowerCase();
      if (listChars.isNotEmpty && listChars.contains(option)) {
        return option;
      }

      int optionI = int.parse(option);

      if (optionI >= min && optionI <= max) {
        return "$optionI";
      } else if (zero && optionI == 0) {
        return "$optionI";
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Shows menu to user
  void showMenu();
}
