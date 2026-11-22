import 'package:flutter/material.dart';
import 'product.dart';
import 'app_state.dart';
import 'app_theme.dart';
import 'product_image.dart';
import 'checkout_page.dart';

class DetailsPage extends StatelessWidget {
  final Product product;

  const DetailsPage({
    super.key,
    required this.product,
  });

  void _openCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckoutPage()),
    );
  }

  void _addToCart(BuildContext context) {
    cart.add(product);

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        content: Text('${product.name} added to cart'),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () => _openCart(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Product Details',
      backTooltip: 'Back to Home',
      maxWidth: 700,
      actions: [
        CartHeaderButton(onTap: () => _openCart(context)),
      ],
      body: GlassScrollView(
        maxWidth: 700,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 260,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: productImage(product, iconSize: 80),
            ),
            const SizedBox(height: 16),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: glassDecoration(radius: 24, alpha: 0.18),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 5, color: kPink),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.category,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              product.description,
                              style: const TextStyle(
                                fontSize: 17,
                                height: 1.6,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Divider(
                              color: Colors.white.withValues(alpha: 0.25),
                              height: 1,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              egp(product.price),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: whiteButtonStyle(
                                  padding: const EdgeInsets.all(14),
                                ),
                                onPressed: () => _addToCart(context),
                                icon: const Icon(Icons.add_shopping_cart),
                                label: const Text(
                                  'Add to Cart',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                style: glassOutlinedButtonStyle(),
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Back to Home'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}