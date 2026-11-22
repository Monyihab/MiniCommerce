import 'package:flutter/material.dart';
import 'app_state.dart';
import 'app_theme.dart';

class OrderConfirmationPage extends StatelessWidget {
  final OrderSummary order;

  const OrderConfirmationPage({super.key, required this.order});

  Widget _row(
    String label,
    String value, {
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: bold ? 17 : 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: bold ? 19 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(double height) {
    return Divider(height: height, color: Colors.white.withValues(alpha: 0.25));
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Order Confirmed',
      showBack: false,
      maxWidth: 480,
      body: GlassScrollView(
        centered: true,
        maxWidth: 480,
        child: GlassCard(
          bottomMargin: 0,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.green,
                    size: 56,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Thank you, ${UserSession.name}!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your order has been placed successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Order ${order.number}',
                    style: const TextStyle(
                      color: kPink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _divider(32),
              ...order.items.map(
                (item) => _row(
                  '${item.quantity} x ${item.product.name}',
                  egp(item.total),
                ),
              ),
              _divider(24),
              _row('Subtotal', egp(order.subtotal)),
              if (order.discount > 0)
                _row(
                  'Discount',
                  '- ${egp(order.discount)}',
                  color: kSoftGreen,
                ),
              _row('Shipping', egp(order.shipping)),
              const SizedBox(height: 4),
              _row('Total', egp(order.total), bold: true),
              const SizedBox(height: 18),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    color: Colors.white70,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Estimated delivery: 3-5 working days',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: whiteButtonStyle(padding: const EdgeInsets.all(14)),
                onPressed: () {
                  Navigator.popUntil(
                    context,
                    (route) => route.settings.name == '/home',
                  );
                },
                icon: const Icon(Icons.storefront),
                label: const Text(
                  'Continue Shopping',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
