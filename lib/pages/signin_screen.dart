import 'package:flutter/material.dart';
import 'package:flutter_e_commerce_app/pages/singup_screen.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../Utils/colors.dart';
import '../helpers/network_info.dart';
import '../main.dart';
import '../service/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late NetworkInfo _networkInfo;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    _networkInfo = NetworkInfoImpl(InternetConnectionChecker());
    super.initState();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              backgroundColor2,
              backgroundColor2,
              backgroundColor4,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 48.0),
            child: ListView(
              children: [
                // Logo
                Semantics(
                  label: 'Created by Md Soliman Ali',
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 200, // Adjust as needed
                    width: 200, // Adjust as needed
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.002),
                Text(
                  "স্বাগতম!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: textColor1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "কৃষিতে আপনাকে স্বাগতম",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: textColor2, height: 1.2),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                // Username and password fields
                myTextField("ইমেইল দিন", Colors.white, usernameController, false),
                myTextField("পাসওয়ার্ড", Colors.black26, passwordController, true),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "পাসওয়ার্ড রিকোভার করুন                ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor2,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      // Sign in button
                      GestureDetector(
                        onTap: () async{
                          if(!await _networkInfo.isConnected){
                            const snackbar = SnackBar(
                              content: Text("ইন্টারনেট কানেকশন চেক করুন!"),
                              duration: Duration(seconds: 5),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(snackbar);
                            return;
                          }

                          if(usernameController.text.isEmpty){
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('অনুগ্রহ করে ইমেইল দিন!')));
                            return;
                          }

                          if(passwordController.text.isEmpty){
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('অনুগ্রহ করে পাসওয়ার্ড দিন!')));
                            return;
                          }

                          var isSignIn = await  AuthServices.signinUser(usernameController.text.toString(), passwordController.text.toString(), context);
                          if(isSignIn){
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(content: Text('আপনি সফলভাবে লগইন করেছেন')));

                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                            const HomePage()), (Route<dynamic> route) => false);
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: buttonColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Center(
                            child: Text(
                              "সাইন ইন",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                        },
                        child: Text.rich(
                          TextSpan(
                            text: "সদস্য নন? ",
                            style: TextStyle(
                              color: textColor2,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            children: const [
                              TextSpan(
                                text: "রেজিস্টার করুন",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container myTextField(String hint, Color color, TextEditingController controller, bool isPassword) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 8,
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(16),
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.black45,
            fontSize: 19,
          ),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off_outlined,
              color: color,
            ),
            onPressed: _togglePasswordVisibility,
          )
              : null,
        ),
      ),
    );
  }
}