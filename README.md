# MorseCodeApp - Flutter

## Overview
A Flutter mobile application that translates text into Morse code and communicates it through visual LED flashes. The app provides an interactive way to learn and share Morse code messages, complete with SMS integration for sending and receiving encrypted communications.

## Key Features

### Morse Code Translation
- **Text-to-Morse Conversion**: Convert any text phrase into authentic Morse code
- **LED Flash Communication**: Visualize Morse code through your phone's flashlight/LED
- **Real-time Display**: See the Morse code pattern for each character as it flashes

### Communication
- **SMS Integration**: Send Morse code messages directly via text message
- **Message Decryption**: Automatically decrypt received Morse code SMS messages
- **Two-way Communication**: Both encode and decode Morse code seamlessly

## Technologies Used
- **Flutter** - Cross-platform mobile development framework
- **Dart** - Programming language
- **Camera/Torch Plugin** - LED flashlight control
- **SMS Plugin** - SMS sending and receiving functionality

## How It Works
1. **Encode**: Enter a text phrase in the input field
2. **Flash**: Press the button to trigger LED flashing in Morse code pattern
3. **Display**: Watch the corresponding Morse code symbols appear on screen in real-time
4. **Share**: Send your Morse code message via SMS to another user
5. **Decode**: Receive and automatically decrypt Morse code SMS messages
   
## Requirements
- Flutter SDK 3.0 or higher
- Dart 2.17 or higher
- Android/iOS device with LED flash capability
- SMS permissions for message functionality

## Permissions
The app requires the following permissions:
- **Camera/Flashlight**: To control the LED for Morse code flashing
- **SMS**: To send and receive Morse code messages
