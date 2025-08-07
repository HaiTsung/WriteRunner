import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

List<String> words = [];

int wordCount = 100;
int wordLength = 7;
bool wordLengthRandom = false;

String language = "en";

int duration = 10;

var languages = {
  1: ["English", "en"],
  2: ["Spanish", "es"],
  3: ["Italian", "it"],
  4: ["German", "de"],
  5: ["French", "fr"],
  6: ["Chinese", "zh"],
  7: ["Brazilian Portugese", "pt-br"],
};

var ansiColors = {"red": "\x1B[31m", "white": "\x1B[0m", "green": "\x1B[32m"};

void main() {
  print("Welcome to WriteRunner!");
  print("1: Start Game");
  print("2: Settings");
  String? selection = stdin.readLineSync();

  int input = int.parse(selection!);

  switch (input) {
    case 1:
      playGame();
      break;
    case 2:
      settingsMenu();
      break;
    default:
  }
}

Future<void> playGame() async {
  var loading = startLoadingAnimation();
  await loadWords();
  showLoadingAnimation = false;
  await loading;
  for (var i = 3; i > 0; i--) {
    print("\x1B[2J\x1B[0;0H");
    print(i);
    await Future.delayed(Duration(milliseconds: 300));
  }
  print("\x1B[2J\x1B[0;0H");
  print("GO!");

  int currentWord = 0;

  bool loadingNextWord = false;

  DateTime startTime = DateTime.now();

  DateTime estimatedEndTime = startTime.add(Duration(seconds: duration));
  print(startTime.toIso8601String());
  print(estimatedEndTime.toIso8601String());

  int correctAnswers = 0;
  int wrongAnswers = 0;
  while (currentWord < words.length &&
      DateTime.now().compareTo(estimatedEndTime) <= 0) {
    print(words[currentWord]);
    String? input = stdin.readLineSync();
    if (input!.toLowerCase() == words[currentWord]) {
      print(ansiColors["green"]! + input + ansiColors["white"]!);
      correctAnswers++;
    } else {
      print(colorizeWord(input, words[currentWord]));
      wrongAnswers++;
    }
    currentWord++;
  }

  print("Wrong: $wrongAnswers");
  print("Correct: $correctAnswers");
  DateTime endTime = DateTime.now();
  print("in ${endTime.difference(startTime).inMilliseconds} ms");
  print(
    "Thats ${(correctAnswers / (endTime.difference(startTime).inMilliseconds / 1000) * 60).toStringAsFixed(1)} wpm",
  );
}

void settingsMenu() {
  print("Settings");
  print("1: Change word Length");
  print("2: Change loaded word count");
  print("3: Change word Language");
  print("4: Change type duration");
  print("5: back");
  var input = stdin.readLineSync();
  switch (input) {
    case "1":
      changeWordLength();
      break;

    case "2":
      changeWordCount();
      break;

    case "3":
      changeLanguage();
      break;

    case "4":
      changeTypeDuartion();
      break;

    case "5":
      main();
      break;
    default:
      settingsMenu();
  }
}

void changeTypeDuartion() {
  print("Chamge type duration (currently: $duration s)");
  var input = stdin.readLineSync();
  int inputInt = int.parse(input!);
  if (inputInt > 300 || inputInt < 5) {
    print("Not a valid input");
  }
  duration = inputInt;
  print("Changed type duartion to $duration s");
  main();
}

void changeLanguage() {
  print("Change language (currently: $language)");

  for (var i = 1; i < languages.length; i++) {
    var language = languages[i]!;
    print("$i: ${language[0]} - ${language[1]}");
  }
  String? input = stdin.readLineSync();
  int inputInt = int.parse(input!);
  if (inputInt <= languages.length && inputInt > 0) {
    language = languages[inputInt]![1];
    print("Changed language to ${languages[inputInt]![0]}");
  } else {
    print("Not a valid input");
  }
  main();
}

void dumpScreen() {}

void changeWordCount() {
  print("Change loaded word count(currently: $wordCount)");
  String? input = stdin.readLineSync();
  int? inputInt = int.tryParse(input!);
  if (inputInt == null) {
    print("Can't change word count to $input!");
  } else {
    wordCount = inputInt;
    print("Changed word count to $inputInt!");
  }
  main();
}

void changeWordLength() {
  String current = wordLengthRandom ? "Random" : wordLength.toString();
  print(
    "Change Word Length (0 for Random or 1-10 for 1-10 Characters; currently: $current)",
  );
  String? input = stdin.readLineSync();
  int? inputInt = int.tryParse(input!);
  if (inputInt == null || inputInt > 10 || inputInt < 0) {
    print("Not a valid number");
  }
  if (inputInt == 0) {
    wordLengthRandom = true;
    print("Word length is now random");
  } else {
    wordLength = inputInt!;
    print("Word length is now $wordLength");
  }
  main();
}

String colorizeWord(String input, String word) {
  String colorized = "";

  for (var i = 0; i < input.length; i++) {
    if (i < word.length) {
      if (input[i] == word[i]) {
        colorized += ansiColors["green"]! + input[i] + ansiColors["white"]!;
      } else {
        colorized += ansiColors["red"]! + input[i] + ansiColors["white"]!;
      }
    } else {
      colorized += ansiColors["red"]! + input[i] + ansiColors["white"]!;
    }
  }

  return colorized;
}

bool showLoadingAnimation = false;

Future<void> loadWords() async {
  Uri url;
  if (wordLengthRandom) {
    url = Uri.parse(
      "https://random-word-api.herokuapp.com/word?number=$wordCount&lang=$language",
    );
  } else {
    url = Uri.parse(
      "https://random-word-api.herokuapp.com/word?length=$wordLength&number=$wordCount&lang=$language",
    );
  }
  var response = await http.get(url);
  var dynamicWords = jsonDecode(response.body);
  for (var word in dynamicWords) {
    words.add(word);
  }
}

Future<void> startLoadingAnimation() async {
  showLoadingAnimation = true;
  List<String> frames = ["Loading", "Loading.", "Loading..", "Loading..."];
  int currentFrame = 0;

  while (showLoadingAnimation) {
    stdout.write("\r${frames[currentFrame % frames.length]}  ");
    await Future.delayed(Duration(milliseconds: 300));
    currentFrame++;
  }
}
