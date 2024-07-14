import 'package:flutter/material.dart';
import 'package:myapp/themes/theme.dart';
import 'package:myapp/components/input_field.dart';
import 'package:myapp/components/button.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/pages/home_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService _authService = AuthService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController =
      TextEditingController(text: '');
  final TextEditingController emailController = TextEditingController(text: '');
  final TextEditingController passwordController =
      TextEditingController(text: '');
  final TextEditingController verifyPasswordController =
      TextEditingController(text: '');

  bool passwordVisible = false;

  void togglePassword() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  Future<void> onSignUpPressed() async {
    if (_formKey.currentState?.validate() ?? false) {
      // The form is valid, proceed with signup logic
      if (passwordController.text == verifyPasswordController.text) {
        User? user = await _authService.signUpWithEmailAndPassword(
          emailController.text,
          passwordController.text,
          usernameController.text,
        );
        if (user != null) {
          navigateToHomePage();
        } else {
          handleSignUpError();
        }
      } else {
        // Passwords do not match, show an error message or handle accordingly
        if (kDebugMode) {
          print('Passwords do not match');
        }
      }
    }
  }

  void navigateToHomePage() {
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void handleSignUpError() {
    // You can show a snackbar or update the UI to inform the user about the error
    if (kDebugMode) {
      print('Error during sign up');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 40.0, 24.0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Create an account',
                      style: textmd.copyWith(color: textBlack),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
              const SizedBox(
                height: 48,
              ),
              Center(
                child: SizedBox(
                  width: screenWidth * 0.4,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        InputField(
                          hintText: 'Username',
                          suffixIcon: const SizedBox(),
                          controller: usernameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 32,
                        ),
                        InputField(
                          hintText: 'Email',
                          suffixIcon: const SizedBox(),
                          controller: emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            } else if (!RegExp(
                                    r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                                .hasMatch(value)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 32,
                        ),
                        InputField(
                          hintText: 'Password',
                          controller: passwordController,
                          obscureText: !passwordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            color: textGrey,
                            splashRadius: 1,
                            icon: Icon(passwordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: togglePassword,
                          ),
                        ),
                        const SizedBox(
                          height: 32,
                        ),
                        InputField(
                          hintText: 'Verify Password',
                          controller: verifyPasswordController,
                          obscureText: !passwordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please verify your password';
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            color: textGrey,
                            splashRadius: 1,
                            icon: Icon(passwordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: togglePassword,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              Center(
                child: SizedBox(
                  width: screenWidth * 0.3,
                  child: Button(
                    buttonColor: primaryBlue,
                    textValue: 'Sign Up',
                    textColor: Colors.white,
                    onPressed: onSignUpPressed,
                  ),
                ),
              ),
              const SizedBox(
                height: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
