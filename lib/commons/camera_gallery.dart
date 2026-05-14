import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaSourceSheet extends StatelessWidget {
  final void Function(XFile) onImageSelected;
  const MediaSourceSheet({super.key, required this.onImageSelected});

  Future<void> _pick(ImageSource source, BuildContext context) async {
    // Camera needs runtime permission; gallery typically does not on Android
    // because the picker uses system UI. iOS still needs Photos permission.
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission denied')),
        );
        return;
      }
    } else {
      // Gallery
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gallery permission denied')),
          );
          return;
        }
      }
    }

    // 2. Pick image
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (file != null) {
      onImageSelected(file);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.orange),
            title: const Text('Take Photo'),
            onTap: () => _pick(ImageSource.camera, context),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.orange),
            title: const Text('Choose from Gallery'),
            onTap: () => _pick(ImageSource.gallery, context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Cancel'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
