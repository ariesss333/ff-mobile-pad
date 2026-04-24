import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MaterialApp(home: FFWorkstationVIP(), debugShowCheckedModeBanner: false));
}

class FFWorkstationVIP extends StatefulWidget {
  const FFWorkstationVIP({super.key});
  @override
  State<FFWorkstationVIP> createState() => _FFWorkstationVIPState();
}

class _FFWorkstationVIPState extends State<FFWorkstationVIP> {
  late final WebViewController controller;
  double mouseX = 300.0;
  double mouseY = 150.0;

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

  void _sendKey(String key) {
    controller.runJavaScript("""
      var e = new KeyboardEvent('keydown', {key: '$key', bubbles: true});
      window.dispatchEvent(e);
      document.activeElement.dispatchEvent(e);
    """);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: controller),
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (d) => setState(() {
                      mouseX = (mouseX + d.delta.dx * 1.4).clamp(0, MediaQuery.of(context).size.width);
                      mouseY = (mouseY + d.delta.dy * 1.4).clamp(0, MediaQuery.of(context).size.height);
                    }),
                    onTap: _sendClick,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                Positioned(
                  left: mouseX,
                  top: mouseY,
                  child: IgnorePointer(
                    child: Transform.rotate(
                      angle: -math.pi / 4.5,
                      child: const Icon(Icons.navigation, color: Colors.white, size: 20, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFF121212),
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              children: [
                _vipBtn("CTRL", "Control"), _vipBtn("ALT", "Alt"), _vipBtn("SHIFT", "Shift"),
                _vipBtn("B-SPACE", "Backspace"), _vipBtn("DEL", "Delete"), _vipBtn("ENTER", "Enter"),
                _vipBtn("TAB", "Tab"), _vipBtn("ESC", "Escape"), _vipBtn("SPACE", " "),
                _vipBtn("←", "ArrowLeft"), _vipBtn("↑", "ArrowUp"), _vipBtn("↓", "ArrowDown"), _vipBtn("→", "ArrowRight"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vipBtn(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C2C2C),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        onPressed: () => _sendKey(key),
        child: Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
