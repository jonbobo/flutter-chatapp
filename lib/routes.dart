import 'package:flutter/material.dart';
import 'package:myapp/pages/home_page.dart';
import 'package:myapp/pages/login_page.dart';
import 'package:myapp/pages/profile_page.dart';
import 'package:myapp/pages/signup_page.dart';


class Routes {
  static const String home = '/home';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String signup = '/signup';

  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const HomePage(),
    login: (context) => const LoginPage(),
    profile: (context) => const ProfilePage(),
    signup: (context) => const SignUpPage(),
  };
}
