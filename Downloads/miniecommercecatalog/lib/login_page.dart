import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'app_state.dart';
import 'home_page.dart';
import 'fox_avatar.dart';
import 'page_transitions.dart';
import 'shiny_logo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const double _foxWidth = 170;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_refresh);
    _passwordController.addListener(_refresh);
    _emailFocus.addListener(_refresh);
    _passwordFocus.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Offset get _foxLook {
    if (_emailFocus.hasFocus) {
      final t = (_emailController.text.length / 25).clamp(0.0, 1.0).toDouble();
      return Offset(-0.8 + t * 1.6, 0.8);
    }
    if (_passwordFocus.hasFocus) {
      final t =
          (_passwordController.text.length / 12).clamp(0.0, 1.0).toDouble();
      return Offset(-0.3 + t * 0.8, 1.0);
    }
    return const Offset(0, 0.2);
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w\.\-+]+@[\w\-]+(\.[\w\-]+)+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Please enter your password';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      UserSession.signIn(_emailController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Login successful! Welcome ${_emailController.text.trim()}',
          ),
        ),
      );

      Navigator.push(
        context,
        slideFadeRoute(
          settings: const RouteSettings(name: '/home'),
          page: const HomePage(),
        ),
      );
    }
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ShinyLogo(height: 70, fallbackSize: 56),
            const SizedBox(height: 12),
            const Text(
              'Welcome Back',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Login to continue shopping',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: glassInput(
                label: 'Email',
                prefix: const Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              validator: _validatePassword,
              onFieldSubmitted: (_) => _login(),
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: glassInput(
                label: 'Password',
                prefix: const Icon(Icons.lock_outline),
                suffix: IconButton(
                  tooltip:
                      _obscurePassword ? 'Show password' : 'Hide password',
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: whiteButtonStyle(),
              onPressed: _login,
              child: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidePhoto() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/LoginImage.jpg',
              fit: BoxFit.cover,
              alignment: const Alignment(0.45, 0),
              errorBuilder: (context, error, stackTrace) {
                return Container(color: kDeepRed);
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    kDeepRed.withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFox(bool isWide) {
    final look = _foxLook;
    final fox = FoxAvatar(
      lookX: look.dx,
      lookY: look.dy,
      width: _foxWidth,
    );

    if (isWide) {
      return Row(
        children: [
          Expanded(child: Center(child: fox)),
          const Expanded(child: SizedBox()),
        ],
      );
    }
    return Center(child: fox);
  }

  @override
  Widget build(BuildContext context) {
    final foxHeight = FoxAvatar.heightFor(_foxWidth);

    return GlassPage(
      title: 'Login',
      backTooltip: 'Back to Welcome',
      maxWidth: 900,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 750;

          return GlassScrollView(
            centered: true,
            maxWidth: isWide ? 900 : 420,
            padding: const EdgeInsets.fromLTRB(16, 8, 24, 24),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: foxHeight - 6),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: glassDecoration(radius: 28, alpha: 0.18),
                    child: isWide
                        ? SizedBox(
                            height: 480,
                            child: Row(
                              children: [
                                Expanded(child: _buildForm()),
                                Expanded(child: _buildSidePhoto()),
                              ],
                            ),
                          )
                        : _buildForm(),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildFox(isWide),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}