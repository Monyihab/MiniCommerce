import 'package:flutter/material.dart';
import 'product.dart';
import 'app_colors.dart';
import 'app_state.dart';
import 'product_image.dart';
import 'checkout_page.dart';

class DetailsPage extends StatelessWidget {
  final Product product;

  const DetailsPage({
    super.key,
    required this.product,
  });

  void _addToCart(BuildContext context) {
    cart.add(product);

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text('${product.name} added to cart'),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CheckoutPage(),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          tooltip: 'Back to Home',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          ListenableBuilder(
            listenable: cart,
            builder: (context, _) {
              return IconButton(
                tooltip: 'Cart',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckoutPage(),
                    ),
                  );
                },
                icon: Badge(
                  isLabelVisible: cart.itemCount > 0,
                  backgroundColor: navy,
                  textColor: Colors.white,
                  label: Text('${cart.itemCount}'),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/BlackCommerce.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: navy);
            },
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.30),
          ),
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                height: 260,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: lightBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: productImage(product, iconSize: 80),
              ),
              const SizedBox(height: 16),
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: navy,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(width: 6, color: red),
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
                                  color: Colors.white60,
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
                                color: Colors.white.withValues(alpha: 0.2),
                                height: 1,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                '${product.price.toStringAsFixed(0)} EGP',
                                style: const TextStyle(
                                  color: red,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.all(14),
                                  ),
                                  onPressed: () => _addToCart(context),
                                  icon: const Icon(Icons.add_shopping_cart),
                                  label: const Text(
                                    'Add to Cart',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(
                                      color: Colors.white54,
                                    ),
                                    padding: const EdgeInsets.all(14),
                                  ),
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
        ],
      ),
    );
  }
}