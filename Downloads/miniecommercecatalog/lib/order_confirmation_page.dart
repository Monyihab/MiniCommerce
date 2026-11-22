import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_state.dart';
import 'white_card.dart';

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
                color: navy,
                fontSize: bold ? 17 : 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? navy,
              fontSize: bold ? 19 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Order Confirmed',
          style: TextStyle(color: navy, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: WhiteCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 76,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Thank you, ${UserSession.name}!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your order has been placed successfully.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Order ${order.number}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 32),
                  ...order.items.map(
                    (item) => _row(
                      '${item.quantity} x ${item.product.name}',
                      egp(item.total),
                    ),
                  ),
                  const Divider(height: 24),
                  _row('Subtotal', egp(order.subtotal)),
                  if (order.discount > 0)
                    _row(
                      'Discount',
                      '- ${egp(order.discount)}',
                      color: Colors.green,
                    ),
                  _row('Shipping', egp(order.shipping)),
                  const SizedBox(height: 4),
                  _row('Total', egp(order.total), bold: true, color: red),
                  const SizedBox(height: 18),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        color: Colors.grey,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Estimated delivery: 3-5 working days',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(14),
                    ),
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
        ),
      ),
    );
  }
}