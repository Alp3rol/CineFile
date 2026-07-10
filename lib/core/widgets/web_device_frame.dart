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
  DeviceModel(name: 'iPhone 16', width: 390, height: 844, screenSize: '6.1"', isIos: true),
  DeviceModel(name: 'iPhone 16 Pro', width: 393, height: 852, screenSize: '6.3"', isIos: true),
  DeviceModel(name: 'iPhone 16 Pro Max', width: 430, height: 932, screenSize: '6.9"', isIos: true),
  DeviceModel(name: 'iPad mini', width: 744, height: 1133, screenSize: '8.3"', isIos: true),
  // Android
  DeviceModel(name: 'Galaxy S24', width: 360, height: 780, screenSize: '6.2"', isIos: false),
  DeviceModel(name: 'Galaxy S24+', width: 384, height: 854, screenSize: '6.7"', isIos: false),
  DeviceModel(name: 'Galaxy S24 Ultra', width: 412, height: 915, screenSize: '6.8"', isIos: false),
  DeviceModel(name: 'Pixel 9 Pro', width: 411, height: 914, screenSize: '6.3"', isIos: false),
  DeviceModel(name: 'Pixel 9', width: 393, height: 873, screenSize: '6.3"', isIos: false),
  DeviceModel(name: 'OnePlus 13', width: 412, height: 919, screenSize: '6.8"', isIos: false),
];

class WebDeviceFrame extends StatefulWidget {
  final Widget child;
  const WebDeviceFrame({super.key, required this.child});

  @override
  State<WebDeviceFrame> createState() => _WebDeviceFrameState();
}

class _WebDeviceFrameState extends State<WebDeviceFrame> {
  DeviceModel? _selected;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return widget.child;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (screenWidth < 700) return widget.child;

    return Scaffold(
      backgroundColor: const Color(0xFF07090F),
      body: Stack(
        children: [
          // Arka plan ızgara
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),

          Column(
            children: [
              // ÜST TOOLBAR - Cihaz seçici
              _DeviceToolbar(
                selected: _selected,
                onSelect: (d) => setState(() => _selected = d),
              ),

              // Uygulama alanı
              Expanded(
                child: Center(
                  child: _selected != null
                      ? _PhoneFrame(
                          device: _selected!,
                          screenHeight: screenHeight - 56,
                          child: widget.child,
                        )
                      : ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: widget.child,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeviceToolbar extends StatelessWidget {
  final DeviceModel? selected;
  final Function(DeviceModel?) onSelect;

  const _DeviceToolbar({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const iosColor = Color(0xFF64D2FF);
    const androidColor = Color(0xFF78C257);

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: Row(
        children: [
          // iOS etiketi
          _PlatformLabel(
            icon: Icons.phone_iphone,
            label: 'iOS',
            color: iosColor,
          ),

          // iOS cihazları
          ...allDevices.where((d) => d.isIos).map((d) => _DeviceChip(
                device: d,
                isSelected: selected == d,
                accentColor: iosColor,
                onTap: () => onSelect(selected == d ? null : d),
              )),

          // Ayırıcı
          Container(
            width: 1,
            height: 28,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.white.withOpacity(0.12),
          ),

          // Android etiketi
          _PlatformLabel(
            icon: Icons.phone_android,
            label: 'Android',
            color: androidColor,
          ),

          // Android cihazları
          ...allDevices.where((d) => !d.isIos).map((d) => _DeviceChip(
                device: d,
                isSelected: selected == d,
                accentColor: androidColor,
                onTap: () => onSelect(selected == d ? null : d),
              )),

          const Spacer(),

          // Seçili cihaz bilgisi
          if (selected != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${selected!.width.toInt()}×${selected!.height.toInt()} · ${selected!.screenSize}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => onSelect(null),
                      child: const Icon(Icons.close, size: 13, color: Colors.white38),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlatformLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PlatformLabel({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceChip extends StatelessWidget {
  final DeviceModel device;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _DeviceChip({
    required this.device,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? accentColor.withOpacity(0.6) : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Text(
          device.name,
          style: TextStyle(
            color: isSelected ? accentColor : Colors.white54,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
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
