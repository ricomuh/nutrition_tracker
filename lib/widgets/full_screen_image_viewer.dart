import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:typed_data';

class FullScreenImageViewer extends StatelessWidget {
  final String? imagePath;
  final Uint8List? imageBytes;
  final String? heroTag;

  const FullScreenImageViewer({
    super.key,
    this.imagePath,
    this.imageBytes,
    this.heroTag,
  }) : assert(
         imagePath != null || imageBytes != null,
         'Either imagePath or imageBytes must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!kIsWeb) // Only show save button on mobile platforms
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: () => _saveImage(context),
              tooltip: 'Save to Gallery',
            ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareImage(context),
            tooltip: 'Share Image',
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(tag: heroTag ?? 'image_hero', child: _buildImage()),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageBytes != null) {
      return Image.memory(
        imageBytes!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    } else if (imagePath != null) {
      if (kIsWeb) {
        // For web, we might need different handling
        return Image.network(
          imagePath!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      } else {
        return Image.file(
          File(imagePath!),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      }
    }
    return _buildErrorWidget();
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, color: Colors.white, size: 64),
          SizedBox(height: 16),
          Text(
            'Image not available',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Future<void> _saveImage(BuildContext context) async {
    try {
      // Request storage permission
      if (Platform.isAndroid) {
        final permission = await Permission.storage.request();
        if (!permission.isGranted) {
          _showSnackBar(
            context,
            'Storage permission is required to save images',
            isError: true,
          );
          return;
        }
      }

      // Save the image
      var result;
      if (imageBytes != null) {
        result = await ImageGallerySaver.saveImage(imageBytes!);
      } else if (imagePath != null && !kIsWeb) {
        final file = File(imagePath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          result = await ImageGallerySaver.saveImage(bytes);
        } else {
          _showSnackBar(context, 'Image file not found', isError: true);
          return;
        }
      }

      if (result['isSuccess'] == true) {
        _showSnackBar(context, 'Image saved to gallery successfully!');
      } else {
        _showSnackBar(context, 'Failed to save image', isError: true);
      }
    } catch (e) {
      _showSnackBar(context, 'Error saving image: $e', isError: true);
    }
  }

  Future<void> _shareImage(BuildContext context) async {
    // This would require a share plugin, for now just show a message
    _showSnackBar(context, 'Share functionality coming soon!');
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 2),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
