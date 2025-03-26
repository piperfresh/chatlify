import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension ResponsiveSizeExtension on num {
  SizedBox get sbW => SizedBox(width: toDouble().w);

  SizedBox get sbH => SizedBox(height: toDouble().h);
}
