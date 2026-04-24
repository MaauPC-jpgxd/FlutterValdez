import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const CasaValdezApp());
}

class CasaValdezApp extends StatelessWidget {
  const CasaValdezApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Casa Valdez',
      theme: ThemeData(
        primaryColor: const Color(0xFF1565C0),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double scale1 = 1.0;
  double scale2 = 1.0;

  void irAWeb({bool abrirPromos = false}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => WebPageScreen(abrirPromos: abrirPromos),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void animar(int boton) {
    setState(() {
      if (boton == 1) scale1 = 0.95;
      if (boton == 2) scale2 = 0.95;
    });

    Future.delayed(const Duration(milliseconds: 120), () {
      setState(() {
        scale1 = 1.0;
        scale2 = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Casa Valdez'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.storefront,
                size: 90,
                color: Color(0xFF1565C0),
              ),
              const SizedBox(height: 25),
              const Text(
                "Bienvenido",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Ordena fácil y rápido desde tu celular",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              AnimatedScale(
                scale: scale1,
                duration: const Duration(milliseconds: 120),
                child: ElevatedButton(
                  onPressed: () {
                    animar(1);
                    irAWeb();
                  },
                  child: const Text("Comenzar a pedir"),
                ),
              ),
              const SizedBox(height: 15),
              AnimatedScale(
                scale: scale2,
                duration: const Duration(milliseconds: 120),
                child: ElevatedButton(
                  onPressed: () {
                    animar(2);
                    irAWeb(abrirPromos: true);
                  },
                  child: const Text("Ver promociones 🔥"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WebPageScreen extends StatefulWidget {
  final bool abrirPromos;

  const WebPageScreen({super.key, this.abrirPromos = false});

  @override
  State<WebPageScreen> createState() => _WebPageScreenState();
}

class _WebPageScreenState extends State<WebPageScreen> {
  late final WebViewController controller;
  bool isLoading = true;
  double progress = 0;

  // 🔥 FUNCIÓN MANUAL (NO BOT)
  void abrirPromosManual() async {
    await controller.runJavaScript("""
    (function() {

      function realClick(el) {
        if (!el) return;

        el.scrollIntoView({block: 'center'});

        ['pointerdown','mousedown','mouseup','click'].forEach(type => {
          el.dispatchEvent(new MouseEvent(type, {
            bubbles: true,
            cancelable: true,
            view: window
          }));
        });
      }

      function abrirFiltros() {
        // Busca botón de filtros (icono)
        let btns = document.querySelectorAll('button');

        for (let b of btns) {
          if (b.querySelector('svg')) {
            realClick(b);
            return true;
          }
        }
        return false;
      }

      function clickDepartamentos() {
        let items = document.querySelectorAll('[role="button"]');

        for (let el of items) {
          let txt = el.innerText || "";
          if (txt.toUpperCase().includes("DEPARTAMENTOS")) {
            realClick(el);
            return true;
          }
        }
        return false;
      }

      function clickPromociones() {
        let items = document.querySelectorAll('.MuiListItemButton-root');

        for (let el of items) {
          let txt = el.innerText || "";
          if (txt.toUpperCase().includes("PROMOCIONES")) {
            realClick(el);
            return true;
          }
        }
        return false;
      }

      function clickAceptar() {
        let btns = document.querySelectorAll('button');

        for (let b of btns) {
          let txt = b.innerText || "";
          txt = txt.toUpperCase();

          if (txt.includes("ACEPTAR") || txt.includes("APPLY") || txt.includes("OK")) {
            realClick(b);
            return true;
          }
        }
        return false;
      }

      // 🔁 FLUJO CONTROLADO
      if (!abrirFiltros()) return;

      setTimeout(() => {
        if (!clickDepartamentos()) return;

        setTimeout(() => {
          if (!clickPromociones()) return;

          setTimeout(() => {
            clickAceptar();
          }, 900);

        }, 900);

      }, 900);

    })();
  """);
  }
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
      ..loadRequest(Uri.parse('https://casavaldez.sicarx.shop/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema'),
        actions: [
          TextButton(
            onPressed: abrirPromosManual, // 👈 SOLO MANUAL
            child: const Text(
              "Promociones",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          final uri = Uri.parse("https://wa.me/525549523726");
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        child: const Icon(Icons.chat),
      ),

      body: Stack(
        children: [
          WebViewWidget(controller: controller),

          if (progress < 1)
            LinearProgressIndicator(
              value: progress,
              color: const Color(0xFF1565C0),
            ),

          if (isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}