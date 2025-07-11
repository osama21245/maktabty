import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mktabte/features/auth/presentation/riverpod/signup_riverpod.dart';
import 'package:mktabte/features/auth/presentation/screens/login.dart';

import '../../../../core/theme/text_style.dart';
import '../../../../core/utils/show_snack_bar.dart';
import '../../../home/presentation/widgets/custom_txt_btn.dart';
import '../../../home/presentation/widgets/custom_txt_field.dart';
import '../../../home/presentation/widgets/custompass_txt_fiels.dart';
// Osama Abdelrahman pull request
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();
  final bool _showOtpField = false;

  String? _validateFields() {
    if (_nameController.text.isEmpty) {
      return 'Name is required';
    }
    if (_emailController.text.isEmpty) {
      return 'Email is required';
    }
    if (_passwordController.text.isEmpty) {
      return 'Password is required';
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _signUp() {
    final error = _validateFields();
    if (error != null) {
      showSnackBar(context, error);
      return;
    }
    ref.read(signupControllerProvider.notifier).signUpWithEmail(
          email: _emailController.text,
          name: _nameController.text,
          password: _passwordController.text,
        );
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Sign Up Successful'),
        content: const Text(
          'Your account has been created successfully. Please check your email to verify your account before logging in.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(signupControllerProvider, (previous, next) {
      if (next.error != null) {
        showSnackBar(context, next.error!);
      } else if (next.isSuccessCreateEmail()) {
        ref.read(signupControllerProvider.notifier).createUserProfile(
              user: next.user!,
            );
      } else if (next.isSuccessSaveEmailInSupabaseDatabase()) {
        _showVerificationDialog();
      }
    });

    final state = ref.watch(signupControllerProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),
              Center(
                child: Text(
                  "Signup",
                  style: TextStyles.Lato16extraBoldBlack,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  "assets/images/login_img.png",
                  height: 150,
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  "Name:",
                  style: TextStyles.Lato14extraBoldBlack,
                ),
              ),
              Center(
                child: CustomTextField(
                  hinttxt: 'Enter Your Full Name',
                  mycontroller: _nameController,
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  "Email:",
                  style: TextStyles.Lato14extraBoldBlack,
                ),
              ),
              Center(
                child: CustomTextField(
                  hinttxt: 'Enter your Email',
                  mycontroller: _emailController,
                ),
              ),
              const SizedBox(height: 30),
              if (!_showOtpField) ...[
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    "Password:",
                    style: TextStyles.Lato14extraBoldBlack,
                  ),
                ),
                Center(
                  child: CustompassTxtField(
                    hinttxt: "Enter your password",
                    mycontroller: _passwordController,
                    obscureText:
                        !ref.watch(signupControllerProvider).isPasswordVisible,
                    onToggleVisibility: () {
                      ref
                          .read(signupControllerProvider.notifier)
                          .togglePasswordVisibility();
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: CustompassTxtField(
                    hinttxt: "Confirm password",
                    mycontroller: _confirmPasswordController,
                    obscureText: !ref
                        .watch(signupControllerProvider)
                        .isConfirmPasswordVisible,
                    onToggleVisibility: () {
                      ref
                          .read(signupControllerProvider.notifier)
                          .toggleConfirmPasswordVisibility();
                    },
                  ),
                ),
              ] else
                CustomTextField(
                  hinttxt: "Enter OTP",
                  mycontroller: _otpController,
                ),
              const SizedBox(height: 40),
              Center(
                child: CustomTxtBtn(
                  txtstyle: TextStyles.Lato16extraBoldBlack,
                  bgclr: const Color(0xFFF68B3B),
                  btnWidth: 327,
                  btnHeight: 48,
                  btnradious: 10,
                  btnName: state.isLoading()
                      ? "Loading..."
                      : (_showOtpField ? 'Verify OTP' : 'Sign Up'),
                  onPress: () {
                    if (state.isLoading()) {
                      return;
                    }
                    _signUp();
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "already have an account?",
                    style: TextStyle(fontSize: 18, fontFamily: "Inter"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: Text(
                      " Log in",
                      style: TextStyles.Lato16extraBoldBlack,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
