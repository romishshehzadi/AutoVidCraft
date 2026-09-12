import 'package:auto/Screens/adminpannel/adminnavbottom.dart';
import 'package:auto/Screens/bottom%20navigation.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto/services/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GlassAuthScreen extends StatefulWidget {
  const GlassAuthScreen({super.key});

  @override
  State<GlassAuthScreen> createState() => _GlassAuthScreenState();
}

enum AuthView { login, register, forgot }

class _GlassAuthScreenState extends State<GlassAuthScreen> {
  AuthView currentView = AuthView.login;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  String nameError = "";
  String emailError = "";
  String passwordError = "";
  String confirmPasswordError = "";

  bool showPassword = false;
  bool showConfirmPassword = false;

  // Email validation regex
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  void togglePasswordVisibility() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  void toggleConfirmPasswordVisibility() {
    setState(() {
      showConfirmPassword = !showConfirmPassword;
    });
  }

  bool validateEmail(String email) {
    if (email.isEmpty) {
      emailError = "Email is required";
      return false;
    }
    if (!emailRegex.hasMatch(email)) {
      emailError = "Please enter a valid email address";
      return false;
    }
    emailError = "";
    return true;
  }

  // ✅ UPDATED: Password validation - minimum 8 characters
  bool validatePassword(String password) {
    if (password.isEmpty) {
      passwordError = "Password is required";
      return false;
    }

    // Password must be at least 8 characters
    if (password.length < 8) {
      passwordError = "Password must be at least 8 characters";
      return false;
    }

    passwordError = "";
    return true;
  }

