import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/app_state.dart';
import 'register_screen.dart';
import '../home/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure  = true;
  bool _loading  = false;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // Panggil AppState.login() untuk set user sebagai logged in
    // dan simpan data ke state global
    AppStateProvider.of(context).login(email: _emailCtrl.text.trim());

    setState(() => _loading = false);
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const MainScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(children: [
        Container(
          height: screenH * 0.62,
          decoration: const BoxDecoration(gradient: AppColors.gradientHeader),
        ),
        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.coffee_rounded, size: 20, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text('Nomad', style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                      ]),
                      const SizedBox(height: 32),
                      const Text('Welcome\nBack', style: TextStyle(
                        fontSize: 44, fontWeight: FontWeight.w900,
                        color: Colors.white, height: 1.05, letterSpacing: -0.5)),
                      const SizedBox(height: 12),
                      const Text('Your curated morning ritual is just a step away.',
                          style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5)),
                      const SizedBox(height: 20),
                      Row(children: [
                        Container(width: 32, height: 1, color: Colors.white38),
                        const SizedBox(width: 10),
                        const Text('THE DIGITAL CURATOR', style: TextStyle(
                          fontSize: 10, letterSpacing: 2,
                          color: Colors.white54, fontWeight: FontWeight.w600)),
                      ]),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sign In', style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Please enter your credentials to access your Nomad account.',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                        const SizedBox(height: 28),
                        _label('EMAIL ADDRESS'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                          decoration: _udeco('name@example.com', Icons.email_outlined),
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _label('PASSWORD'),
                            GestureDetector(onTap: () {},
                              child: const Text('FORGOT?', style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700,
                                color: AppColors.primary, letterSpacing: 0.5))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                          decoration: _udeco('••••••••', Icons.lock_outline).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(_obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                                size: 18, color: AppColors.textSecondary),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Password tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity, height: 52,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: _loading
                              ? const SizedBox(width: 20, height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                              : const Text('MASUK', style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w800,
                                  color: Colors.white, letterSpacing: 1)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _divider(),
                        const SizedBox(height: 16),
                        Row(children: [
                          Expanded(child: _socialBtn('Google', Icons.g_mobiledata_rounded)),
                          const SizedBox(width: 12),
                          Expanded(child: _socialBtn('Apple', Icons.apple_rounded)),
                        ]),
                        const SizedBox(height: 24),
                        Center(child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? ",
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            GestureDetector(
                              onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen())),
                              child: const Text('Create Account', style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700,
                                color: AppColors.primary)),
                            ),
                          ],
                        )),
                        const SizedBox(height: 20),
                        Center(child: Text('© 2024 Nomad Brew Collective',
                            style: TextStyle(fontSize: 11, color: AppColors.textHint))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _label(String t) => Text(t, style: const TextStyle(
    fontSize: 10, fontWeight: FontWeight.w700,
    color: AppColors.textSecondary, letterSpacing: 1));

  InputDecoration _udeco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
    prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
    border: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.divider)),
    enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.divider)),
    focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
    errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.error)),
    focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.error)),
    contentPadding: const EdgeInsets.symmetric(vertical: 10),
  );

  Widget _divider() => Row(children: [
    const Expanded(child: Divider(color: AppColors.divider)),
    const Padding(padding: EdgeInsets.symmetric(horizontal: 12),
      child: Text('OR CONTINUE WITH', style: TextStyle(
        fontSize: 10, color: AppColors.textHint, letterSpacing: 1))),
    const Expanded(child: Divider(color: AppColors.divider)),
  ]);

  Widget _socialBtn(String label, IconData icon) => OutlinedButton.icon(
    onPressed: () {
      // Google/Apple sign-in: simulasi login langsung
      AppStateProvider.of(context).login();
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const MainScreen()));
    },
    icon: Icon(icon, size: 20, color: AppColors.textPrimary),
    label: Text(label, style: const TextStyle(
      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: const BorderSide(color: AppColors.cardBorder),
      backgroundColor: AppColors.surface,
    ),
  );
}
