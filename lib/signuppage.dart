import 'package:flutter/material.dart';
import 'loginpage.dart';
import 'services/api.dart'; // Import the login page

class SignUpScreen extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/pic03.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Sign-up Form
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 130, left: 30, right: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Create an Account",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Sign Up to get started",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),

                    _buildInputField(
                      "Username",
                      Icons.person,
                      false,
                      usernameController,
                      (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter a username";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    _buildInputField(
                      "Email",
                      Icons.email,
                      false,
                      emailController,
                      (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter an email";
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    _buildInputField(
                      "Password",
                      Icons.lock,
                      true,
                      passwordController,
                      (value) {
                        if (value == null || value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          var data1 = {
                            "username": usernameController.text,
                            "email": emailController.text,
                            "password": passwordController.text
                          };

                          Api.adduser(data1);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      child: const Text("Sign Up",
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                    const SizedBox(height: 50),

                    // Login Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?",
                            style: TextStyle(color: Colors.black54)),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          },
                          child: const Text("Log in",
                              style: TextStyle(color: Colors.blue)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String hint,
    IconData icon,
    bool obscure,
    TextEditingController controller,
    String? Function(String?)? validator,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 5, offset: const Offset(0, 3)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
