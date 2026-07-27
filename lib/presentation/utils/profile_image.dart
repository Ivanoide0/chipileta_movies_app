import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ProfileImage {
  static ImageProvider? provider(String? base64Photo) {
    final bytes = _decode(base64Photo);
    if (bytes == null) return null;
    return MemoryImage(bytes);
  }

  static bool hasPhoto(String? base64Photo) => _decode(base64Photo) != null;

  static Uint8List? _decode(String? base64Photo) {
    if (base64Photo == null || base64Photo.isEmpty) return null;
    try {
      return base64Decode(base64Photo);
    } catch (_) {
      
      return null;
    }
  }
}