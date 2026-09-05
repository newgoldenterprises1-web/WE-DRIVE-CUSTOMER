import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/navigation_screen.dart';
import '../auth/profile_completion_screen.dart';

import 'widgets/otp_header.dart';
import 'widgets/otp_input_field.dart';
import 'widgets/otp_timer.dart';
import 'widgets/resend_otp_button.dart';
import 'widgets/verify_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    this.resendToken,
  });

  final String verificationId;
  final String phoneNumber;
  final int? resendToken;

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends State<OtpVerificationScreen> {
  final GlobalKey timerKey = GlobalKey();

  bool otpComplete = false;
  bool otpExpired = false;
  bool verifying = false;
  bool resendLoading = false;

  String enteredOtp = '';
  String? errorMessage;

  late String currentVerificationId;
  int? currentResendToken;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    currentVerificationId =
        widget.verificationId;

    currentResendToken =
        widget.resendToken;
  }

  // ==========================================================
  // SAVE USER TO FIRESTORE
  // ==========================================================

  Future<void> _saveUserToFirestore(
    User user,
  ) async {
    final DocumentReference<Map<String, dynamic>>
        userRef = _firestore
            .collection('users')
            .doc(user.uid);

    final DocumentSnapshot<
        Map<String, dynamic>> snapshot =
        await userRef.get();

    final Map<String, dynamic> userData = {
      'uid': user.uid,
      'phone':
          user.phoneNumber ?? widget.phoneNumber,
      'role': 'customer',
      'isActive': true,
      'profileCompleted': snapshot.exists
          ? (snapshot.data()?['profileCompleted'] ?? false)
          : false,
      'updatedAt':
          FieldValue.serverTimestamp(),
    };

    // ========================================================
    // FIRST TIME USER
    // ========================================================

    if (!snapshot.exists) {
      userData['createdAt'] =
          FieldValue.serverTimestamp();
    }

    // ========================================================
    // CREATE / UPDATE USER
    // ========================================================

    await userRef.set(
      userData,
      SetOptions(merge: true),
    );
  }

  // ==========================================================
  // GO TO HOME
  // ==========================================================

  Future<void> _goToNext() async {
    if (!mounted) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();
    final data = snapshot.data() ?? <String, dynamic>{};
    final complete = data['profileCompleted'] == true &&
        data['age'] != null &&
        (data['gender'] ?? '').toString().trim().isNotEmpty;

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => complete
            ? const NavigationScreen()
            : ProfileCompletionScreen(user: user),
      ),
      (route) => false,
    );
  }

  // ==========================================================
  // VERIFY OTP
  // ==========================================================

  Future<void> verifyOtp() async {
    if (enteredOtp.length != 6) {
      setState(() {
        errorMessage =
            'Please enter the 6-digit OTP';
      });

      return;
    }

    if (otpExpired) {
      setState(() {
        errorMessage =
            'OTP expired. Please request a new OTP.';
      });

      return;
    }

    setState(() {
      verifying = true;
      errorMessage = null;
    });

    try {
      // ======================================================
      // CREATE PHONE CREDENTIAL
      // ======================================================

      final PhoneAuthCredential credential =
          PhoneAuthProvider.credential(
        verificationId:
            currentVerificationId,
        smsCode: enteredOtp,
      );

      // ======================================================
      // FIREBASE SIGN IN
      // ======================================================

      final UserCredential userCredential =
          await _auth.signInWithCredential(
        credential,
      );

      final User? user =
          userCredential.user;

      if (user == null) {
        throw Exception(
          'Firebase user could not be created.',
        );
      }

      // ======================================================
      // SAVE USER
      // ======================================================

      await _saveUserToFirestore(user);

      if (!mounted) return;

      setState(() {
        verifying = false;
      });

      // ======================================================
      // LOGIN SUCCESS
      // ======================================================

      await _goToNext();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        verifying = false;
      });

      String message;

      switch (e.code) {
        case 'invalid-verification-code':
          message =
              'Invalid OTP. Please check the OTP and try again.';
          break;

        case 'session-expired':
          message =
              'OTP expired. Please request a new OTP.';
          break;

        case 'invalid-verification-id':
          message =
              'Verification session expired. Please request a new OTP.';
          break;

        case 'credential-already-in-use':
          message =
              'This phone number is already connected to another account.';
          break;

        case 'too-many-requests':
          message =
              'Too many requests. Please try again later.';
          break;

        case 'quota-exceeded':
          message =
              'SMS quota exceeded. Please try again later.';
          break;

        case 'network-request-failed':
          message =
              'Network error. Please check your internet connection.';
          break;

        default:
          message =
              e.message ?? 'OTP verification failed.';
      }

      setState(() {
        errorMessage = message;
      });

      debugPrint(
        'Firebase OTP Error Code: ${e.code}',
      );

      debugPrint(
        'Firebase OTP Error Message: ${e.message}',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        verifying = false;
        errorMessage =
            'Unable to complete your account setup. Please try again.';
      });

      debugPrint(
        'OTP / Firestore Error: $e',
      );
    }
  }

  // ==========================================================
  // RESEND OTP
  // ==========================================================

  Future<void> resendOtp() async {
    if (resendLoading) return;

    setState(() {
      resendLoading = true;
      errorMessage = null;
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,

        // ====================================================
        // AUTOMATIC VERIFICATION
        // ====================================================

        verificationCompleted:
            (PhoneAuthCredential credential) async {
          try {
            final UserCredential
                userCredential =
                await _auth.signInWithCredential(
              credential,
            );

            final User? user =
                userCredential.user;

            if (user != null) {
              await _saveUserToFirestore(user);
            }

            if (!mounted) return;

            setState(() {
              resendLoading = false;
            });

            await _goToNext();
          } catch (e) {
            if (!mounted) return;

            setState(() {
              resendLoading = false;
              errorMessage =
                  'Automatic verification failed. Please enter the OTP manually.';
            });

            debugPrint(
              'Automatic verification error: $e',
            );
          }
        },

        // ====================================================
        // VERIFICATION FAILED
        // ====================================================

        verificationFailed:
            (FirebaseAuthException e) {
          if (!mounted) return;

          setState(() {
            resendLoading = false;
          });

          String message;

          switch (e.code) {
            case 'invalid-phone-number':
              message =
                  'Invalid phone number.';
              break;

            case 'too-many-requests':
              message =
                  'Too many requests. Please try again later.';
              break;

            case 'quota-exceeded':
              message =
                  'SMS quota exceeded. Please try again later.';
              break;

            case 'app-not-authorized':
              message =
                  'This Android app is not authorized for Firebase Phone Auth.';
              break;

            default:
              message =
                  e.message ??
                      'Unable to resend OTP.';
          }

          setState(() {
            errorMessage = message;
          });

          debugPrint(
            'Resend OTP Error Code: ${e.code}',
          );

          debugPrint(
            'Resend OTP Error Message: ${e.message}',
          );
        },

        // ====================================================
        // CODE SENT
        // ====================================================

        codeSent: (
          String verificationId,
          int? resendToken,
        ) {
          if (!mounted) return;

          currentVerificationId =
              verificationId;

          currentResendToken =
              resendToken;

          try {
            (timerKey.currentState as dynamic)
                .restart();
          } catch (_) {
            debugPrint(
              'OTP timer restart unavailable.',
            );
          }

          setState(() {
            resendLoading = false;
            otpExpired = false;
            otpComplete = false;
            enteredOtp = '';
            errorMessage = null;
          });

          ScaffoldMessenger.of(context)
              .hideCurrentSnackBar();

          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                'New OTP sent successfully.',
              ),
            ),
          );
        },

        // ====================================================
        // AUTO RETRIEVAL TIMEOUT
        // ====================================================

        codeAutoRetrievalTimeout:
            (String verificationId) {
          currentVerificationId =
              verificationId;

          debugPrint(
            'OTP auto retrieval timeout.',
          );
        },

        timeout:
            const Duration(seconds: 60),

        forceResendingToken:
            currentResendToken,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        resendLoading = false;
        errorMessage =
            'Unable to resend OTP. Please try again.';
      });

      debugPrint(
        'Resend OTP Exception: $e',
      );
    }
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF5F7FA),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor:
            const Color(0xFF173B6D),
        foregroundColor: Colors.white,
        title: const Text(
          'OTP Verification',
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(24),
            child: Container(
              padding:
                  const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(
                      alpha: .06,
                    ),
                    blurRadius: 25,
                    offset:
                        const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  OtpHeader(
                    phoneNumber:
                        widget.phoneNumber,
                  ),

                  const SizedBox(height: 35),

                  OtpInputField(
                    onCompleted: (otp) {
                      setState(() {
                        enteredOtp = otp;
                        otpComplete =
                            otp.length == 6;
                        errorMessage = null;
                      });
                    },
                  ),

                  if (errorMessage != null) ...[
                    const SizedBox(height: 18),

                    Text(
                      errorMessage!,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color: Colors.red,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  OtpTimer(
                    key: timerKey,
                    onExpired: () {
                      if (!mounted) return;

                      setState(() {
                        otpExpired = true;
                      });
                    },
                  ),

                  const SizedBox(height: 18),

                  ResendOtpButton(
                    enabled: otpExpired,
                    loading: resendLoading,
                    onPressed: resendOtp,
                  ),

                  const SizedBox(height: 28),

                  VerifyButton(
                    enabled:
                        otpComplete &&
                        !otpExpired &&
                        !verifying,
                    loading: verifying,
                    onPressed: verifyOtp,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}