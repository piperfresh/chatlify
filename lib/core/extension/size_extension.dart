import 'package:flutter/material.dart';

extension ResponsiveSizeExtension on num {
  SizedBox get sbW => SizedBox(width: toDouble());

  SizedBox get sbH => SizedBox(height: toDouble());
}
