import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

List<String> words = [];

int wordCount = 100;
int wordLength = 7;
bool wordLengthRandom = false;

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

  while (currentWord < words.length) {
    print(words[currentWord]);
    String? input = stdin.readLineSync();
    if (input == words[currentWord]) {
      print(ansiColors["green"]! + input! + ansiColors["white"]!);
    } else {
      print(colorizeWord(input!, words[currentWord]));
    }
    currentWord++;
  }
}

void settingsMenu() {
  print("Settings");
  print("1: Change word Length");
  print("2: Change loaded word count");
  print("3: Change word Language");
  print("4: back");
  var input = stdin.readLineSync();
  switch (input) {
    case "1":
      changeWordLength();
      break;

    case "2":
      changeWordCount();
      break;

    case "3":

      break;

    case "4":
      main();
    default:
      settingsMenu();
  }
}

void dumpScreen(){

}

void changeWordCount() {
  print("Change loaded word count(currently: $wordCount)");
  String? input = stdin.readLineSync();
  int? inputInt = int.tryParse(input!);
  if (inputInt == null) {
    print("Can't change word count to $input!");
  }
  else{
    wordCount = inputInt;
    print("Changed word count to $inputInt!");
  }
  main();
}

void changeWordLength(){
  String current = wordLengthRandom ? "Random" : wordLength.toString();
  print("Change Word Length (0 for Random or 1-10 for 1-10 Characters; currently: $current)");
  String? input = stdin.readLineSync();
  int? inputInt = int.tryParse(input!);
  if (inputInt == null || inputInt > 10 ||inputInt < 0) {
    print("Not a valid number");
  }
  if (inputInt == 0) {
    wordLengthRandom = true;
    print("Word length is now random");
  }
  else{
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
      "https://random-word-api.herokuapp.com/word?number=$wordCount",
    );
  } else {
    url = Uri.parse(
      "https://random-word-api.herokuapp.com/word?length=$wordLength&number=$wordCount",
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
