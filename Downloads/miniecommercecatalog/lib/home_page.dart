import 'dart:async';
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'product.dart';
import 'product_data.dart';
import 'app_colors.dart';
import 'app_state.dart';
import 'product_image.dart';
import 'details_page.dart';
import 'checkout_page.dart';
import 'profile_page.dart';
import 'glass_scrollbar.dart';
import 'app_theme.dart';
import 'page_transitions.dart';
import 'guide_message.dart';
import 'app_snackbar.dart';

const Color _pink = Color(0xFFFF1744);
const Color _deepRed = Color(0xFFB30B27);

BoxDecoration _glass({double radius = 24, double alpha = 0.16}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    color: Colors.white.withValues(alpha: alpha),
    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.12),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

class _Category {
  final String label;
  final IconData icon;
  final String? asset;

  const _Category(this.label, this.icon, [this.asset]);
}

const List<_Category> _categories = [
  _Category('All', Icons.apps_rounded),
  _Category('Electronics', Icons.devices, 'assets/Headphones.png'),
  _Category('Clothing', Icons.checkroom, 'assets/CasualShirt.png'),
  _Category('Accessories', Icons.backpack, 'assets/TravelBackpack.png'),
];

class _Promo {
  final String badge;
  final String big;
  final String sub;
  final Product product;

  const _Promo(this.badge, this.big, this.sub, this.product);
}

const List<_Promo> _promos = [
  _Promo('SPECIAL OFFER', '30% OFF', 'On Smart Watches', smartWatch),
  _Promo('HOT DEAL', '30% OFF', 'On Wireless Headphones', headphones),
  _Promo('FLASH SALE', '30% OFF', 'On Running Shoes', runningShoes),
  _Promo('BEST SELLER', '30% OFF', 'On Travel Backpacks', travelBackpack),
];

