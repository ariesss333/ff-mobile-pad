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
  bool showTools = false; // Menyembunyikan keyboard secara default

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (String url) {
          // KODE RAHASIA: Memaksa situs mengecil seperti layar PC 1440p
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
    // KLIK KELAS BERAT: Tembus sistem Canvas FlutterFlow
    controller.runJavaScript("""
      var el = document.elementFromPoint($mouseX, $mouseY);
      if(el) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. WEBVIEW DENGAN PERISAI MUTLAK (100% Mustahil disentuh jari)
          IgnorePointer(
            ignoring: true,
            child: WebViewWidget(controller: controller),
          ),

          // 2. KACA TRACKPAD (Jari cuma buat gerakin kursor panah)
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

          // 3. KURSOR PANAH PUTIH
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

          // 4. MENU VIP (Hanya muncul kalau tombol ditekan)
          if (showTools)
            Positioned(
              bottom: 20, left: 20, right: 80,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12)),
                child: Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    _vipBtn("CTRL", "Control"), _vipBtn("ALT", "Alt"), _vipBtn("SHIFT", "Shift"),
                    _vipBtn("BSPACE", "Backspace"), _vipBtn("DEL", "Delete"), _vipBtn("ENTER", "Enter"),
                    _vipBtn("TAB", "Tab"), _vipBtn("ESC", "Escape"),
                  ],
                ),
              ),
            ),

          // 5. TOMBOL ASSISTIVE TRANSPARAN (Di pojok kanan bawah)
          Positioned(
            bottom: 20, right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white.withOpacity(0.3), // Transparan biar ga ganggu
              elevation: 0,
              child: Icon(showTools ? Icons.close : Icons.keyboard, color: Colors.black),
              onPressed: () => setState(() => showTools = !showTools),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vipBtn(String label, String key) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800], minimumSize: const Size(50, 35)),
      onPressed: () => _sendKey(key),
      child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.white)),
    );
  }
}
