import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/auth_controller.dart';
import '../widgets/app_drawer.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final auth = AuthController();
  late final WebViewController controller;

  bool isLoading = true;
  double progress = 0;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)

      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) {
            setState(() => progress = p / 100);
          },

          onNavigationRequest: (request) async {
            final url = request.url;

            // 👉 Abrir WhatsApp fuera de la app
            if (url.contains("wa.me") || url.contains("whatsapp")) {
              final uri = Uri.parse(url);
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },

          onPageFinished: (url) {
            setState(() => isLoading = false);
          },
        ),
      )

    // 👉 Fuerza versión móvil (IMPORTANTE)
      ..setUserAgent(
          "Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 Chrome/120 Safari/537.36"
      )

      ..loadRequest(
        Uri.parse("https://casavaldez.sicarx.shop/"),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔥 MENÚ LATERAL
      drawer: const AppDrawer(),

      appBar: AppBar(
        title: const Text("Casa Valdez"),
      ),

      body: Stack(
        children: [
          WebViewWidget(controller: controller),

          // 🔄 Barra de carga
          if (progress < 1)
            LinearProgressIndicator(
              value: progress,
              color: const Color(0xFF1565C0),
            ),

          // ⏳ Loader
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),

      // 💬 BOTÓN WHATSAPP
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          final uri = Uri.parse("https://wa.me/525549523726");
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}