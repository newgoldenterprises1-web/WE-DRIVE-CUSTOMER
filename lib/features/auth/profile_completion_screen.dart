// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_const
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/navigation_screen.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({
    super.key,
    this.user,
  });

  final User? user;

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState
    extends State<ProfileCompletionScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFFF5F7FA);

  final _formKey = GlobalKey<FormState>();

  final _mobileController = TextEditingController();
  final _ageController = TextEditingController();

  String? _gender;

  bool _loading = true;
  bool _saving = false;

  String _name = '';
  String _email = '';
  String? _photoUrl;

  User? get _currentUser =>
      widget.user ?? FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _currentUser;

    if (user == null) {
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = snapshot.data() ?? <String, dynamic>{};

      _name = (data['name'] ?? user.displayName ?? '').toString();

      _email = (data['email'] ?? user.email ?? '').toString();

      _photoUrl =
          (data['photoUrl'] ?? user.photoURL)?.toString();

      final savedPhone =
          (data['phone'] ?? user.phoneNumber ?? '').toString();

      _mobileController.text =
          savedPhone.replaceFirst('+91', '');

      _ageController.text =
          data['age']?.toString() ?? '';

      final savedGender = data['gender']?.toString();

      if (savedGender == 'Male' ||
          savedGender == 'Female' ||
          savedGender == 'Other' ||
          savedGender == 'Prefer not to say') {
        _gender = savedGender;
      }

      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load profile: $e',
          ),
        ),
      );
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = _currentUser;

    if (user == null) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final phone =
          _mobileController.text.trim();

      final age =
          int.parse(_ageController.text.trim());

      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      final existingSnapshot =
          await userRef.get();

      final payload = <String, dynamic>{
        'uid': user.uid,
        'name': _name.isNotEmpty
            ? _name
            : user.displayName,
        'email': _email.isNotEmpty
            ? _email
            : user.email,
        'photoUrl':
            _photoUrl ?? user.photoURL,
        'phone': phone.startsWith('+')
            ? phone
            : '+91$phone',
        'age': age,
        'gender': _gender,
        'role': 'customer',
        'isActive': true,
        'profileCompleted': true,
        'updatedAt':
            FieldValue.serverTimestamp(),
        if (!existingSnapshot.exists)
          'createdAt':
              FieldValue.serverTimestamp(),
      };

      await userRef.set(
        payload,
        SetOptions(merge: true),
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const NavigationScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to save profile: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 28,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Complete Profile',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: gold,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  28,
                  24,
                  24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildProfileAvatar(),

                      const SizedBox(height: 24),

                      Text(
                        _name.isEmpty
                            ? 'Welcome to WE DRIVE'
                            : 'Welcome, $_name',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: primary,
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Just a few details to get you started',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF596273),
                          fontSize: 17,
                        ),
                      ),

                      const SizedBox(height: 30),

                      _buildMobileField(),

                      const SizedBox(height: 16),

                      _buildAgeField(),

                      const SizedBox(height: 16),

                      _buildGenderField(),

                      const SizedBox(height: 30),

                      _buildSaveButton(),

                      const SizedBox(height: 20),

                      _buildSecurityNote(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProfileAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 126,
          height: 126,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: primary,
              width: 5,
            ),
          ),
          child: ClipOval(
            child: _photoUrl != null &&
                    _photoUrl!.isNotEmpty
                ? Image.network(
                    _photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) {
                      return _defaultAvatar();
                    },
                  )
                : _defaultAvatar(),
          ),
        ),

        Positioned(
          right: -2,
          bottom: 0,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: gold,
              shape: BoxShape.circle,
              border: Border.all(
                color: background,
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
        ),
      ],
    );
  }

  Widget _defaultAvatar() {
    return const Center(
      child: Icon(
        Icons.person_rounded,
        color: primary,
        size: 68,
      ),
    );
  }

  Widget _buildMobileField() {
    return _profileField(
      icon: Icons.phone_iphone_rounded,
      label: 'Mobile Number',
      controller: _mobileController,
      hint: '9876543210',
      keyboardType: TextInputType.phone,
      trailing: const Icon(
        Icons.check_circle_outline_rounded,
        color: gold,
        size: 32,
      ),
      validator: (value) {
        final phone = value?.trim() ?? '';

        if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
          return 'Enter a valid 10-digit mobile number';
        }

        return null;
      },
    );
  }

  Widget _buildAgeField() {
    return _profileField(
      icon: Icons.cake_rounded,
      label: 'Age',
      controller: _ageController,
      hint: 'Enter your age',
      keyboardType: TextInputType.number,
      trailing: const Icon(
        Icons.calendar_month_outlined,
        color: gold,
        size: 31,
      ),
      validator: (value) {
        final age = int.tryParse(
          value?.trim() ?? '',
        );

        if (age == null ||
            age < 18 ||
            age > 100) {
          return 'Enter a valid age (18-100)';
        }

        return null;
      },
    );
  }

  Widget _buildGenderField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.06,
            ),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _fieldIcon(
            Icons.person_outline_rounded,
          ),

          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _gender,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: gold,
                size: 34,
              ),
              decoration: const InputDecoration(
                labelText: 'Gender',
                hintText: 'Select your gender',
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 20,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Male',
                  child: Text('Male'),
                ),
                DropdownMenuItem(
                  value: 'Female',
                  child: Text('Female'),
                ),
                DropdownMenuItem(
                  value: 'Other',
                  child: Text('Other'),
                ),
                DropdownMenuItem(
                  value: 'Prefer not to say',
                  child: Text(
                    'Prefer not to say',
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _gender = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Select your gender';
                }

                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.06,
            ),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _fieldIcon(icon),

          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLength:
                  keyboardType ==
                          TextInputType.phone
                      ? 10
                      : null,
              validator: validator,
              decoration:
                  InputDecoration(
                labelText: label,
                hintText: hint,
                border: InputBorder.none,
                counterText: '',
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 20,
                ),
              ),
            ),
          ),

          if (trailing != null)
            Padding(
              padding:
                  const EdgeInsets.only(
                right: 20,
              ),
              child: trailing,
            ),
        ],
      ),
    );
  }

  Widget _fieldIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.only(
        left: 14,
      ),
      width: 58,
      height: 58,
      decoration: const BoxDecoration(
        color: primary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: _saving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: gold,
          elevation: 5,
          shadowColor: Colors.black.withValues(
            alpha: 0.20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(24),
          ),
        ),
        child: _saving
            ? const SizedBox(
                width: 28,
                height: 28,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: gold,
                ),
              )
            : Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: gold,
                    size: 38,
                  ),
                  SizedBox(width: 18),
                  Text(
                    'Save & Continue',
                    style: TextStyle(
                      color: gold,
                      fontSize: 21,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSecurityNote() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_rounded,
            color: Colors.white,
            size: 17,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            'Your information is securely stored with WE DRIVE.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF596273),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}