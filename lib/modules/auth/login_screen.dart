import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import 'auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.put(AuthController());
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Logo + App Name
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ECC71),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'EatSafe',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Login to continue',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF7F8C8D),
                  ),
                ),

                const SizedBox(height: 32),

                // Email Field
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter your email';
                    if (!val.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password Field
                Obx(() => TextFormField(
                      controller: passwordController,
                      obscureText: controller.obscurePassword.value,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscurePassword.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => controller.obscurePassword.toggle(),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Enter your password';
                        }
                        if (val.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    )),

                const SizedBox(height: 32),

                // Login Button
                Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              if (formKey.currentState!.validate()) {
                                controller.login(
                                  email: emailController.text,
                                  password: passwordController.text,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    )),

                const SizedBox(height: 24),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Color(0xFF7F8C8D)),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.register),
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Color(0xFF2ECC71),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}