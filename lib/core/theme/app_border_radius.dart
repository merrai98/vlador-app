import 'package:flutter/material.dart';

abstract class AppBorderRadius {
  // Standard Circular Border Radius
  static const BorderRadius none = BorderRadius.all(Radius.circular(0));
  static const BorderRadius small = BorderRadius.all(Radius.circular(5));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(8));
  static const BorderRadius large = BorderRadius.all(Radius.circular(10));
  static const BorderRadius extraLarge = BorderRadius.all(Radius.circular(12));
  static const BorderRadius ultraLarge = BorderRadius.all(Radius.circular(52));

  // Fully Circular (For circular elements like buttons or avatars)
  static const BorderRadius circularFull =
      BorderRadius.all(Radius.circular(100));

  // Specific Sides
  static const BorderRadius topRoundedMedium = BorderRadius.only(
    topLeft: Radius.circular(15),
    topRight: Radius.circular(15),
  );

  static const BorderRadius bottomRoundedMedium = BorderRadius.only(
    bottomLeft: Radius.circular(8),
    bottomRight: Radius.circular(8),
  );
}
