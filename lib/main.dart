import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MaterialApp(home: VIPWorkstation(), debugShowCheckedModeBanner: false));
}

class VIPWorkstation extends StatefulWidget {
  const VIPWorkstation({super.key});
  @override
  State<VIPWorkstation> createState() => _VIPWorkstationState();
}

class _VIPWorkstationState extends State<VIPWorkstation> {
  late final WebViewController controller;
  double mouseX = 300.0;
  double mouseY = 150.0;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (String url) {
          // Paksa layar jadi mode Desktop 1440p
          controller.runJavaScript("""
            var meta = document.querySelector('meta[name="viewport"]');
            if(meta) meta.remove();
            meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=1440, initial-scale=0.5, maximum-scale=0.5, user-scalable=no';
            document.head.appendChild(meta);
          """);
        },
      ))
      ..loadRequest(Uri.parse('https://app.flutterflow.io'));
  }

  void _sendClick() {
    // Sistem Klik Mouse Super Kuat
    controller.runJavaScript("""
      var el = document.elementFromPoint($mouseX, $mouseY);
      if(el) {
        el.focus();
        var evDown = new PointerEvent('pointerdown', {bubbles: true, clientX: $mouseX, clientY: $mouseY});
        var evUp = new PointerEvent('pointerup', {bubbles: true, clientX: $mouseX, clientY: $mouseY});
        el.dispatchEvent(evDown);
        el.dispatchEvent(evUp);
        el.click();
      }
    """);
  }

  void _sendKey(String key) {
    controller.runJavaScript("window.dispatchEvent(new KeyboardEvent('keydown', {key: '$key', bubbles: true}));");
  }
  
  void _scroll(int amount) {
    controller.runJavaScript("window.scrollBy(0, $amount);");
  }

  void _showTypingDialog() {
    TextEditingController txtCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text("Ketik Teks / Login", style: TextStyle(color: Colors.white, fontSize: 16)),
          content: TextField(
            controller: txtCtrl,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Masukkan teks di sini...",
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Batal", style: TextStyle(color: Colors.grey))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                String text = txtCtrl.text.replaceAll("'", "\\'");
                // Tembak teks ke dalam situs
                controller.runJavaScript("""
                  var el = document.activeElement;
                  if(el) {
                    document.execCommand('insertText', false, '$text');
                    el.dispatchEvent(new Event('input', { bubbles: true }));
                    el.dispatchEvent(new Event('change', { bubbles: true }));
                  }
                """);
                Navigator.pop(context);
              },
              child: const Text("Kirim Teks", style: TextStyle(color: Colors.white)),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Lapisan 1: Web diblokir total dari jari
                IgnorePointer(
                  ignoring: true,
                  child: WebViewWidget(controller: controller),
                ),
                // Lapisan 2: Kaca Trackpad untuk Mouse
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
                // Lapisan 3: Kursor Panah Putih
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
          // Barisan Tombol VIP Pro di Bawah
          Container(
            color: const Color(0xFF121212),
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              children: [
                _actionBtn("⌨️ KETIK", _showTypingDialog, Colors.blue[700]!),
                _actionBtn("↑ SCROLL", () => _scroll(-150), Colors.green[800]!),
                _actionBtn("↓ SCROLL", () => _scroll(150), Colors.green[800]!),
                const VerticalDivider(color: Colors.grey, width: 20, indent: 10, endIndent: 10),
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

  Widget _actionBtn(String label, VoidCallback onTap, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10)),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _vipBtn(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C2C2C), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10)),
        onPressed: () => _sendKey(key),
        child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
