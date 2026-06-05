import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

const Color _kBackgroundColor = Color(0xFF1E2E58);
const Color _kDogCardColor = Color(0xFF0C50A1);
const Color _kCatCardColor = Color(0xFF6DA8AA);

class PetSection {
  const PetSection({required this.petType, required this.color, required this.parts});
  final String petType;
  final Color color;
  final List<String> parts;
}

const List<PetSection> _kPetSections = [
  PetSection(
    petType: 'DOG',
    color: _kDogCardColor,
    parts: ['EYE', 'EAR', 'BODY', 'FOOT', 'TEETH'],
  ),
  PetSection(
    petType: 'CAT',
    color: _kCatCardColor,
    parts: ['EYE', 'TEETH'],
  ),
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SDK Sample',
      theme: ThemeData(
        scaffoldBackgroundColor: _kBackgroundColor,
        colorScheme: ColorScheme.fromSeed(seedColor: _kBackgroundColor),
        useMaterial3: true,
      ),
      home: const StartActivityScreen(),
    );
  }
}

class StartActivityScreen extends StatefulWidget {
  const StartActivityScreen({super.key});

  @override
  State<StartActivityScreen> createState() => _StartActivityScreenState();
}

class _StartActivityScreenState extends State<StartActivityScreen> {
  static const platform = MethodChannel('com.aiforpet.sdk/channel');

  bool enablesQuestionnaire = true;
  bool enableResultView = true;
  bool enablePdfShare = true;

  String? resultText;
  bool showResultView = false;

  Future<void> launchSdk(String petType, String partType) async {
    try {
      final authConfig = await rootBundle.loadString('assets/auth-config.json');

      final String? result = await platform.invokeMethod('launchSdk', {
        'petType': petType,
        'partType': partType,
        'enablesQuestionnaire': enablesQuestionnaire,
        'enableResultView': enableResultView,
        'enablePdfShare': enablePdfShare,
        'authConfig': authConfig,
      });


      if (result != null) {
        String formattedResult = result;
        try {
          final decoded = json.decode(result);
          formattedResult = const JsonEncoder.withIndent('    ').convert(decoded);
        } on FormatException {
          // Non-JSON payload — fall back to raw text.
        }
        setState(() {
          resultText = formattedResult;
          showResultView = true;
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        resultText = "Error: '${e.message}'.";
        showResultView = true;
      });
    }
  }

  Widget _buildOptionRow(String title, bool value, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Checkbox(
            value: value,
            onChanged: onChanged,
            fillColor: WidgetStateProperty.resolveWith((states) => Colors.white),
            checkColor: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 10, bottom: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, Color bgColor, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        color: bgColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 56,
            alignment: Alignment.center,
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 20),
                _buildOptionRow('enableQuestionnaire', enablesQuestionnaire, (val) {
                  setState(() => enablesQuestionnaire = val ?? true);
                }),
                _buildOptionRow('enableResultView', enableResultView, (val) {
                  setState(() => enableResultView = val ?? true);
                }),
                _buildOptionRow('enablePdfShare', enablePdfShare, (val) {
                  setState(() => enablePdfShare = val ?? true);
                }),
                
                Expanded(
                  child: ListView(
                    children: [
                      for (var i = 0; i < _kPetSections.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        _buildAnimalSection(_kPetSections[i].petType),
                        for (final part in _kPetSections[i].parts)
                          _buildCard(
                            part,
                            _kPetSections[i].color,
                            () => launchSdk(_kPetSections[i].petType, part),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            if (showResultView)
              Container(
                color: const Color(0xAF000000), // Semi-transparent black
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: InkWell(
                        onTap: () => setState(() => showResultView = false),
                        child: Container(
                          height: 58,
                          decoration: BoxDecoration(
                            color: const Color(0x8F000000),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Close',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          resultText ?? '',
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
