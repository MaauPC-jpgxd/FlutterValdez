import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/app_drawer.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;

  bool isLoading = true;
  double progress = 0;
  bool hasError = false;

  final String url = "https://casavaldez.sicarx.shop/";

  @override
  void initState() {
    super.initState();

    controller = WebViewController();

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
    }

    _initWebView();
  }

  Future<void> _initWebView() async {
    await controller.clearCache();
    await controller.clearLocalStorage();

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)

    // 🔥 USER AGENT REAL (ANTI BLOQUEO)
      ..setUserAgent(
        "Mozilla/5.0 (Linux; Android 13; Pixel 7) "
            "AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/120.0.0.0 Mobile Safari/537.36",
      )

      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) {
            setState(() => progress = p / 100);
          },

          onPageStarted: (_) {
            setState(() {
              isLoading = true;
              hasError = false;
            });
          },

          // ✅ CUANDO TERMINA → SIEMPRE QUITAR ERROR
          onPageFinished: (_) async {
            setState(() {
              isLoading = false;
              hasError = false;
            });

            // 🔥 DETECTAR BLOQUEO CLOUDFLARE
            try {
              final html = await controller.runJavaScriptReturningResult(
                "document.documentElement.innerText",
              );

              if (html.toString().toLowerCase().contains("blocked")) {
                _handleBlock();
              }
            } catch (_) {}
          },

          // ✅ SOLO ERROR REAL (NO FALSOS)
          onWebResourceError: (error) {
            if (error.isForMainFrame == true)  {
              setState(() {
                hasError = true;
                isLoading = false;
              });
            }
          },

          // 🔗 LINKS EXTERNOS
          onNavigationRequest: (request) async {
            final url = request.url;

            if (url.contains("wa.me") || url.contains("whatsapp")) {
              await launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              );
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )

      ..loadRequest(Uri.parse(url));
  }

  // 🔥 SI CLOUDFLARE BLOQUEA → ABRIR NAVEGADOR
  void _handleBlock() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Protección detectada, abriendo navegador..."),
      ),
    );

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  // 🔄 REINTENTO
  void _reload() {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    controller.loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),

      appBar: AppBar(
        title: const Text("Depósito Valdez"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          )
        ],
      ),

      body: Stack(
        children: [
          // 🔥 SIEMPRE MOSTRAR WEBVIEW (CLAVE)
          WebViewWidget(controller: controller),

          // 🔄 PROGRESS BAR
          if (progress < 1)
            LinearProgressIndicator(
              value: progress,
              color: const Color(0xFF1565C0),
            ),

          // ⏳ LOADING
          if (isLoading)
            const Center(child: CircularProgressIndicator()),

          // ❌ ERROR SOLO ENCIMA (NO REEMPLAZA)
          if (hasError)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off,
                        size: 60, color: Colors.grey),
                    const SizedBox(height: 10),
                    const Text("Error de conexión"),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _reload,
                      child: const Text("Reintentar"),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),

      // 💬 WHATSAPP
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