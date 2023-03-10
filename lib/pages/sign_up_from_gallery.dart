import 'dart:io';
import 'dart:math' as math;

import 'package:face_net_authentication/locator.dart';
import 'package:face_net_authentication/pages/widgets/app_text_field.dart';
import 'package:face_net_authentication/pages/widgets/auth-action-button.dart';
import 'package:face_net_authentication/services/face_detector_service.dart';
import 'package:face_net_authentication/services/ml_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class SignUpFromGallery extends StatefulWidget {
  const SignUpFromGallery({Key? key}) : super(key: key);

  @override
  State<SignUpFromGallery> createState() => _SignUpFromGalleryState();
}

class _SignUpFromGalleryState extends State<SignUpFromGallery> {
  FaceDetectorService _faceDetectorService = locator<FaceDetectorService>();
  MLService _mlService = locator<MLService>();
  TextEditingController username = TextEditingController();

  File? faceFile;
  _setFace(File? newFace) => setState(() => faceFile = newFace);

  _pick() async {
    final result = await FilePicker.platform.pickFiles(withData: true);

    if (result != null) {
      try {
        await _faceDetectorService
            .detectFacesFromImageFile(result.files[0].path!);

        if (_faceDetectorService.faces.isNotEmpty) {
          final faceDetected = _faceDetectorService.faces[0];
          final file = File(result.files[0].path!);
          _setFace(file);

          _mlService.setCurrentPrediction(file, faceDetected);
        } else {
          print('face is null');
        }
      } catch (e) {
        print('Error _faceDetectorService face => $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            OutlinedButton(
              onPressed: _pick,
              child: Text(
                'pick',
              ),
            ),
            if (faceFile != null)
              Container(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: FittedBox(
                      fit: BoxFit.cover, child: Image.file(faceFile!)),
                ),
              ),
            AppTextField(
              labelText: 'Name',
              controller: username,
            ),
            OutlinedButton(
              onPressed: () => signUp(
                context,
                _mlService,
                username.text,
              ),
              child: Text(
                'SignUp',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