  bool validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      confirmPasswordError = "Please confirm your password";
      return false;
    }

    if (password != confirmPassword) {
      confirmPasswordError = "Passwords do not match";
      return false;
    }

    confirmPasswordError = "";
    return true;
  }

  final AuthService _authService = AuthService();

  void onSubmit() async {
    setState(() {
      nameError = "";
      emailError = "";
      passwordError = "";
      confirmPasswordError = "";
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // ---------------- EMAIL VALIDATION ----------------
    if (!validateEmail(email)) return;

    try {
      // ---------------- FORGOT PASSWORD ----------------
      if (currentView == AuthView.forgot) {
        debugPrint("FORGOT PASSWORD FLOW");
        await _authService.resetPassword(email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reset link sent to email")),
        );
        setState(() => currentView = AuthView.login);
        return;
      }

      // ---------------- PASSWORD VALIDATION (LOGIN & REGISTER) ----------------
      if (!validatePassword(password)) return;

      if (currentView != AuthView.forgot) {
        if (!validateConfirmPassword(password, confirmPassword)) return;
      }

      // ---------------- REGISTER ----------------
      if (currentView == AuthView.register) {
        if (nameController.text.isEmpty) {
          setState(() => nameError = "Enter full name");
          return;
        }

        await _authService.register(
          email: email,
          password: password,
          name: nameController.text.trim(),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavScreen()),
        );
      }

      // ---------------- LOGIN ----------------
      if (currentView == AuthView.login) {
        try {
          DocumentSnapshot? userDoc =
          await _authService.login(email: email, password: password);

          String role = userDoc!["role"];

          if (role == "admin") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const BottomNavAdmin()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const BottomNavScreen()),
            );
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'wrong-password') {
            setState(() => passwordError = "Password is incorrect");
          } else if (e.code == 'user-not-found') {
            setState(() => emailError = "No account found with this email");
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.message ?? "Auth error")),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Auth error")),
      );
    }
  }

  void _signInWithGoogle() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      User? user = await _authService.signInWithGoogle();

      Navigator.pop(context);

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        String role = userDoc['role'] ?? 'user';

        if (role == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BottomNavAdmin()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BottomNavScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      String errorMessage;
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = 'Account already exists with a different sign-in method';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Invalid credential';
      } else if (e.code == 'operation-not-allowed') {
        errorMessage = 'Google sign-in is not enabled';
      } else {
        errorMessage = e.message ?? 'Google sign-in failed';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _signInWithGitHub() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      User? user = await _authService.signInWithGitHub();

      Navigator.pop(context);

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        String role = userDoc['role'] ?? 'user';

        if (role == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BottomNavAdmin()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BottomNavScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      String errorMessage;
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = 'Account already exists with a different sign-in method';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Invalid credential';
      } else if (e.code == 'operation-not-allowed') {
        errorMessage = 'GitHub sign-in is not enabled';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This account has been disabled';
      } else {
        errorMessage = e.message ?? 'GitHub sign-in failed';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double cardHeight = MediaQuery.of(context).size.height * 0.85;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: GlassmorphicContainer(
            width: MediaQuery.of(context).size.width * 0.9,
            height: cardHeight,
            borderRadius: 20,
            blur: 25,
            alignment: Alignment.center,
            border: 1,
            linearGradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.04),
              ],
            ),
            borderGradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7C5CFF), Color(0xFF6D5DFB)],
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox.expand(
                              child: Image.asset(
                                'images/logo1.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "AutoVidCraft",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'font5'
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentView == AuthView.login
                              ? "Welcome back! Sign in to continue"
                              : currentView == AuthView.register
                              ? "Create your account to get started"
                              : "Reset your password",
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontFamily: 'font4'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    if (currentView == AuthView.forgot)
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => setState(() => currentView = AuthView.login),
                              icon: const Icon(
                                LucideIcons.arrowLeft,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Back",
                                style: TextStyle(color: Colors.white, fontFamily: 'font6'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    if (currentView == AuthView.register)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputField(
                            label: 'Full Name',
                            icon: LucideIcons.user,
                            controller: nameController,
                          ),
                          if (nameError.isNotEmpty) _errorText(nameError),
                        ],
                      ),

                    _buildInputField(
                      label: 'Email',
                      icon: LucideIcons.mail,
                      controller: emailController,
                    ),
                    if (emailError.isNotEmpty) _errorText(emailError),

                    if (currentView != AuthView.forgot)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPasswordField(
                            label: 'Password',
                            controller: passwordController,
                            showPassword: showPassword,
                            onToggleVisibility: togglePasswordVisibility,
                          ),
                          if (passwordError.isNotEmpty) _errorText(passwordError),
                          // ✅ UPDATED: Password hint text
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 4),
                            child: Text(
                              "Password must be at least 8 characters",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),

                    if (currentView != AuthView.forgot)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPasswordField(
                            label: 'Confirm Password',
                            controller: confirmPasswordController,
                            showPassword: showConfirmPassword,
                            onToggleVisibility: toggleConfirmPasswordVisibility,
                          ),
                          if (confirmPasswordError.isNotEmpty) _errorText(confirmPasswordError),
                        ],
                      ),

                    const SizedBox(height: 16),

                    if (currentView == AuthView.login)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => setState(() => currentView = AuthView.forgot),
                          child: Text(
                            "Forgot password?",
                            style: TextStyle(color: Color(0xFF7C5CFF), fontFamily: 'font6'),
                          ),
                        ),
                      ),

                    SizedBox(height: 8),

                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          currentView == AuthView.login
                              ? 'Sign In'
                              : currentView == AuthView.register
                              ? 'Create Account'
                              : 'Send Reset Link',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'font6'
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 8),

                    if (currentView == AuthView.login)
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.white38)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  "Or continue with",
                                  style: TextStyle(color: Colors.white70, fontFamily: 'font4'),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.white38)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _signInWithGitHub,
                                  icon: const Icon(
                                    LucideIcons.github,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "GitHub",
                                    style: TextStyle(color: Colors.white, fontFamily: 'font6'),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.white30),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _signInWithGoogle,
                                  icon: const Icon(
                                    LucideIcons.chrome,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Google",
                                    style: TextStyle(color: Colors.white, fontFamily: 'font6'),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.white30),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                    if (currentView == AuthView.register)
                      SizedBox(height: 8),

                    Padding(
                      padding: EdgeInsets.only(top: currentView == AuthView.register ? 4 : 16),
                      child: Center(
                        child: TextButton(
                          onPressed: () => setState(() {
                            currentView = currentView == AuthView.login
                                ? AuthView.register
                                : AuthView.login;
                            passwordController.clear();
                            confirmPasswordController.clear();
                            if (currentView == AuthView.register) {
                              nameController.clear();
                            }
                          }),
                          child: Text(
                            currentView == AuthView.login
                                ? "Don't have an account? Sign up"
                                : "Already have an account? Sign in",
                            style: const TextStyle(
                              color: Color(0xFF7C5CFF),
                              fontFamily: 'font4',
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ✅ UPDATED: Removed maxLength property
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool showPassword,
    required VoidCallback onToggleVisibility,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: !showPassword,
        style: const TextStyle(color: Colors.white),
        // maxLength property hatadi hai
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(LucideIcons.lock, color: Colors.white70),
          suffixIcon: IconButton(
            icon: Icon(
              showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
              color: Colors.white70,
            ),
            onPressed: onToggleVisibility,
          ),
          counterText: "",
          filled: true,
          fillColor: Colors.white.withOpacity(0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _errorText(String error) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Text(
        error,
        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
      ),
    );
  }
}