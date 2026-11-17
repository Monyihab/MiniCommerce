
import 'package:flutter/material.dart';
import 'product.dart';
import 'app_colors.dart';

Widget productImage(Product product, {double iconSize = 45}) {
  return Image.asset(
    product.imagePath,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) {
      return Icon(
        Icons.shopping_bag_outlined,
        size: iconSize,
        color: navy,
      );
    },
  );
}
