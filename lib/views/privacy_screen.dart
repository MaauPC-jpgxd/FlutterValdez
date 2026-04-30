import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _bg      = Color(0xFF0A0E1A);
  static const _surface = Color(0xFF111827);
  static const _accent  = Color(0xFF2563EB);
  static const _textPri = Color(0xFFF1F5F9);
  static const _textSec = Color(0xFF94A3B8);
  static const _border  = Color(0xFF1E293B);

  static const _sections = [
    _PolicySection(
      number: '1',
      title: 'Información general',
      body:
      'En Depósito Valdez, respetamos tu privacidad y nos comprometemos a proteger '
          'la información personal que nos proporcionas al usar nuestra aplicación. '
          'Esta política explica qué datos recopilamos, cómo los usamos y cómo los protegemos.',
    ),
    _PolicySection(
      number: '2',
      title: 'Información que recopilamos',
      body:
      'Datos personales: nombre completo, correo electrónico y número telefónico.\n\n'
          'Datos del negocio: nombre del negocio, teléfono y dirección.\n\n'
          'Datos de autenticación: información de inicio de sesión gestionada mediante '
          'Firebase Authentication (Google).',
    ),
    _PolicySection(
      number: '3',
      title: 'Cómo usamos tu información',
      body:
      'Usamos tu información para:\n\n'
          '• Crear y administrar tu cuenta.\n'
          '• Permitir el acceso seguro a la aplicación.\n'
          '• Identificarte dentro del sistema.\n'
          '• Mejorar la experiencia de uso.\n'
          '• Proteger la seguridad de la plataforma.',
    ),
    _PolicySection(
      number: '4',
      title: 'Verificación de correo electrónico',
      body:
      'Para garantizar la seguridad de tu cuenta, se requiere verificar tu correo '
          'electrónico antes de acceder a ciertas funciones. Si no verificas tu cuenta, '
          'el acceso a la aplicación será restringido.',
    ),
    _PolicySection(
      number: '5',
      title: 'Almacenamiento de datos',
      body:
      'Tu información se almacena de forma segura utilizando Firebase Authentication '
          'y Cloud Firestore, ambos servicios de Google LLC. Aplicamos medidas de '
          'seguridad para evitar accesos no autorizados.',
    ),
    _PolicySection(
      number: '6',
      title: 'Compartición de información',
      body:
      'No vendemos, alquilamos ni compartimos tu información personal con terceros '
          'con fines comerciales.\n\n'
          'Solo podremos compartir información cuando sea requerido por ley o sea '
          'estrictamente necesario para proteger nuestros derechos legales.',
    ),
    _PolicySection(
      number: '7',
      title: 'Seguridad',
      body:
      'Implementamos las siguientes medidas de seguridad:\n\n'
          '• Autenticación de usuarios.\n'
          '• Restricciones de acceso mediante reglas de Firebase.\n'
          '• Protección contra accesos no autorizados.',
    ),
    _PolicySection(
      number: '8',
      title: 'Tus derechos',
      body:
      'Tienes derecho a:\n\n'
          '• Acceder a tu información personal.\n'
          '• Modificar tus datos.\n'
          '• Solicitar la eliminación de tu cuenta en cualquier momento.\n\n'
          'Para ejercer cualquiera de estos derechos, contáctanos directamente.',
    ),
    _PolicySection(
      number: '9',
      title: 'Eliminación de cuenta',
      body:
      'Puedes solicitar la eliminación completa de tu cuenta y los datos asociados '
          'contactándonos en cualquier momento. Procesaremos tu solicitud en un plazo razonable.',
    ),
    _PolicySection(
      number: '10',
      title: 'Servicios de terceros',
      body:
      'Esta aplicación utiliza los siguientes servicios de terceros provistos por Google LLC:\n\n'
          '• Firebase Authentication\n'
          '• Cloud Firestore\n\n'
          'Estos servicios pueden recopilar información de acuerdo con sus propias políticas '
          'de privacidad. Te recomendamos revisarlas en policies.google.com/privacy.',
    ),
    _PolicySection(
      number: '11',
      title: 'Cambios en esta política',
      body:
      'Nos reservamos el derecho de modificar esta política en cualquier momento. '
          'Cualquier cambio será notificado dentro de la aplicación. El uso continuado '
          'de la app después de recibir dicho aviso implica tu aceptación de los cambios.',
    ),
  ];

  Future<void> _launchEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'depositocasavaldez01@gmail.com',
      queryParameters: {
        'subject': 'Consulta sobre Políticas de Privacidad – Depósito Valdez',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,

      // ── AppBar ──────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _textPri,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacidad',
          style: TextStyle(
            color: _textPri,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 8),

            // ── Ícono + título ─────────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _accent.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: _accent,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Políticas de privacidad',
                    style: TextStyle(
                      color: _textPri,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Depósito Valdez · Última actualización: abril 2025',
                    style: TextStyle(color: _textSec, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Secciones ──────────────────────────────────────────────────────
            ..._sections.map((s) => _SectionCard(section: s)),

            const SizedBox(height: 8),

            // ── Contacto ───────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _accent.withOpacity(0.20),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿Tienes dudas?',
                    style: TextStyle(
                      color: _textPri,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Si tienes preguntas sobre esta política de privacidad, '
                        'puedes contactarnos directamente.',
                    style: TextStyle(
                      color: _textSec,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: _launchEmail,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: _accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.mail_outline_rounded,
                              color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'depositocasavaldez01@gmail.com',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Footer ─────────────────────────────────────────────────────────
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.store_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Depósito Valdez',
                    style: TextStyle(color: _textSec, fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Modelo de sección ────────────────────────────────────────────────────────

class _PolicySection {
  final String number;
  final String title;
  final String body;
  const _PolicySection({
    required this.number,
    required this.title,
    required this.body,
  });
}

// ── Widget de tarjeta por sección ────────────────────────────────────────────

class _SectionCard extends StatefulWidget {
  final _PolicySection section;
  const _SectionCard({required this.section});

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _expanded = false;

  static const _bg      = Color(0xFF111827);
  static const _accent  = Color(0xFF2563EB);
  static const _textPri = Color(0xFFF1F5F9);
  static const _textSec = Color(0xFF94A3B8);
  static const _border  = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        widget.section.number,
                        style: const TextStyle(
                          color: _accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.section.title,
                      style: const TextStyle(
                        color: _textPri,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: _textSec,
                    size: 20,
                  ),
                ],
              ),
            ),

            // ── Cuerpo expandible ────────────────────────────────────────────
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 1,
                      color: _border,
                      margin: const EdgeInsets.only(bottom: 14),
                    ),
                    Text(
                      widget.section.body,
                      style: const TextStyle(
                        color: _textSec,
                        fontSize: 13,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 220),
            ),
          ],
        ),
      ),
    );
  }
}