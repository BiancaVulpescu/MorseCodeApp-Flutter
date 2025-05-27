import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';

class MorseService {
  static final MorseService _instance = MorseService._internal();
  factory MorseService() {
    return _instance;
  }
  MorseService._internal();

  final Map<String, String> morseCode = {
    'A': '.-',
    'B': '-...',
    'C': '-.-.',
    'D': '-..',
    'E': '.',
    'F': '..-.',
    'G': '--.',
    'H': '....',
    'I': '..',
    'J': '.---',
    'K': '-.-',
    'L': '.-..',
    'M': '--',
    'N': '-.',
    'O': '---',
    'P': '.--.',
    'Q': '--.-',
    'R': '.-.',
    'S': '...',
    'T': '-',
    'U': '..-',
    'V': '...-',
    'W': '.--',
    'X': '-..-',
    'Y': '-.--',
    'Z': '--..',
    '1': '.----',
    '2': '..---',
    '3': '...--',
    '4': '....-',
    '5': '.....',
    '6': '-....',
    '7': '--...',
    '8': '---..',
    '9': '----.',
    '0': '-----',
    ' ': '/',
    '.': '.-.-.-',
    ',': '--..--',
    '?': '..--..',
    '!': '-.-.--',
    ':': '---...',
    '=': '-...-',
    '+': '.-.-.',
    '-': '-....-',
    '/': '-..-.',
  };
  late final Map<String, String> reverseMorseCode = _createReverseDictionary();

  Map<String, String> _createReverseDictionary() {
    final Map<String, String> reverse = {};
    morseCode.forEach((key, value) {
      reverse[value] = key;
    });
    return reverse;
  }

  String textToMorse(String text) {
    if (text.isEmpty) return '';

    String morse = '';
    for (int i = 0; i < text.length; i++) {
      String char = text[i].toUpperCase();
      if (morseCode.containsKey(char)) {
        morse += morseCode[char]! + ' ';
      } else {
        morse +=
            ' '; //adaug un spatiu pt caractere pe care nu le am in dictionarul morse
      }
    }
    return morse.trim();
  }

  String morseToText(String morse) {
    if (morse.isEmpty) return '';

    String text = '';
    List<String> words = morse.split(' / ');

    for (String word in words) {
      List<String> letters = word.trim().split(' ');
      for (String letter in letters) {
        if (letter.isNotEmpty && reverseMorseCode.containsKey(letter)) {
          text += reverseMorseCode[letter]!;
        }
      }
      text += ' ';
    }
    return text.trim();
  }

  Future<void> flashMorseCode(
    String text, {
    required Function(String) onCharFlashing,
    required Function() onComplete,
    int dotDuration = 300,
    int dashDuration = 900,
    int symbolPause = 300,
    int letterPause = 900,
    int wordPause = 2100,
  }) async {
    bool isTorchAvailable = false;
    try {
      isTorchAvailable = await TorchLight.isTorchAvailable();
    } catch (e) {
      debugPrint('Torch not available: $e');
      onComplete();
      return;
    }

    if (!isTorchAvailable) {
      debugPrint('Torch not available on this device');
      onComplete();
      return;
    }

    try {
      for (int i = 0; i < text.length; i++) {
        String char = text[i].toUpperCase();
        if (morseCode.containsKey(char)) {
          String morse = morseCode[char]!;

          onCharFlashing('$char: $morse');

          for (int j = 0; j < morse.length; j++) {
            if (morse[j] == '.') {
              await TorchLight.enableTorch();
              await Future.delayed(Duration(milliseconds: dotDuration));
              await TorchLight.disableTorch();
            } else if (morse[j] == '-') {
              await TorchLight.enableTorch();
              await Future.delayed(Duration(milliseconds: dashDuration));
              await TorchLight.disableTorch();
            } else if (morse[j] == '/') {
              await Future.delayed(Duration(milliseconds: wordPause));
              continue;
            }

            if (j < morse.length - 1) {
              await Future.delayed(Duration(milliseconds: symbolPause));
            }
          }

          if (char == ' ') {
            await Future.delayed(Duration(milliseconds: wordPause));
          } else if (i < text.length - 1) {
            await Future.delayed(Duration(milliseconds: letterPause));
          }
        }
      }
    } catch (e) {
      debugPrint('Error flashing Morse code: $e');
    } finally {
      await TorchLight.disableTorch();
      onComplete();
    }
  }
}
