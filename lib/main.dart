import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MaterialApp(home: FFWorkstation(), debugShowCheckedModeBanner: false));
}

class FFWorkstation extends StatefulWidget {
  const FFWorkstation({super.key});
  @override
  State<FFWorkstation> createState() => _FFWorkstationState();
}

class _FFWorkstationState extends State<FFWorkstation> {
  late final WebViewController controller;
  double mouseX = 300.0;
  double mouseY = 150.0;
  bool showKeyboard = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
      ..loadRequest(Uri.parse('https://app.flutterflow.io'));
  }

  void _sendClick() {
    controller.runJavaScript("document.elementFromPoint($mouseX, $mouseY).click();");
  }

  void _injectText(String text) {
    controller.runJavaScript("""
      var el = document.activeElement;
      if (el && (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA' || el.isContentEditable)) {
        el.value += '$text';
        el.dispatchEvent(new Event('input', { bubbles: true }));
      }
    """);
  }

  void _sendSpecialKey(String key) {
    controller.runJavaScript("window.dispatchEvent(new KeyboardEvent('keydown', {'key': '$key', 'bubbles': true}));");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. WEBVIEW (Situs FlutterFlow)
          WebViewWidget(controller: controller),

          // 2. SHIELD (Blokir Jari - Jari jadi Trackpad)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (d) => setState(() {
                mouseX = (mouseX + d.delta.dx * 1.5).clamp(0, MediaQuery.of(context).size.width);
                mouseY = (mouseY + d.delta.dy * 1.5).clamp(0, MediaQuery.of(context).size.height);
              }),
              onTap: _sendClick,
              child: Container(color: Colors.transparent),
            ),
          ),

          // 3. KURSOR PANAH PC
          Positioned(
            left: mouseX,
            top: mouseY,
            child: IgnorePointer(
              child: Transform.rotate(
                angle: -math.pi / 4.5,
                child: const Icon(Icons.navigation, color: Colors.white, size: 22, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
              ),
            ),
          ),

          // 4. TOMBOL MELAYANG (Assistive Keyboard)
          Positioned(
            right: 20,
            bottom: showKeyboard ? 180 : 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.blueAccent.withOpacity(0.7),
              child: Icon(showKeyboard ? Icons.keyboard_hide : Icons.keyboard),
              onPressed: () => setState(() => showKeyboard = !showKeyboard),
            ),
          ),

          // 5. KEYBOARD PANEL (Kecil di Bawah)
          if (showKeyboard)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: const Color(0xFF1A1A1A),
                height: 160,
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    // Baris Input Teks Aktif
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: const InputDecoration(hintText: "Ketik di sini...", hintStyle: TextStyle(color: Colors.grey)),
                            onSubmitted: (val) {
                              _injectText(val);
                              _textController.clear();
                            },
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.send, color: Colors.blue), onPressed: () {
                          _injectText(_textController.text);
                          _textController.clear();
                        }),
                      ],
                    ),
                    // Tombol Spesial PC
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _kBtn("CTRL", "Control"), _kBtn("ALT", "Alt"), _kBtn("SHIFT", "Shift"),
                          _kBtn("BSPACE", "Backspace"), _kBtn("DEL", "Delete"),
                          _kBtn("ENTER", "Enter"), _kBtn("TAB", "Tab"), _kBtn("ESC", "Escape"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _kBtn(String label, String key) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800], minimumSize: const Size(60, 40)),
        onPressed: () => _sendSpecialKey(key),
        child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.white)),
      ),
    );
  }
}
