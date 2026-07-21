import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Helper utility for capturing and exporting a widget tree (e.g. [GraphCanvas])
/// as a high-resolution PNG image.
class GraphExporter {
  /// Captures the [RenderRepaintBoundary] identified by [key] as a PNG byte array.
  /// Returns null if the boundary is not attached or fails to render.
  static Future<ui.Image?> captureBoundary(GlobalKey key, {double pixelRatio = 3.0}) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 20));
      }

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      return image;
    } catch (_) {
      return null;
    }
  }

  /// Converts a [ui.Image] to PNG byte buffer.
  static Future<List<int>?> imageToPngBytes(ui.Image image) async {
    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }
}
