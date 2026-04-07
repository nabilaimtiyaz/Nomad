import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/app_state.dart';
import '../home/main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _agreed  = false;
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _phoneCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Centang persetujuan Terms of Service terlebih dahulu')));
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // Daftarkan user baru — login dengan data dari form
    AppStateProvider.of(context).login(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );

    setState(() => _loading = false);
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Text('THE DIGITAL CURATOR', style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: AppColors.primary, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                const Text('Begin your journey.', style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary, height: 1.1)),
                const SizedBox(height: 8),
                Row(children: [
                  const Text('Already have an account? ', style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Log in', style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
                  ),
                ]),
                const SizedBox(height: 24),

                // Bronze Member perks card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.tealLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.teal.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.workspace_premium_rounded,
                          size: 18, color: AppColors.teal),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BRONZE MEMBER STATUS', style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w800,
                          color: AppColors.teal, letterSpacing: 0.8)),
                        SizedBox(height: 4),
                        Text('Daftar sekarang dan mulai kumpulkan poin dari setiap transaksi. Naik tier untuk benefit lebih banyak!',
                            style: TextStyle(fontSize: 12, color: AppColors.teal, height: 1.45)),
                      ],
                    )),
                  ]),
                ),
                const SizedBox(height: 24),

                _label('FULL NAME'), const SizedBox(height: 6),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: _deco('Alexander Bennett'),
                  validator: Validators.name,
                ),
                const SizedBox(height: 16),

                _label('EMAIL ADDRESS'), const SizedBox(height: 6),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _deco('name@example.com'),
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),

                _label('PHONE NUMBER'), const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: _deco('+62 812 3456 7890'),
                  validator: Validators.phone,
                ),
                const SizedBox(height: 16),

                _label('PASSWORD'), const SizedBox(height: 6),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: _deco('Minimal 8 karakter').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                        size: 18, color: AppColors.textSecondary),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: Validators.password,
                ),
                const SizedBox(height: 20),

                // Checkbox T&C
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Checkbox(
                    value: _agreed,
                    onChanged: (v) => setState(() => _agreed = v ?? false),
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: RichText(text: TextSpan(
                      style: const TextStyle(fontSize: 12,
                        color: AppColors.textSecondary, height: 1.5),
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(text: 'Terms of Service',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600)),
                        const TextSpan(text: ' and acknowledge the '),
                        TextSpan(text: 'Privacy Policy',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600)),
                        const TextSpan(text: '.'),
                      ],
                    )),
                  )),
                ]),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity, height: 54,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _register,
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
                      : const Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Create Account', style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700,
                              color: Colors.white)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded,
                                size: 18, color: Colors.white),
                          ]),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t, style: const TextStyle(
    fontSize: 10, fontWeight: FontWeight.w700,
    color: AppColors.textSecondary, letterSpacing: 0.8));

  InputDecoration _deco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
    filled: true, fillColor: AppColors.surfaceGrey,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error)),
    focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
  );
}
