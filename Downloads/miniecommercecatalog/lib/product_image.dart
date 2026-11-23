import 'package:flutter/material.dart';
import 'product.dart';
import 'app_theme.dart';

const bool kTransparentProductImages = true;

BoxDecoration productTileDecoration(double radius) {
  return BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(radius),
  );
}

BoxDecoration productHeroDecoration() {
  return glassDecoration(radius: 24, alpha: 0.18);
}

Widget assetImage(String asset, {Widget? fallback}) {
  return Image.asset(
    asset,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) {
      return fallback ?? const SizedBox.shrink();
    },
  );
}

Widget productImage(Product product, {double iconSize = 45}) {
  return assetImage(
    product.imagePath,
    fallback: Icon(
      Icons.shopping_bag_outlined,
      size: iconSize,
      color: Colors.white,
    ),
  );
}