// import 'dart:convert';
// import 'dart:developer';

// import 'package:amin_test/voice_to_speach.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     checkCodeNamesVersion();
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: SpeechToTextExample(),
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Color(0xff002441),
//         appBar: AppBar(
//           elevation: 0,
//           actions: [
//             IconButton(
//               icon: Icon(Icons.settings),
//               onPressed: () {
//                 // Handle settings button press
//               },
//             ),
//             IconButton(
//               icon: Icon(Icons.menu),
//               onPressed: () {
//                 // Handle menu button press
//               },
//             ),
//           ],
//         ),
//         body: Image.asset("assets/spotlight.png")
//         // Image.asset("assets/backing.png")
//         );
//   }
// }

// class SpotlightPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint shadowPaint = Paint()
//       ..color = Colors.black.withOpacity(0.5)
//       ..style = PaintingStyle.fill;

//     final Path shadowPath = Path()
//       ..moveTo(size.width * 0.5 + 10, 10)
//       ..lineTo(size.width + 10, size.height + 10)
//       ..lineTo(10, size.height + 10)
//       ..close();

//     canvas.drawPath(shadowPath, shadowPaint);

//     final Paint paint = Paint()
//       ..color = Colors.blue[800]!
//       ..style = PaintingStyle.fill;

//     final Path path = Path()
//       ..moveTo(size.width * 0.5, 0)
//       ..lineTo(size.width, size.height)
//       ..lineTo(0, size.height)
//       ..close();

//     canvas.drawPath(path, paint);

//     final Paint ovalPaint = Paint()
//       ..color = Colors.red
//       ..style = PaintingStyle.fill;

//     Rect ovalRect = Rect.fromLTWH(
//       size.width * 0.15,
//       size.height -
//           (size.height *
//               0.08), // Adjust the height to move the oval slightly above the bottom
//       size.width * 0.7,
//       size.height * 0.16,
//     );

//     canvas.drawOval(ovalRect, ovalPaint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }


// Future<void> checkCodeNamesVersion() async {
//   // GitHub raw URL to your .txt file
//   final url = 'https://raw.githubusercontent.com/aminjafari-dev/chechVersion/main/check_versions.txt';

//   // Fetch the file from GitHub
//   final response = await http.get(Uri.parse(url));
  
//   if (response.statusCode == 200) {
//     // Parse the response body as JSON
//     Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    
//     // Get the version of code_names from the file
//     int cloudCodeNamesVersion = jsonResponse['code_names'];

//     // Replace this with the actual current version of your app or logic
//     int localCodeNamesVersion = 0; // Example value
    
//     if (cloudCodeNamesVersion != localCodeNamesVersion) {
//       // Trigger the action, e.g., show a dialog, update something, etc.
//       print("Version mismatch! Need to update.");
//     } else {
//       print("Version is up to date.");
//     }
//   } else {
//     print("Failed to load version file from GitHub: ${response.statusCode}");
//   }
// }



import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Editor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PhotoEditorPage(),
    );
  }
}

class PhotoEditorPage extends StatefulWidget {
  const PhotoEditorPage({Key? key}) : super(key: key);

  @override
  _PhotoEditorPageState createState() => _PhotoEditorPageState();
}

class _PhotoEditorPageState extends State<PhotoEditorPage> {
  File? _image;
  final picker = ImagePicker();

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _cropImage() async {
    if (_image != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: _image!.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _image = File(croppedFile.path);
        });
      }
    }
  }

  Future<void> _saveImage() async {
    if (_image == null) return;

    final status = await Permission.storage.request();
    if (status.isGranted) {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/edited_image_${DateTime.now().millisecondsSinceEpoch}.png';
      await _image!.copy(imagePath);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image saved successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Editor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null) ...[
              Image.file(_image!),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _cropImage,
                child: const Text('Crop Image'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _saveImage,
                child: const Text('Save Image'),
              ),
            ] else
              const Text('No image selected'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImage,
        tooltip: 'Pick Image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}