import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../services/driver_service.dart';
import '../../theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _authService = AuthService();
  final _driverService = DriverService();

  File? _pickedPhoto;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (picked != null) {
      setState(() => _pickedPhoto = File(picked.path));
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmController.text) {
      setState(() => _errorMessage = l10n.registerScreen_passwordMismatch);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await _authService.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final uid = credential.user!.uid;

      String? photoUrl;
      if (_pickedPhoto != null) {
        photoUrl = await _driverService.uploadProfilePhoto(uid, _pickedPhoto!);
      }

      await _driverService.createDriverProfile(
        uid: uid,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        photoUrl: photoUrl,
      );

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Text(l10n.registerScreen_title, style: TextStyle(color: colors.primary)),
        iconTheme: IconThemeData(color: colors.primary),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: colors.divider,
                        backgroundImage:
                            _pickedPhoto != null ? FileImage(_pickedPhoto!) : null,
                        child: _pickedPhoto == null
                            ? Icon(Icons.person, size: 44, color: colors.textGrey)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: colors.interface,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.background, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildField(
                controller: _nameController,
                label: l10n.registerScreen_nameLabel,
                icon: Icons.person_outline,
                colors: colors,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.registerScreen_nameRequired : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _emailController,
                label: l10n.registerScreen_emailLabel,
                icon: Icons.email_outlined,
                colors: colors,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v == null || !v.contains('@')) ? l10n.registerScreen_emailInvalid : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _phoneController,
                label: l10n.registerScreen_phoneLabel,
                icon: Icons.phone_outlined,
                colors: colors,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.registerScreen_phoneRequired : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _passwordController,
                label: l10n.registerScreen_passwordLabel,
                icon: Icons.lock_outline,
                colors: colors,
                obscureText: true,
                validator: (v) =>
                    (v == null || v.length < 6) ? l10n.registerScreen_passwordMinLength : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _confirmController,
                label: l10n.registerScreen_confirmPasswordLabel,
                icon: Icons.lock_outline,
                colors: colors,
                obscureText: true,
                validator: (v) =>
                    (v == null || v.isEmpty) ? l10n.registerScreen_confirmRequired : null,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(_errorMessage!,
                    style: TextStyle(color: colors.error, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.4),
                        )
                      : Text(l10n.registerScreen_submitButton,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: Text(l10n.registerScreen_alreadyAccount,
                      style: TextStyle(color: colors.interface)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required dynamic colors,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(color: colors.primary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colors.textGrey),
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
