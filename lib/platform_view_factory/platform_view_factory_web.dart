// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;
import 'dart:html' as html;

class PlatformViewFactory {
  static void registerImageView(String viewId, String imageUrl) {
    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => html.ImageElement()
        ..src = imageUrl
        ..style.objectFit =
            'contain' // Ensure the image fits within the container
        ..style.width = '100%' // Ensure the width fills the container
        ..style.height = '100%' // Ensure the height fills the container
        ..id = 'image-container',
    );
  }
}
