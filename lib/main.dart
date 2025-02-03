import 'dart:html' as html;
import 'package:challenge_task/platform_view_factory/platform_view_factory_web.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

final imageUrlRegex = RegExp(
    r'^(https?|ftp):\/\/([a-zA-Z0-9\-]+\.)+[a-zA-Z]{2,6}\/[^\s]*\.(jpg|jpeg|png|gif|bmp|webp|svg)$|^data:image\/(jpeg|png|gif|bmp|webp|svg);base64,([A-Za-z0-9+\/=]+)$|^[\w\-\./]+(\.jpg|\.jpeg|\.png|\.gif|\.bmp|\.webp|\.svg)$');

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _urlController = TextEditingController();
  String? imageUrl;
  bool isContextMenuVisible = false;
  OverlayEntry? _overlayEntry;

  // GlobalKey to get the FAB position
  final GlobalKey _fabKey = GlobalKey();

  String currentViewId = "image-view-1"; // Dynamic view ID

  void _registerImageView() {
    if (imageUrl != null) {
      PlatformViewFactory.registerImageView(currentViewId, imageUrl!);
    }
  }

  void _toggleFullScreen() {
    html.document.fullscreenElement != null
        ? html.document.exitFullscreen()
        : html.document.documentElement?.requestFullscreen();
  }

  void _toggleContextMenu() {
    setState(() {
      isContextMenuVisible = !isContextMenuVisible;
    });

    if (isContextMenuVisible) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    // Get the position of the FAB using the GlobalKey
    final RenderBox renderBox =
        _fabKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = MediaQuery.of(context).size;

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeOverlay,
        child: Container(
          height: size.width,
          width: size.height,
          color: Colors.black38,
          child: Stack(
            children: [
              Positioned(
                right: size.width -
                    (position.dx +
                        renderBox.size.width), // Align it with the FAB
                bottom: renderBox.size.height + 20,
                // left: 160,
                child: GestureDetector(
                  onTap: () => _removeOverlay(),
                  child: Material(
                    color: Colors.transparent,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 200,
                            // height: 56,
                            child: ListTile(
                              title: const Text('Enter Fullscreen'),
                              onTap: () {
                                html.document.documentElement
                                    ?.requestFullscreen();
                                _removeOverlay();
                              },
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            // height: 56,
                            child: ListTile(
                              title: const Text('Exit Fullscreen'),
                              onTap: () {
                                html.document.exitFullscreen();
                                _removeOverlay();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    setState(() {
      isContextMenuVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isContextMenuVisible) {
          _removeOverlay();
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: imageUrl == null
                        ? const Center(child: Text('No Image'))
                        : GestureDetector(
                            onDoubleTap: _toggleFullScreen,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: HtmlElementView(viewType: currentViewId),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(hintText: 'Image URL'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final url = _urlController.text.trim();
                      _urlController
                        ..clear()
                        ..clearComposing();
                      if (!imageUrlRegex.hasMatch(url)) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Please enter valid image url")));
                        return;
                      }
                      setState(() {
                        imageUrl = url;

                        // Change the view ID dynamically each time the URL changes
                        currentViewId =
                            "image-view-${DateTime.now().millisecondsSinceEpoch}";
                        _registerImageView();
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                      child: Icon(Icons.arrow_forward),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 64),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          key: _fabKey, // Assign the key to the FAB
          onPressed: _toggleContextMenu,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
