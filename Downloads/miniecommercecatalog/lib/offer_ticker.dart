import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class OfferTicker extends StatefulWidget {
  const OfferTicker({super.key});

  @override
  State<OfferTicker> createState() => _OfferTickerState();
}

class _OfferTickerState extends State<OfferTicker>
    with SingleTickerProviderStateMixin {
  final ScrollController _controller = ScrollController();
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  static const double _speed = 60;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000;
    _lastElapsed = elapsed;
    if (_controller.hasClients) {
      _controller.jumpTo(_controller.offset + _speed * dt);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_offer, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          const Text(
            'Special offer! ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Get up to ',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '30% OFF',
              style: TextStyle(
                color: Color(0xFFFF1744),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Text(
            ' Your Favorite items!',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
        ),
      ),
      child: ClipRect(
        child: ListView.builder(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Center(child: _buildMessage());
          },
        ),
      ),
    );
  }
}
