import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 1. Mengunci Layar ke Mode Landscape & Fullscreen (Immersive)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MaterialApp(home: CustomBrowserScreen(), debugShowCheckedModeBanner: false));
}

class CustomBrowserScreen extends StatefulWidget {
  const CustomBrowserScreen({super.key});

  @override
  State<CustomBrowserScreen> createState() => _CustomBrowserScreenState();
}

class _CustomBrowserScreenState extends State<CustomBrowserScreen> {
  late final WebViewController controller;
  
  // Posisi kursor mouse virtual
  double mouseX = 300.0;
  double mouseY = 150.0;

  @override
  void initState() {
    super.initState();
    // 2. Menyiapkan WebView dan Memaksa Mode Desktop (MacOS)
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15')
      ..loadRequest(Uri.parse('https://app.flutterflow.io'));
  }

  // Fungsi untuk menembakkan klik ke situs web menggunakan JavaScript
  void _simulateClick() {
    controller.runJavaScript('''
      var el = document.elementFromPoint($mouseX, $mouseY);
      if (el) {
        var ev = new MouseEvent('click', {
          'view': window,
          'bubbles': true,
          'cancelable': true,
          'clientX': $mouseX,
          'clientY': $mouseY
        });
        el.dispatchEvent(ev);
      }
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Lapisan Bawah: Situs Web FlutterFlow
          WebViewWidget(controller: controller),

          // 3. Lapisan Kaca Transparan (Sistem Mouse RDP)
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                // Menggerakkan kursor berdasarkan geseran jari (relatif)
                mouseX += details.delta.dx * 1.5; // Angka 1.5 adalah sensitivitas
                mouseY += details.delta.dy * 1.5;
                
                // Mencegah kursor keluar dari layar
                mouseX = mouseX.clamp(0.0, MediaQuery.of(context).size.width);
                mouseY = mouseY.clamp(0.0, MediaQuery.of(context).size.height);
              });
            },
            onTap: _simulateClick, // Klik kiri
            behavior: HitTestBehavior.opaque, // Memblokir sentuhan ke webview di bawahnya
            child: Container(color: Colors.transparent),
          ),

          // 4. Ikon Kursor Mouse Virtual
          Positioned(
            left: mouseX,
            top: mouseY,
            child: const IgnorePointer( // Kursor tidak boleh menghalangi klik
              child: Icon(Icons.mouse, color: Colors.redAccent, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}