import 'dart:io';

import 'package:asamurat/cli/menu/options.dart';

void setCursor(int x, int y, [String text = ""]) {
  stdout.write("\x1B[$x;${y}H$text");
}

void clear() {
  stdout.write("\x1B[2J");
  setCursor(0, 0);
}

String capitalize(String text) {
  return text.isEmpty
      ? text
      : text[0].toUpperCase() + text.substring(1).toLowerCase();
}

String trimString(String text, int maxChars, [bool ellipsis = true]) {
  return text.length <= maxChars
      ? text
      : text.substring(0, maxChars) + (ellipsis ? "…" : "");
}

String maskString(String text, String mask) => text.replaceAllMapped(RegExp(r'.'), (match) => mask);

void printMenu(List<OptionsMenu> options,
    {int startIndex = 1, dynamic breakPos = 0}) {
  int maxLength = 18;

  print("┌${"─" * (maxLength + 8)}┐"); // Top border
  print("│ Menu  ${" " * (maxLength)} │"); // Title
  print("├${"─" * (maxLength + 8)}┤");

  for (int i = 0, j = 0; i < options.length; i++) {
    String option = options[i].text;
    print("│ ${startIndex + i}. ${option.padRight(maxLength + 3)} │");

    if (breakPos is List && j < breakPos.length) {
      if (options[i].option.index == breakPos[j]) {
        print("├${"─" * (maxLength + 8)}┤");
        j++;
      }
    } else {
      if (options[i].option.index == breakPos) {
        print("├${"─" * (maxLength + 8)}┤");
      }
    }
  }

  print("└${"─" * (maxLength + 8)}┘"); // Bottom border
}

void printTable(List<List<String>> rows) {
  // Calculate column widths
  final List<int> columnWidths = List.filled(rows[0].length, 0);
  for (var row in rows) {
    for (int i = 0; i < row.length; i++) {
      if (row[i].length > columnWidths[i]) {
        columnWidths[i] = row[i].length;
      }
    }
  }

  // Print table
  for (int i = 0; i < rows.length; i++) {
    final row = rows[i];
    if (i == 0) {
      // Print top border
      stdout.write('┌');
      for (int i = 0; i < columnWidths.length; i++) {
        if (i != 0) stdout.write('┬');
        stdout.write('─' * (columnWidths[i] + 2));
      }
      print('┐');
    } else {
      // Print middle border
      stdout.write('├');
      for (int i = 0; i < columnWidths.length; i++) {
        if (i != 0) stdout.write('┼');
        stdout.write('─' * (columnWidths[i] + 2));
      }
      print('┤');
    }

    // Print row
    stdout.write('│ ');
    for (int i = 0; i < columnWidths.length; i++) {
      if (i != 0) stdout.write(' │ ');
      stdout.write(row[i] + ' ' * (columnWidths[i] - row[i].length));
    }
    print(' │');

    // Print bottom border if it's the last row
    if (i == rows.length - 1) {
      stdout.write('└');
      for (int i = 0; i < columnWidths.length; i++) {
        if (i != 0) stdout.write('┴');
        stdout.write('─' * (columnWidths[i] + 2));
      }
      print('┘');
    }
  }
}

void printOptions(List<OptionsMenu> options) {
  StringBuffer opt = StringBuffer();
  List<int> lengths = options.map((option) => option.text.length).toList();

  opt.writeln("┌${List.generate(options.length, (index) => "─────${"─" * lengths[index]}─").join("┬")}┐");
  
  List<String> middleLines = options.map((option) => "[${option.option.input}] ${option.text} ").toList();
  opt.writeln("│ ${middleLines.join("│ ")}│");
  
  opt.writeln("└${List.generate(options.length, (index) => "─────${"─" * lengths[index]}─").join("┴")}┘");

  stdout.write(opt);
}

DateTime convertDate(String date) {
  var parts = date.split('-');
  var day = int.parse(parts[0]);
  var month = int.parse(parts[1]);
  var year = int.parse(parts[2]);
  return DateTime(year, month, day);
}

String rot13(String input) {
  return input.replaceAllMapped(RegExp('[a-zA-Z]'), (match) {
    String letter = match.group(0)!;
    int offset =
        letter.codeUnitAt(0) <= 90 ? 65 : 97; // Check if uppercase or lowercase
    return String.fromCharCode(
        (letter.codeUnitAt(0) - offset + 13) % 26 + offset);
  });
}

enum TextColor {
  black(30),
  red(31),
  green(32),
  yellow(33),
  blue(34),
  magenta(35),
  cyan(36),
  white(36);

  const TextColor(this.code);

  final int code;
}

String colorizeText(String text, TextColor color) {
  return "\x1B[${color.code}m$text\x1B[0m";
}
