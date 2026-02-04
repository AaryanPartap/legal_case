import 'dart:io';
import 'package:flutter/material.dart';

class AvatarCache {
  /// Global notifier
  static final ValueNotifier<File?> notifier = ValueNotifier<File?>(null);

  static File? get image => notifier.value;
  static set image(File? file) => notifier.value = file;
}
