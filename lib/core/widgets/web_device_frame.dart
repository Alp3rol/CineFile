import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DeviceModel {
  final String name;
  final double width;
  final double height;
  final String screenSize;
  final bool isIos;

  const DeviceModel({
    required this.name,
    required this.width,
    required this.height,
    required this.screenSize,
    required this.isIos,
  });
}

const List<DeviceModel> allDevices = [
  // iOS
  DeviceModel(name: 'iPhone SE', width: 375, height: 667, screenSize: '4.7"', isIos: true),
  DeviceModel(name: 'iPhone 13 mini', width: 375, height: 812, screenSize: '5.4"', isIos: true),
  DeviceModel(name: 'iPhone 14', width: 390, height: 844, screenSize: '6.1"', isIos: true),
  DeviceModel(name: 'iPhone 15', width: 393, height: 852, screenSize: '6.1"', isIos: true),
  DeviceModel(name: 'iPhone 15 Pro Max', width: 430, height: 932, screenSize: '6.7"', isIos: true),
  DeviceModel(name: 'iPhone 16', width: 390, height: 844, screenSize: '6.1"', isIos: true),
  DeviceModel(name: 'iPhone 16 Pro', width: 393, height: 852, screenSize: '6.3"', isIos: true),
  DeviceModel(name: 'iPhone 16 Pro Max', width: 430, height: 932, screenSize: '6.9"', isIos: true),
  DeviceModel(name: 'iPad mini', width: 744, height: 1133, screenSize: '8.3"', isIos: true),
  // Android
  DeviceModel(name: 'Galaxy Z Flip 6', width: 420, height: 1011, screenSize: '6.7"', isIos: false),
  DeviceModel(name: 'Galaxy Z Fold 6', width: 884, height: 1060, screenSize: '7.6"', isIos: false),
  DeviceModel(name: 'Galaxy S24', width: 360, height: 780, screenSize: '6.2"', isIos: false),
  DeviceModel(name: 'Galaxy S24+', width: 384, height: 854, screenSize: '6.7"', isIos: false),
  DeviceModel(name: 'Galaxy S24 Ultra', width: 412, height: 915, screenSize: '6.8"', isIos: false),
  DeviceModel(name: 'Pixel 8a', width: 412, height: 892, screenSize: '6.1"', isIos: false),
  DeviceModel(name: 'Pixel 9', width: 393, height: 873, screenSize: '6.3"', isIos: false),
  DeviceModel(name: 'Pixel 9 Pro', width: 411, height: 914, screenSize: '6.3"', isIos: false),
  DeviceModel(name: 'OnePlus 13', width: 412, height: 919, screenSize: '6.8"', isIos: false),
  DeviceModel(name: 'Nothing Phone (2)', width: 412, height: 915, screenSize: '6.7"', isIos: false),
  DeviceModel(name: 'Xiaomi 14 Ultra', width: 412, height: 915, screenSize: '6.7"', isIos: false),
];

class WebDeviceFrame extends StatefulWidget {
  final Widget child;
  const WebDeviceFrame({super.key, required this.child});

  @override
  State<WebDeviceFrame> createState() => _WebDeviceFrameState();
}

class _WebDeviceFrameState extends State<WebDeviceFrame> {
  // Varsayılan olarak her zaman iPhone 16 seçili
  late DeviceModel _selected = allDevices.firstWhere((d) => d.name == 'iPhone 16');
  bool _isMenuOpen = false;

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _selectDevice(DeviceModel device) {
    setState(() {
      _selected = device;
      _isMenuOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return widget.child;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Çok küçük ekranlarda cihaz çerçevesini kapat
    if (screenWidth < 700) return widget.child;

    return Scaffold(
      backgroundColor: const Color(0xFF07090F),
      body: Stack(
        children: [
          // Arka plan ızgara
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Basit, hap şeklinde açılır menü butonu
              GestureDetector(
                onTap: _toggleMenu,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_selected.name} • ${_selected.width.toInt()}×${_selected.height.toInt()} • ${_selected.screenSize}',
                        style: const TextStyle(
                          color: Colors.white70, 
                          fontSize: 13, 
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(_isMenuOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white54, size: 18),
                    ],
                  ),
                ),
              ),

              // Uygulama alanı (Telefon Çerçevesi)
              Flexible(
                child: _PhoneFrame(
                  device: _selected,
                  screenHeight: screenHeight - 120, // Menü butonu için biraz daha yer bırak
                  child: widget.child,
                ),
              ),
            ],
          ),

          // Özel Açılır Menü (Dropdown Overlay)
          if (_isMenuOpen)
            Positioned(
              top: screenHeight / 2 - (screenHeight - 120) / 2 - 20, // Butonun hemen altına denk gelmesi için
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 30, offset: const Offset(0, 15)),
                    ],
                  ),
                  constraints: const BoxConstraints(maxHeight: 450),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: allDevices.map((d) {
                        final isSelected = d == _selected;
                        return InkWell(
                          onTap: () => _selectDevice(d),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            color: isSelected ? Colors.white.withOpacity(0.06) : Colors.transparent,
                            child: Row(
                              children: [
                                Icon(
                                  d.isIos ? Icons.phone_iphone : Icons.phone_android,
                                  size: 16,
                                  color: d.isIos ? const Color(0xFF64D2FF) : const Color(0xFF78C257),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    d.name,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white70,
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${d.width.toInt()}×${d.height.toInt()} • ${d.screenSize}',
                                  style: TextStyle(
                                    color: isSelected ? Colors.white70 : Colors.white38,
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Telefon çerçevesi
class _PhoneFrame extends StatelessWidget {
  final DeviceModel device;
  final double screenHeight;
  final Widget child;

  const _PhoneFrame({
    required this.device,
    required this.screenHeight,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final maxH = screenHeight * 0.90;
    final scale = device.height > maxH ? maxH / device.height : 1.0;
    final displayW = device.width * scale;
    final displayH = device.height * scale;

    const frameThickness = 10.0;
    const cornerRadius = 40.0;

    return SizedBox(
      width: displayW + frameThickness * 2,
      height: displayH + frameThickness * 2,
      child: Stack(
        children: [
          // Dış çerçeve
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(cornerRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // Ekran içeriği
          Positioned(
            left: frameThickness,
            top: frameThickness,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(cornerRadius - frameThickness),
              child: SizedBox(
                width: displayW,
                height: displayH,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: device.width,
                    height: device.height,
                    child: child,
                  ),
                ),
              ),
            ),
          ),

          // Dynamic Island / Notch
          Positioned(
            top: frameThickness + 8,
            left: frameThickness + displayW / 2 - 45,
            child: Container(
              width: 90,
              height: 24 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 1;
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
