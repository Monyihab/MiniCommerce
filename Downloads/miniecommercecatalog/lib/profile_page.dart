import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_theme.dart';
import 'app_state.dart';
import 'checkout_page.dart';
import 'welcome_page.dart';
import 'glass_dialog.dart';
import 'page_transitions.dart';
import 'app_snackbar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _snack(String message, {IconData icon = Icons.check_rounded}) {
    showAppSnack(context, message, icon: icon);
  }

  Future<void> _editName() async {
    final value = await showDialog<String>(
      context: context,
      builder: (context) => _TextEditDialog(
        title: 'Edit Profile',
        label: 'Full name',
        initial: UserSession.name,
        emptyMessage: 'Name cannot be empty',
      ),
    );
    if (!mounted || value == null) {
      return;
    }
    setState(() {
      UserSession.name = value;
    });
    _snack('Name updated');
  }

  Future<void> _editAddress() async {
    final value = await showDialog<String>(
      context: context,
      builder: (context) => _TextEditDialog(
        title: 'Saved Addresses',
        label: 'Delivery address',
        initial: UserSession.address,
        emptyMessage: 'Address cannot be empty',
      ),
    );
    if (!mounted || value == null) {
      return;
    }
    setState(() {
      UserSession.address = value;
    });
    _snack('Address saved', icon: Icons.location_on_outlined);
  }

  Future<void> _changePassword() async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => const _PasswordDialog(),
    );
    if (!mounted || changed != true) {
      return;
    }
    _snack('Password updated', icon: Icons.lock_outline);
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => GlassDialog(
        title: 'Logout',
        content: const Text('Are you sure you want to log out?'),
        actions: [
          GlassDialog.cancel(context, result: false),
          GlassDialog.primary(
            label: 'Logout',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    UserSession.signOut();
    cart.clear();

    Navigator.pushAndRemoveUntil(
      context,
      slideFadeRoute(
        page: const WelcomePage(),
        fromLeft: true,
      ),
      (route) => false,
    );
  }

  void _showOrders() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Orders',
                style: TextStyle(
                  color: navy,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (orderHistory.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'You have not placed any orders yet.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: orderHistory
                        .map(
                          (o) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.receipt_long_outlined,
                              color: red,
                            ),
                            title: Text(
                              o.number,
                              style: const TextStyle(
                                color: navy,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text('${o.itemCount} items'),
                            trailing: Text(
                              egp(o.total),
                              style: const TextStyle(
                                color: red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCoupons() {
    showDialog<void>(
      context: context,
      builder: (context) => GlassDialog(
        title: 'Coupons',
        content: const Text(
          '$discountCode: 10% off your order.\nApply it on the checkout screen.',
        ),
        actions: [
          GlassDialog.primary(
            label: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _trackOrder() {
    if (orderHistory.isEmpty) {
      _snack('You have no orders to track yet', icon: Icons.info_outline);
      return;
    }

    final latest = orderHistory.first;
    showDialog<void>(
      context: context,
      builder: (context) => GlassDialog(
        title: 'Track Order',
        content: Text(
          'Order ${latest.number}\n'
          'Status: Processing\n'
          'Estimated delivery: 3-5 working days',
        ),
        actions: [
          GlassDialog.primary(
            label: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _openCart() {
    Navigator.push(
      context,
      slideFadeRoute(page: const CheckoutPage()),
    );
  }

  Widget _tile(String label, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: glassDecoration(radius: 24, alpha: 0.18),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: glassDecoration(radius: 22, alpha: 0.18),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.22),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
          subtitle: subtitle == null
              ? null
              : Text(subtitle, style: const TextStyle(color: Colors.white70)),
          trailing: trailing ??
              const Icon(Icons.chevron_right, color: Colors.white),
          onTap: onTap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial =
        UserSession.name.isEmpty ? '?' : UserSession.name[0].toUpperCase();

    return GlassPage(
      maxWidth: 600,
      titleWidget: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              'assets/AAST.png',
              height: 28,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.school, color: kPink, size: 28);
              },
            ),
          ),
          const SizedBox(width: 10),
          const Flexible(
            child: Text(
              'My Profile',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      actions: [
        InkWell(
          onTap: _logout,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout, color: Colors.white, size: 20),
                SizedBox(width: 6),
                Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      body: GlassScrollView(
        maxWidth: 600,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: kPink,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${UserSession.name}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              UserSession.email.isEmpty
                                  ? 'No email'
                                  : UserSession.email,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(child: _tile('Your Order', _showOrders)),
                const SizedBox(width: 12),
                Expanded(child: _tile('Your Cart', _openCart)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _tile('Coupons', _showCoupons)),
                const SizedBox(width: 12),
                Expanded(child: _tile('Track Order', _trackOrder)),
              ],
            ),
            const SectionTitle('Account Settings'),
            _settingTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              subtitle: UserSession.name,
              onTap: _editName,
            ),
            _settingTile(
              icon: Icons.location_on_outlined,
              title: 'Saved Addresses',
              subtitle: UserSession.address.isEmpty
                  ? 'Not set'
                  : UserSession.address,
              onTap: _editAddress,
            ),
            _settingTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: _changePassword,
            ),
            _settingTile(
              icon: Icons.notifications_none,
              title: 'Notifications Settings',
              trailing: Switch(
                value: UserSession.notifications,
                thumbColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? Colors.white
                      : Colors.white70,
                ),
                trackColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? kDeepRed
                      : Colors.white.withValues(alpha: 0.15),
                ),
                trackOutlineColor: WidgetStateProperty.all(
                  Colors.white.withValues(alpha: 0.5),
                ),
                onChanged: (value) {
                  setState(() {
                    UserSession.notifications = value;
                  });
                },
              ),
              onTap: () {
                setState(() {
                  UserSession.notifications = !UserSession.notifications;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TextEditDialog extends StatefulWidget {
  final String title;
  final String label;
  final String initial;
  final String emptyMessage;

  const _TextEditDialog({
    required this.title,
    required this.label,
    required this.initial,
    required this.emptyMessage,
  });

  @override
  State<_TextEditDialog> createState() => _TextEditDialogState();
}

class _TextEditDialogState extends State<_TextEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassDialog(
      title: widget.title,
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: glassInput(label: widget.label),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return widget.emptyMessage;
            }
            return null;
          },
          onFieldSubmitted: (_) => _save(),
        ),
      ),
      actions: [
        GlassDialog.cancel(context),
        GlassDialog.primary(label: 'Save', onPressed: _save),
      ],
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog();

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassDialog(
      title: 'Change Password',
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _newController,
              obscureText: _obscure,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: glassInput(
                label: 'New password',
                suffix: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a new password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirmController,
              obscureText: _obscure,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: glassInput(label: 'Confirm password'),
              validator: (value) {
                if (value != _newController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
              onFieldSubmitted: (_) => _save(),
            ),
          ],
        ),
      ),
      actions: [
        GlassDialog.cancel(context),
        GlassDialog.primary(label: 'Update', onPressed: _save),
      ],
    );
  }
}