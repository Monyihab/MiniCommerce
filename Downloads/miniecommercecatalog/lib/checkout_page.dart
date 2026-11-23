import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'app_state.dart';
import 'product_image.dart';
import 'order_confirmation_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _codeController = TextEditingController();
  String? _codeError;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _applyCode() {
    final input = _codeController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _codeError = 'Enter a discount code';
      });
      return;
    }

    final ok = cart.applyCode(input);
    setState(() {
      _codeError = ok ? null : 'Invalid discount code';
    });

    if (ok) {
      _codeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('10% discount applied'),
        ),
      );
    }
  }

  void _placeOrder() {
    if (cart.isEmpty) {
      return;
    }

    final number = (DateTime.now().millisecondsSinceEpoch % 1000000)
        .toString()
        .padLeft(6, '0');

    final order = OrderSummary(
      number: 'AAST-$number',
      items: cart.items
          .map((i) => CartItem(i.product, quantity: i.quantity))
          .toList(),
      subtotal: cart.subtotal,
      discount: cart.discount,
      shipping: cart.shipping,
      total: cart.total,
      code: cart.appliedCode,
    );

    orderHistory.insert(0, order);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationPage(order: order),
      ),
    );

    cart.clear();
  }

  Widget _qtyControl(CartItem item) {
    final canDecrease = item.quantity > 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => cart.decrease(item),
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              canDecrease ? Icons.remove : Icons.delete_outline,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 40),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${item.quantity}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        InkWell(
          onTap: () => cart.increase(item),
          customBorder: const CircleBorder(),
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.add, size: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _itemCard(CartItem item) {
    return GlassCard(
      bottomMargin: 12,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 84,
            height: 84,
            padding: const EdgeInsets.all(6),
            decoration: productTileDecoration(18),
            child: productImage(item.product, iconSize: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.product.category,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  egp(item.total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _qtyControl(item),
        ],
      ),
    );
  }

  Widget _shippingCard() {
    return GlassCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shipping: ${egp(cart.shipping)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  shippingName,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const Icon(Icons.local_shipping_outlined, color: Colors.white),
        ],
      ),
    );
  }

  Widget _discountCard() {
    final applied = cart.appliedCode;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader(
            icon: Icons.local_offer_outlined,
            title: 'Apply Discount',
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  onSubmitted: (_) => _applyCode(),
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: glassInput(
                    dense: true,
                    radius: 24,
                    hint: 'Discount Code (try $discountCode)',
                    errorText: _codeError,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: whiteButtonStyle(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                  ),
                  onPressed: _applyCode,
                  child: const Text(
                    'Apply',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          if (applied != null) ...[
            const SizedBox(height: 12),
            InputChip(
              label: Text(
                '$applied  (-10%)',
                style: const TextStyle(
                  color: kPink,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              backgroundColor: Colors.white,
              deleteIconColor: kPink,
              side: BorderSide.none,
              deleteIcon: const Icon(Icons.close, size: 14),
              onDeleted: cart.removeCode,
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: bold ? 17 : 15,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: bold ? 18 : 15,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader(
            icon: Icons.receipt_long_outlined,
            title: 'Order Summary',
          ),
          const SizedBox(height: 12),
          _summaryRow('Subtotal', egp(cart.subtotal)),
          if (cart.discount > 0)
            _summaryRow(
              'Discount',
              '- ${egp(cart.discount)}',
              color: kSoftGreen,
            ),
          _summaryRow('Shipping', egp(cart.shipping)),
          Divider(height: 20, color: Colors.white.withValues(alpha: 0.25)),
          _summaryRow('Total', egp(cart.total), bold: true, color: Colors.white),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return GlassBottomBar(
      maxWidth: 700,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Amount to be paid',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  egp(cart.total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              style: whiteButtonStyle(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _placeOrder,
              child: const Text(
                'Place Order',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return GlassScrollView(
      centered: true,
      maxWidth: 420,
      child: GlassCard(
        bottomMargin: 0,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white,
              size: 56,
            ),
            const SizedBox(height: 12),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add some products to get started.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: whiteButtonStyle(padding: const EdgeInsets.all(14)),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.storefront),
                label: const Text(
                  'Browse Products',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    return GlassScrollView(
      maxWidth: 700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...cart.items.map(_itemCard),
          _shippingCard(),
          _discountCard(),
          _summaryCard(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        final empty = cart.isEmpty;
        return GlassPage(
          title: 'Checkout',
          maxWidth: 700,
          bottomBar: empty ? null : _bottomBar(),
          body: empty ? _emptyState() : _content(),
        );
      },
    );
  }
}