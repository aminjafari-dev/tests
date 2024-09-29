import 'dart:convert';
import 'dart:developer';

import 'package:amin_test/voice_to_speach.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    checkCodeNamesVersion();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SpeechToTextExample(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff002441),
        appBar: AppBar(
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                // Handle settings button press
              },
            ),
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                // Handle menu button press
              },
            ),
          ],
        ),
        body: Image.asset("assets/spotlight.png")
        // Image.asset("assets/backing.png")
        );
  }
}

class SpotlightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final Path shadowPath = Path()
      ..moveTo(size.width * 0.5 + 10, 10)
      ..lineTo(size.width + 10, size.height + 10)
      ..lineTo(10, size.height + 10)
      ..close();

    canvas.drawPath(shadowPath, shadowPaint);

    final Paint paint = Paint()
      ..color = Colors.blue[800]!
      ..style = PaintingStyle.fill;

    final Path path = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);

    final Paint ovalPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    Rect ovalRect = Rect.fromLTWH(
      size.width * 0.15,
      size.height -
          (size.height *
              0.08), // Adjust the height to move the oval slightly above the bottom
      size.width * 0.7,
      size.height * 0.16,
    );

    canvas.drawOval(ovalRect, ovalPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}


Future<void> checkCodeNamesVersion() async {
  // GitHub raw URL to your .txt file
  final url = 'https://raw.githubusercontent.com/aminjafari-dev/chechVersion/main/check_versions.txt';

  // Fetch the file from GitHub
  final response = await http.get(Uri.parse(url));
  
  if (response.statusCode == 200) {
    // Parse the response body as JSON
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    
    // Get the version of code_names from the file
    int cloudCodeNamesVersion = jsonResponse['code_names'];

    // Replace this with the actual current version of your app or logic
    int localCodeNamesVersion = 0; // Example value
    
    if (cloudCodeNamesVersion != localCodeNamesVersion) {
      // Trigger the action, e.g., show a dialog, update something, etc.
      print("Version mismatch! Need to update.");
    } else {
      print("Version is up to date.");
    }
  } else {
    print("Failed to load version file from GitHub: ${response.statusCode}");
  }
}

