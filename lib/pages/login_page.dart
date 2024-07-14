import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/pages/home_page.dart';
import 'package:myapp/pages/signup_page.dart';
import 'package:myapp/themes/theme.dart';
import 'package:myapp/components/input_field.dart';
import 'package:myapp/components/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController(text: '');
  final TextEditingController passwordController =
      TextEditingController(text: '');

  bool passwordVisible = false;

  void togglePassword() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  Future<void> onLoginPressed() async {
    if (_formKey.currentState!.validate()) {
      User? user = await _authService.signInWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );
      if (user != null) {
        navigateToHomePage();
      } else {
        handleLoginError();
      }
    }
  }

  Future<void> onLoginAsGuestPressed() async {
    User? user = await _authService.signInAnonymously();

    if (user != null) {
      navigateToHomePage();
    } else {
      handleLoginError();
    }
  }

  void navigateToHomePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void handleLoginError() {
    if (kDebugMode) {
      print('Error during login');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
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
                      'Login to your account',
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
                          suffixIcon: IconButton(
                            color: textGrey,
                            splashRadius: 1,
                            icon: Icon(passwordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: togglePassword,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
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
                    textValue: 'Login',
                    textColor: Colors.white,
                    onPressed: onLoginPressed,
                  ),
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              const SizedBox(
                height: 24,
              ),
              Center(
                child: Text(
                  'OR',
                  style: textbase.copyWith(color: textGrey),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Center(
                child: SizedBox(
                  width: screenWidth * 0.3,
                  child: Button(
                    buttonColor: const Color.fromARGB(255, 244, 222, 222),
                    textValue: 'Login as Guest',
                    textColor: textBlack,
                    onPressed: onLoginAsGuestPressed,
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: textlight.copyWith(color: textGrey),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpPage()),
                        );
                      },
                      child: Text(
                        'Register',
                        style: textlight.copyWith(color: primaryBlue),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
