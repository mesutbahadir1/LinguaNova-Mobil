import 'dart:convert';

import 'package:fire_base/app/constants/app_config.dart';
import 'package:fire_base/auth/forgot_password/forgot.dart';
import 'package:fire_base/auth/sign_up.dart';
import 'package:fire_base/ui/home.dart';
import 'package:fire_base/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/user_provider.dart';
import '../services/authService.dart';
import '../widgets/button.dart';
import '../widgets/snackBar.dart';
import 'google_login/google_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;


  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void login() async {
    setState(() {
      isLoading = true;
    });

    String res = await AuthServices().loginUser(
      email: emailController.text,
      password: passwordController.text,
    );

    if (res == "success") {
      try {
        final response = await http.get(
          Uri.parse('${HTTPS_URL}/api/User/getidbymail?email=${emailController.text}'),
        );

        if (response.statusCode == 200) {
          int userId = int.parse(response.body);
          //print(userId);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', userId);
          print(prefs.getInt('userId'));
          await Future.delayed(Duration(milliseconds: 100));
          setState(() {
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          showSnackBar(context, "User ID not found in backend");
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, "An error occurred: $e");
      }
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, res);
    }
  }


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      resizeToAvoidBottomInset: true, // Klavye açıldığında ekranın yeniden düzenlenmesini sağlar
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView( // Ekranın kaydırılabilir olmasını sağlar
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: height / 2.7,
                  child: Image.asset('assets/images/login.jpg'),
                ),
                TextFieldInput(
                  textEditingController: emailController,
                  hintText: "Enter your email",
                  icon: Icons.email,
                ),
                TextFieldInput(
                  textEditingController: passwordController,
                  isPass: true,
                  hintText: "Enter your password",
                  icon: Icons.lock,
                ),
                MyButtons(
                  onTap: login,
                  text: "Log In",
                ),
                const ForgotPassword(),
                SizedBox(
                  height: height / 50,
                ),
                SizedBox(
                  height: height / 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUp()));
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
