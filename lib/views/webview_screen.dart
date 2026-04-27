import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/app_drawer.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen>
    with SingleTickerProviderStateMixin {
  late final WebViewController controller;
  late AnimationController _pulseController;

  bool isLoading = true;
  double progress = 0;
  bool hasError = false;

  final String url = "https://casavaldez.sicarx.shop/";

  // ── Colores (mismo sistema Nu) ─────────────────────────────────────────────
  static const _bg         = Color(0xFF0A0E1A);
  static const _surface    = Color(0xFF111827);
  static const _accent     = Color(0xFF2563EB);
  static const _textPri    = Color(0xFFF1F5F9);
  static const _textSec    = Color(0xFF94A3B8);
  static const _border     = Color(0xFF1E293B);
  static const _errorColor = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();

    // Animación del pulse para el loading
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Barra de estado oscura para coherencia visual
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    controller = WebViewController();

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
    }

    _initWebView();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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
            if (error.isForMainFrame == true) {
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
      SnackBar(
        content: const Text("Protección detectada, abriendo navegador..."),
        backgroundColor: const Color(0xFFB45309),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      backgroundColor: _bg,
      drawer: const AppDrawer(),

      // ── AppBar ──────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(
              Icons.menu_rounded,
              color: _textPri,
              size: 22,
            ),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.store_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "Depósito Valdez",
              style: TextStyle(
                color: _textPri,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 1, color: _border),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: _textSec,
              size: 20,
            ),
            onPressed: _reload,
            tooltip: "Recargar",
          ),
        ],
      ),

      body: Stack(
        children: [
          // 🔥 SIEMPRE MOSTRAR WEBVIEW (CLAVE)
          WebViewWidget(controller: controller),

          // 🔄 BARRA DE PROGRESO ESTILIZADA
          if (progress < 1)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 2,
                backgroundColor: _border,
                valueColor: const AlwaysStoppedAnimation<Color>(_accent),
              ),
            ),

          // ⏳ LOADING OVERLAY
          if (isLoading)
            Container(
              color: _bg,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ícono animado
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) => Transform.scale(
                        scale: 0.92 + (_pulseController.value * 0.08),
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: _accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _accent.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.store_rounded,
                            color: _accent,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Cargando tienda...",
                      style: TextStyle(
                        color: _textSec,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 120,
                      child: LinearProgressIndicator(
                        value: progress > 0 ? progress : null,
                        minHeight: 2,
                        backgroundColor: _border,
                        valueColor:
                        const AlwaysStoppedAnimation<Color>(_accent),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ❌ PANTALLA DE ERROR
          if (hasError)
            Container(
              color: _bg,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: _errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _errorColor.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.wifi_off_rounded,
                          size: 32,
                          color: _errorColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Sin conexión",
                        style: TextStyle(
                          color: _textPri,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Revisa tu conexión a internet\ne intenta de nuevo",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _textSec,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _reload,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text(
                            "Reintentar",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),

      // 💬 BOTÓN WHATSAPP
      floatingActionButton: _WhatsAppFAB(),
    );
  }
}

// ── FAB de WhatsApp personalizado ─────────────────────────────────────────────
class _WhatsAppFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse("https://wa.me/525549523726");
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF16A34A),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF16A34A).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              "WhatsApp",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}