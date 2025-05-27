import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morse_code/morse_service.dart';
import 'package:torch_light/torch_light.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MorseCodeApp());
}

class MorseCodeApp extends StatelessWidget {
  const MorseCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Morse Code App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MorseCodeHome(),
    );
  }
}

class MorseCodeHome extends StatefulWidget {
  const MorseCodeHome({Key? key}) : super(key: key);

  @override
  _MorseCodeHomeState createState() => _MorseCodeHomeState();
}

class _MorseCodeHomeState extends State<MorseCodeHome> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _receivedController = TextEditingController();
  String _currentMorseChar = '';
  String _morseOutput = '';
  bool _isFlashing = false;

  final Telephony telephony = Telephony.instance;

  final MorseService morseService = MorseService();

  @override
  void initState() {
    super.initState();
    _checkTorchAvailability();
    _requestPermissions();
    _initializeTelephony();
  }

  Future<void> _initializeTelephony() async {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        if (_isMorseCode(message.body ?? '')) {
          _showMessage(
            'Received Morse SMS from ${message.address}: ${message.body}',
          );
          setState(() {
            _receivedController.text = message.body ?? '';
          });
        }
      },
      listenInBackground: false,
    );
  }

  bool _isMorseCode(String text) {
    RegExp morsePattern = RegExp(r'^[.\-\s/]+$');
    return morsePattern.hasMatch(text) && text.trim().isNotEmpty;
  }

  Future<void> _checkTorchAvailability() async {
    try {
      await TorchLight.isTorchAvailable();
    } on Exception catch (e) {
      _showMessage('Torch not available on this device: $e');
    }
  }

  Future<void> _requestPermissions() async {
    await [Permission.sms, Permission.camera].request();
  }

  Future<void> _flashMorseCode() async {
    if (_isFlashing) return;

    setState(() {
      _isFlashing = true;
      _morseOutput = morseService.textToMorse(_textController.text);
    });
    await morseService.flashMorseCode(
      _textController.text,
      onCharFlashing: (char) {
        setState(() {
          _currentMorseChar = char;
        });
      },
      onComplete: () {
        setState(() {
          _currentMorseChar = '';
          _isFlashing = false;
        });
      },
    );
  }

  Future<void> _sendMorseSMS() async {
    if (_phoneController.text.isEmpty || _textController.text.isEmpty) {
      _showMessage('Please enter phone number and text');
      return;
    }

    String morseMessage = morseService.textToMorse(_textController.text);

    try {
      bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;

      if (permissionsGranted != null && permissionsGranted) {
        await telephony.sendSms(
          to: _phoneController.text,
          message: morseMessage,
        );
        _showMessage('Morse code SMS sent successfully!');
      } else {
        _showMessage('SMS permissions not granted');
      }
    } catch (e) {
      _showMessage('Failed to send SMS: $e');
    }
  }

  void _decodeMorseCode() {
    if (_receivedController.text.isEmpty) {
      _showMessage('Please enter received Morse code');
      return;
    }

    try {
      String decodedText = morseService.morseToText(_receivedController.text);
      _showMessage('Decoded text: $decodedText');
    } catch (e) {
      _showMessage('Failed to decode: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _phoneController.dispose();
    _receivedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Morse Code App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Enter text to convert to Morse code',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              if (_morseOutput.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Morse Code: $_morseOutput',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

              const SizedBox(height: 16),
              if (_currentMorseChar.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Current: $_currentMorseChar',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isFlashing ? null : _flashMorseCode,
                child: Text(_isFlashing ? 'Flashing...' : 'Flash Morse Code'),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Enter phone number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _sendMorseSMS,
                child: const Text('Send Morse Code via SMS'),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              TextField(
                controller: _receivedController,
                decoration: const InputDecoration(
                  labelText:
                      'Enter received Morse code (space between letters, / between words)',
                  border: OutlineInputBorder(),
                  helperText:
                      'Incoming Morse SMS will appear here automatically',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _decodeMorseCode,
                child: const Text('Decode Morse Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
