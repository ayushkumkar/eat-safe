import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import 'auth_controller.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.put(AuthController());
    final nameController = TextEditingController();
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
                const SizedBox(height: 32),

                // Back Button
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Color(0xFF2C3E50),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Join EatSafe and eat smarter',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF7F8C8D),
                  ),
                ),

                const SizedBox(height: 32),

                // Name Field
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter your name';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

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
                          return 'Enter a password';
                        }
                        if (val.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    )),

                const SizedBox(height: 28),

                // Health Conditions
                const Text(
                  'Any health conditions? (optional)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'We use this to personalize your nutrition advice',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
                const SizedBox(height: 14),

                // Health Condition Chips
                Obx(() => Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: controller.healthConditions.map((condition) {
                        final label = condition['label'] as String;
                        final icon = condition['icon'] as IconData;
                        final isSelected =
                            controller.selectedConditions.contains(label);
                        return GestureDetector(
                          onTap: () => controller.toggleCondition(label),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2ECC71)
                                  : const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2ECC71)
                                    : const Color(0xFFE0E0E0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  icon,
                                  size: 16,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF7F8C8D),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF2C3E50),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    )),

                const SizedBox(height: 32),

                // Register Button
                Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              if (formKey.currentState!.validate()) {
                                controller.register(
                                  name: nameController.text,
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
                              'Create Account',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    )),

                const SizedBox(height: 20),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Color(0xFF7F8C8D)),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.login),
                      child: const Text(
                        'Login',
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