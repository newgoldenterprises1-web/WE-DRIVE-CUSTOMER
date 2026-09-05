import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'profile_completion_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  bool _obscureConfirm = true;

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      final user = credential.user;
      if (user == null) throw Exception('Unable to create account');

      await user.updateDisplayName(_name.text.trim());
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'phone': '+91${_phone.text.trim()}',
        'role': 'customer',
        'isActive': true,
        'profileCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => ProfileCompletionScreen(user: user)),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = e.message ?? 'Unable to create account.';
      if (e.code == 'email-already-in-use') message = 'This email is already registered.';
      if (e.code == 'weak-password') message = 'Please use a stronger password.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to create account: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                const Icon(Icons.person_add_alt_1_rounded, color: gold, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Create your WE DRIVE account',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: primary, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter your details to get started.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 28),
                _field(_name, 'Full Name', Icons.person_outline, TextInputType.name),
                const SizedBox(height: 16),
                _field(_email, 'Email Address', Icons.email_outlined, TextInputType.emailAddress),
                const SizedBox(height: 16),
                _field(_phone, 'Mobile Number', Icons.phone_outlined, TextInputType.phone, prefix: '+91 '),
                const SizedBox(height: 16),
                _passwordField(_password, 'Password', _obscure, () => setState(() => _obscure = !_obscure)),
                const SizedBox(height: 16),
                _passwordField(_confirmPassword, 'Confirm Password', _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm), confirm: true),
                const SizedBox(height: 28),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _createAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: _loading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : const Text('Create Account', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Already have an account? Login', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon, TextInputType type, {String? prefix}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      maxLength: type == TextInputType.phone ? 10 : null,
      validator: (value) {
        final v = value?.trim() ?? '';
        if (v.isEmpty) return 'Please enter $label';
        if (label == 'Email Address' && !v.contains('@')) return 'Enter a valid email address';
        if (label == 'Mobile Number' && !RegExp(r'^\d{10}$').hasMatch(v)) return 'Enter a valid 10-digit mobile number';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        prefixIcon: Icon(icon, color: primary),
        counterText: '',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _passwordField(TextEditingController controller, String label, bool obscure, VoidCallback toggle, {bool confirm = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: (value) {
        if ((value ?? '').length < 6) return 'Password must be at least 6 characters';
        if (confirm && value != _password.text) return 'Passwords do not match';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: primary),
        suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility), onPressed: toggle),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      ),
    );
  }
}
