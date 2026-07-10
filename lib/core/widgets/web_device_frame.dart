import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Telefon modeli veri sınıfı
class DeviceModel {
  final String name;
  final double width;
  final double height;
  final String screenSize;

  const DeviceModel({
    required this.name,
    required this.width,
    required this.height,
    required this.screenSize,
  });
}

// Seçili cihazı tutan provider (Riverpod kullanmadan basit ValueNotifier)
final ValueNotifier<DeviceModel?> selectedDeviceNotifier = ValueNotifier(null);

// iOS Cihazları
const List<DeviceModel> iosDevices = [
  DeviceModel(name: 'iPhone SE', width: 375, height: 667, screenSize: '4.7"'),
  DeviceModel(name: 'iPhone 16', width: 390, height: 844, screenSize: '6.1"'),
  DeviceModel(name: 'iPhone 16 Pro', width: 393, height: 852, screenSize: '6.3"'),
  DeviceModel(
      name: 'iPhone 16 Pro Max', width: 430, height: 932, screenSize: '6.9"'),
  DeviceModel(
      name: 'iPhone 16 Plus', width: 430, height: 932, screenSize: '6.7"'),
  DeviceModel(name: 'iPad mini', width: 744, height: 1133, screenSize: '8.3"'),
];

// Android Cihazları
const List<DeviceModel> androidDevices = [
  DeviceModel(
      name: 'Galaxy S24', width: 360, height: 780, screenSize: '6.2"'),
  DeviceModel(
      name: 'Galaxy S24+', width: 384, height: 854, screenSize: '6.7"'),
  DeviceModel(
      name: 'Galaxy S24 Ultra', width: 412, height: 915, screenSize: '6.8"'),
  DeviceModel(
      name: 'Pixel 9 Pro', width: 411, height: 914, screenSize: '6.3"'),
  DeviceModel(name: 'Pixel 9', width: 393, height: 873, screenSize: '6.3"'),
  DeviceModel(
      name: 'OnePlus 13', width: 412, height: 919, screenSize: '6.8"'),
];

class WebDeviceFrame extends StatefulWidget {
  final Widget child;

  const WebDeviceFrame({super.key, required this.child});

  @override
  State<WebDeviceFrame> createState() => _WebDeviceFrameState();
}

class _WebDeviceFrameState extends State<WebDeviceFrame> {
  DeviceModel? _selectedDevice;
  bool _isIosExpanded = false;
  bool _isAndroidExpanded = false;

  void _selectDevice(DeviceModel? device) {
    setState(() {
      _selectedDevice = device;
      selectedDeviceNotifier.value = device;
    });
  }

  void _clearDevice() {
    setState(() {
      _selectedDevice = null;
      selectedDeviceNotifier.value = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sadece web'de göster
    if (!kIsWeb) return widget.child;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Ekran dar ise panel gösterme, sadece uygulamayı göster
    if (screenWidth < 800) {
      return widget.child;
    }

    final double appWidth = _selectedDevice?.width ?? 480;
    final double appHeight = _selectedDevice?.height ?? screenHeight;

    return Scaffold(
      backgroundColor: const Color(0xFF07090F),
      body: Stack(
        children: [
          // Arka plan ızgara deseni
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(),
            ),
          ),

          Row(
            children: [
              // SOL PANEL - iOS
              _DevicePanel(
                title: 'iOS',
                icon: Icons.phone_iphone,
                iconColor: const Color(0xFF64D2FF),
                accentColor: const Color(0xFF64D2FF),
                devices: iosDevices,
                selectedDevice: _selectedDevice,
                isExpanded: _isIosExpanded,
                onToggle: () =>
                    setState(() => _isIosExpanded = !_isIosExpanded),
                onSelect: _selectDevice,
              ),

              // ORTA - Uygulama
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Cihaz ismi başlık
                      if (_selectedDevice != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.12)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  iosDevices.contains(_selectedDevice)
                                      ? Icons.phone_iphone
                                      : Icons.phone_android,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${_selectedDevice!.name}  •  ${_selectedDevice!.width.toInt()}×${_selectedDevice!.height.toInt()}  •  ${_selectedDevice!.screenSize}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: _clearDevice,
                                  child: const Icon(Icons.close,
                                      size: 14, color: Colors.white38),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Telefon çerçevesi + uygulama
                      Flexible(
                        child: _selectedDevice != null
                            ? _PhoneFrame(
                                device: _selectedDevice!,
                                screenHeight: screenHeight,
                                child: widget.child,
                              )
                            : ConstrainedBox(
                                constraints:
                                    BoxConstraints(maxWidth: appWidth),
                                child: widget.child,
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // SAĞ PANEL - Android
              _DevicePanel(
                title: 'Android',
                icon: Icons.phone_android,
                iconColor: const Color(0xFF78C257),
                accentColor: const Color(0xFF78C257),
                devices: androidDevices,
                selectedDevice: _selectedDevice,
                isExpanded: _isAndroidExpanded,
                onToggle: () =>
                    setState(() => _isAndroidExpanded = !_isAndroidExpanded),
                onSelect: _selectDevice,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Telefon çerçevesi widget'ı
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
    // Ekrana sığdır
    final maxH = screenHeight * 0.88;
    final scale = device.height > maxH ? maxH / device.height : 1.0;
    final displayW = device.width * scale;
    final displayH = device.height * scale;

    const frameThickness = 10.0;
    const cornerRadius = 40.0;
    const notchHeight = 28.0;

    return SizedBox(
      width: displayW + frameThickness * 2,
      height: displayH + frameThickness * 2,
      child: Stack(
        children: [
          // Telefon dış çerçevesi
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
                  BoxShadow(
                    color: Colors.white.withOpacity(0.05),
                    blurRadius: 1,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ),

          // İç ekran alanı
          Positioned(
            left: frameThickness,
            top: frameThickness,
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(cornerRadius - frameThickness),
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

          // Üst notch/Dynamic Island
          Positioned(
            top: frameThickness + 8,
            left: frameThickness + displayW / 2 - 50,
            child: Container(
              width: 100,
              height: notchHeight * scale,
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

// Cihaz seçim paneli
class _DevicePanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color accentColor;
  final List<DeviceModel> devices;
  final DeviceModel? selectedDevice;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Function(DeviceModel?) onSelect;

  const _DevicePanel({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.accentColor,
    required this.devices,
    required this.selectedDevice,
    required this.isExpanded,
    required this.onToggle,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: isExpanded ? 175 : 48,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              // Başlık butonu
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.08),
                    border: Border(
                      bottom: BorderSide(
                          color: accentColor.withOpacity(0.2), width: 1),
                    ),
                  ),
                  child: isExpanded
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, color: iconColor, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              title,
                              style: TextStyle(
                                color: iconColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.chevron_left,
                                color: iconColor.withOpacity(0.6), size: 16),
                          ],
                        )
                      : Column(
                          children: [
                            Icon(icon, color: iconColor, size: 18),
                            const SizedBox(height: 4),
                            RotatedBox(
                              quarterTurns: 1,
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: iconColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              // Cihaz listesi
              if (isExpanded)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      final device = devices[index];
                      final isSelected = selectedDevice == device;

                      return GestureDetector(
                        onTap: () =>
                            onSelect(isSelected ? null : device),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 9),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? accentColor.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? accentColor.withOpacity(0.5)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                device.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? accentColor
                                      : Colors.white70,
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${device.width.toInt()}×${device.height.toInt()} · ${device.screenSize}',
                                style: TextStyle(
                                  color: isSelected
                                      ? accentColor.withOpacity(0.7)
                                      : Colors.white30,
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Arka plan ızgara çizici
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
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