const Map<String, List<String>> _ratings = {
  'Wireless Headphones': ['4.8', '1.2k'],
  'Smart Watch': ['4.7', '856'],
  'Casual T-Shirt': ['4.5', '640'],
  'Running Shoes': ['4.6', '932'],
  'Coffee Mug': ['4.4', '310'],
  'Travel Backpack': ['4.7', '578'],
};

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _categoriesKey = GlobalKey();
  final GlobalKey _productsKey = GlobalKey();
  final Set<String> _favorites = {};

  Timer? _timer;
  int _bannerIndex = 0;
  int _categoryIndex = 0;
  int _navIndex = 0;
  int _sort = 0;
  bool _favoritesOnly = false;
  bool _showGuide = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageController.hasClients) {
        return;
      }
      final next = (_bannerIndex + 1) % _promos.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showGuide = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  String get _firstName => UserSession.name.split(' ').first;

  String get _productsTitle {
    if (_favoritesOnly) {
      return 'Favorites';
    }
    if (_query.trim().isNotEmpty) {
      return 'Search Results';
    }
    if (_categoryIndex != 0) {
      return _categories[_categoryIndex].label;
    }
    return 'Featured Products';
  }

  List<Product> get _visibleProducts {
    var list = List<Product>.generate(productCount, productAt);

    if (_favoritesOnly) {
      list = list.where((p) => _favorites.contains(p.name)).toList();
    }
    if (_categoryIndex != 0) {
      final label = _categories[_categoryIndex].label;
      list = list.where((p) => p.category == label).toList();
    }
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                p.category.toLowerCase().contains(q),
          )
          .toList();
    }
    if (_sort == 1) {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sort == 2) {
      list.sort((a, b) => b.price.compareTo(a.price));
    }
    return list;
  }

  List<String> _ratingFor(String name) {
    return _ratings[name] ?? const ['4.5', '100'];
  }

  void openDetails(Product product) {
    Navigator.push(
      context,
      slideFadeRoute(page: DetailsPage(product: product)),
    );
  }

  void _openCart() {
    Navigator.push(
      context,
      slideFadeRoute(page: const CheckoutPage()),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      slideFadeRoute(page: const ProfilePage()),
    );
  }

  void _toggleFavorite(Product product) {
    setState(() {
      if (!_favorites.remove(product.name)) {
        _favorites.add(product.name);
      }
    });
  }

  void _addToCart(Product product) {
    cart.add(product);

    showAppSnack(
      context,
      '${product.name} added to cart',
      icon: Icons.shopping_cart_outlined,
      actionLabel: 'VIEW CART',
      onAction: _openCart,
    );
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) {
      return;
    }
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        setState(() {
          _navIndex = 0;
          _favoritesOnly = false;
          _categoryIndex = 0;
          _sort = 0;
          _query = '';
          _searchController.clear();
        });
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        }
        break;
      case 1:
        setState(() {
          _navIndex = 1;
          _favoritesOnly = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollTo(_categoriesKey);
        });
        break;
      case 2:
        setState(() {
          _navIndex = 2;
          _favoritesOnly = true;
          _categoryIndex = 0;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollTo(_productsKey);
        });
        break;
      case 3:
        _openCart();
        break;
      case 4:
        _openProfile();
        break;
    }
  }

  void _resetFilters() {
    setState(() {
      _navIndex = 0;
      _favoritesOnly = false;
      _categoryIndex = 0;
      _sort = 0;
      _query = '';
      _searchController.clear();
    });
  }

  void _showSortSheet() {
    const options = ['Default', 'Price: Low to High', 'Price: High to Low'];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sort by',
                  style: TextStyle(
                    color: navy,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            for (var i = 0; i < options.length; i++)
              ListTile(
                title: Text(options[i]),
                trailing:
                    _sort == i ? const Icon(Icons.check, color: red) : null,
                onTap: () {
                  setState(() {
                    _sort = i;
                  });
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
    int badge = 0,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Badge(
              isLabelVisible: badge > 0,
              backgroundColor: _deepRed,
              textColor: Colors.white,
              label: Text('$badge'),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final initial =
        UserSession.name.isEmpty ? '?' : UserSession.name[0].toUpperCase();

    return Row(
      children: [
        InkWell(
          onTap: _openProfile,
          customBorder: const CircleBorder(),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Text(
                initial,
                style: const TextStyle(
                  color: _pink,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                'Hello $_firstName! 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _circleButton(
          icon: Icons.favorite,
          tooltip: 'Favorites',
          onTap: () => _onNavTap(2),
        ),
        const SizedBox(width: 10),
        ListenableBuilder(
          listenable: cart,
          builder: (context, _) {
            return _circleButton(
              icon: Icons.shopping_cart_outlined,
              tooltip: 'Cart',
              badge: cart.itemCount,
              onTap: _openCart,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 6, 8, 6),
      decoration: _glass(radius: 32, alpha: 0.18),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white70),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
              style: const TextStyle(color: Colors.white, fontSize: 16),
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: 'Search products...',
                hintStyle: TextStyle(color: Colors.white70),
              ),
            ),
          ),
          if (_query.isNotEmpty)
            IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: () {
                setState(() {
                  _query = '';
                  _searchController.clear();
                });
              },
            ),
          InkWell(
            onTap: _showSortSheet,
            customBorder: const CircleBorder(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: _sort == 0 ? 0.2 : 0.5),
              ),
              child: const Icon(Icons.tune, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoSlide(_Promo promo) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(16),
      decoration: _glass(radius: 28, alpha: 0.18),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_offer,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        promo.badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    promo.big,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                    ),
                  ),
                ),
                Text(
                  promo.sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => openDetails(promo.product),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Order Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: productTileDecoration(20),
              child: productImage(promo.product, iconSize: 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(double height) {
    return Column(
      children: [
        SizedBox(
          height: height,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: PageView.builder(
              controller: _pageController,
              itemCount: _promos.length,
              onPageChanged: (index) {
                setState(() {
                  _bannerIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildPromoSlide(_promos[index]);
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_promos.length, (i) {
            final active = i == _bannerIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: active ? 1 : 0.45),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, VoidCallback onSeeAll, {Key? key}) {
    return Row(
      key: key,
      children: [
        Container(
          width: 5,
          height: 26,
          decoration: BoxDecoration(
            color: _pink,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        InkWell(
          onTap: onSeeAll,
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              children: [
                Text('See all', style: TextStyle(color: Colors.white)),
                Icon(Icons.chevron_right, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryRow() {
    return Row(
      children: List.generate(_categories.length, (i) {
        final c = _categories[i];
        final selected = _categoryIndex == i && !_favoritesOnly;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: i == _categories.length - 1 ? 0 : 10,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                setState(() {
                  _categoryIndex = i;
                  _favoritesOnly = false;
                  _navIndex = 0;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                decoration: _glass(
                  radius: 22,
                  alpha: selected ? 0.35 : 0.14,
                ).copyWith(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: selected ? 0.9 : 0.25),
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 56,
                      width: double.infinity,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: c.asset == null || kTransparentProductImages
                            ? Colors.transparent
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: c.asset == null
                          ? Icon(c.icon, color: Colors.white, size: 40)
                          : assetImage(
                              c.asset!,
                              fallback: Icon(
                                c.icon,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        c.label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProductCard(Product product) {
    final rating = _ratingFor(product.name);
    final isFav = _favorites.contains(product.name);

    return InkWell(
      onTap: () => openDetails(product),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: _glass(radius: 24, alpha: 0.18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: productTileDecoration(18),
                      child: productImage(product, iconSize: 40),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: InkWell(
                      onTap: () => _toggleFavorite(product),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFFE3E8),
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: _pink,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 15),
                const SizedBox(width: 4),
                Text(
                  '${rating[0]} (${rating[1]})',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    egp(product.price),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _addToCart(product),
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      color: _pink,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: _glass(radius: 24, alpha: 0.18),
      child: const Column(
        children: [
          Icon(Icons.search_off, color: Colors.white, size: 48),
          SizedBox(height: 10),
          Text(
            'No products found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try a different search or category.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label, {
    int badge = 0,
  }) {
    final selected = _navIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onNavTap(index),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46,
                height: 36,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Badge(
                    isLabelVisible: badge > 0,
                    backgroundColor: Colors.white,
                    textColor: _pink,
                    label: Text('$badge'),
                    child: Icon(
                      selected ? activeIcon : icon,
                      color: selected ? _pink : Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListenableBuilder(
              listenable: cart,
              builder: (context, _) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC5102F).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _navItem(0, Icons.home_outlined, Icons.home, 'Home'),
                      _navItem(
                        1,
                        Icons.grid_view_outlined,
                        Icons.grid_view_rounded,
                        'Categories',
                      ),
                      _navItem(
                        2,
                        Icons.favorite_border,
                        Icons.favorite,
                        'Favorites',
                      ),
                      _navItem(
                        3,
                        Icons.shopping_cart_outlined,
                        Icons.shopping_cart,
                        'Cart',
                        badge: cart.itemCount,
                      ),
                      _navItem(
                        4,
                        Icons.person_outline,
                        Icons.person,
                        'Profile',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceBottom = MediaQuery.of(context).padding.bottom;
    final products = _visibleProducts;

    final columns = screenWidth >= 1000
        ? 4
        : screenWidth >= 700
            ? 3
            : 2;
    final bannerHeight = screenWidth >= 700 ? 230.0 : 190.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBody: true,
        backgroundColor: _deepRed,
        bottomNavigationBar: _buildNavBar(),
        body: Stack(
          fit: StackFit.expand,
          children: [
            const GradientBackground(),
            SafeArea(
              bottom: false,
              child: GlassScrollbar(
                controller: _scrollController,
                inset: EdgeInsets.fromLTRB(0, 8, 4, 96 + deviceBottom),
                child: ScrollConfiguration(
                  behavior:
                      ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 16),
                              _buildSearchBar(),
                              const SizedBox(height: 18),
                              _buildBanner(bannerHeight),
                              const SizedBox(height: 22),
                              _sectionTitle(
                                'Categories',
                                () {
                                  setState(() {
                                    _categoryIndex = 0;
                                    _favoritesOnly = false;
                                    _navIndex = 0;
                                  });
                                },
                                key: _categoriesKey,
                              ),
                              const SizedBox(height: 14),
                              _buildCategoryRow(),
                              const SizedBox(height: 26),
                              _sectionTitle(
                                _productsTitle,
                                _resetFilters,
                                key: _productsKey,
                              ),
                              const SizedBox(height: 14),
                              if (products.isEmpty)
                                _buildEmptyState()
                              else
                                GridView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  itemCount: products.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.74,
                                  ),
                                  itemBuilder: (context, index) {
                                    return _buildProductCard(products[index]);
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_showGuide)
              Positioned(
                left: 12,
                right: 12,
                bottom: 96 + deviceBottom,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: GuideMessage(
                      onClosed: () {
                        if (mounted) {
                          setState(() {
                            _showGuide = false;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}