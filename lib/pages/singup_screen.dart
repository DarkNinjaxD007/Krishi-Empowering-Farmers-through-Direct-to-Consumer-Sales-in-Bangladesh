import 'package:flutter/material.dart';
import 'package:flutter_e_commerce_app/Utils/constant.dart';
import 'package:flutter_e_commerce_app/pages/signin_screen.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../Utils/colors.dart';
import '../helpers/network_info.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  late NetworkInfo _networkInfo;
  String? _selectedRole; // Variable to hold the selected role
  final List<String> _roles = ['consumer', 'farmer'];
  String? _selectedAddress = "";
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _networkInfo = NetworkInfoImpl(InternetConnectionChecker());
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        // Remove fixed height
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
            padding: const EdgeInsets.only(top: 5.0),
            child: Column(
              children: [
                // Add logo here
                Semantics(
                  label: 'Created by Md Soliman Ali',
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 150,
                    width: 150,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  "রেজিস্ট্রেশন পেজ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: textColor1,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "কৃষিতে আপনাকে স্বাগতম",
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 18, color: textColor2, height: 1.0),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                // Role Dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: DropdownButtonFormField<String>(
                    value: _selectedRole,
                    hint: const Text('রোল সিলেক্ট করুন'),
                    items: _roles.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                // Address Autocomplete with Chip
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          } else {
                            return Constant.districtList.where((word) => word
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()));
                          }
                        },
                        onSelected: (selectedString) {
                          setState(() {
                            _selectedAddress = selectedString;
                          });
                        },
                        fieldViewBuilder: (context, controller, focusNode,
                            onEditingComplete) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            onEditingComplete: onEditingComplete,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              hintText: "ঠিকানা খুঁজুন",
                              prefixIcon: const Icon(Icons.search),
                            ),
                          );
                        },
                      ),
                      // const SizedBox(height: 2),
                      // Display selected address with Chip
                      Align(
                        alignment: Alignment.topLeft,
                        child: _selectedAddress!.isNotEmpty
                            ? Chip(
                                label: Text(_selectedAddress!),
                                onDeleted: () {
                                  setState(() {
                                    _selectedAddress =
                                        ""; // Clear the selected address
                                  });
                                },
                              )
                            : Container(),
                      ),
                    ],
                  ),
                ),

                // Text fields for other inputs
                myTextField("ইমেইল দিন", emailController, false),
                myTextField("পাসওয়ার্ড", passwordController, true),
                myTextField("পুরো নাম দিন", fullNameController, false),
                myTextField("ফোন নাম্বার দিন", phoneNumberController, false),
                const SizedBox(height: 15),
                // Submit Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: GestureDetector(
                    onTap: _submitForm,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Center(
                        child: Text(
                          "রেজিস্ট্রেশন",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignInScreen()));
                  },
                  child: Text.rich(
                    TextSpan(
                        text: "আগের একাউন্ট আছে? ",
                        style: TextStyle(
                          color: textColor2,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        children: const [
                          TextSpan(
                            text: "লগইন করুন",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ]),
                  ),
                ),
                // const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  // Helper function to generate text fields
  Widget myTextField(
      String hint, TextEditingController controller, bool isPassword) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          hintText: hint,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off_outlined,
                    color: Colors.black26,
                  ),
                  onPressed: _togglePasswordVisibility,
                )
              : null,
        ),
      ),
    );
  }

  // Form submission handler
  Future<void> _submitForm() async {
    if (_selectedRole == null || _selectedRole!.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('রোল সিলেক্ট করুন!')));
      return;
    }

    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('ইমেইল প্রয়োজন!')));
      return;
    }

    if (passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('পাসওয়ার্ড প্রয়োজন!')));
      return;
    }

    if (fullNameController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('নাম প্রয়োজন!')));
      return;
    }
  }
}
