import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_state.dart';
import 'checkout_page.dart';
import 'welcome_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _snack(String message, {Color color = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(message)),
    );
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
    _snack('Address saved');
  }

  Future<void> _changePassword() async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => const _PasswordDialog(),
    );
    if (!mounted || changed != true) {
      return;
    }
    _snack('Password updated');
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
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
      MaterialPageRoute(builder: (context) => const WelcomePage()),
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
      builder: (context) => AlertDialog(
        title: const Text('Coupons'),
        content: const Text(
          '$discountCode: 10% off your order.\nApply it on the checkout screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _trackOrder() {
    if (orderHistory.isEmpty) {
      _snack('You have no orders to track yet', color: navy);
      return;
    }

    final latest = orderHistory.first;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Track Order'),
        content: Text(
          'Order ${latest.number}\n'
          'Status: Processing\n'
          'Estimated delivery: 3-5 working days',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckoutPage()),
    );
  }

  Widget _tile(String label, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: navy,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 26, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: navy,
          fontSize: 22,
          fontWeight: FontWeight.bold,
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: navy, size: 28),
      title: Text(
        title,
        style: const TextStyle(color: navy, fontSize: 17),
      ),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, style: const TextStyle(color: Colors.grey)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: navy),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial =
        UserSession.name.isEmpty ? '?' : UserSession.name[0].toUpperCase();

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/AAST.png',
              height: 32,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.school, color: navy);
              },
            ),
            const SizedBox(width: 10),
            const Text(
              'My Profile',
              style: TextStyle(color: navy, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: red, size: 20),
            label: const Text(
              'Logout',
              style: TextStyle(color: red, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: red,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
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
                            color: navy,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              color: Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                UserSession.email.isEmpty
                                    ? 'No email'
                                    : UserSession.email,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.grey),
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
              _sectionTitle('Account Settings'),
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
                  thumbColor: WidgetStateProperty.all(Colors.white),
                  trackColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? red
                        : Colors.black26,
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
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: widget.label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: red,
            foregroundColor: Colors.white,
          ),
          onPressed: _save,
          child: const Text('Save'),
        ),
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
    return AlertDialog(
      title: const Text('Change Password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _newController,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'New password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
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
              decoration: InputDecoration(
                labelText: 'Confirm password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: red,
            foregroundColor: Colors.white,
          ),
          onPressed: _save,
          child: const Text('Update'),
        ),
      ],
    );
  }
}