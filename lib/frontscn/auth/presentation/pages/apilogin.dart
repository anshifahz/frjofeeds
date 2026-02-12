import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../home/presentation/pages/home_screen.dart';

class ApiLoginPage extends StatefulWidget {
  const ApiLoginPage({super.key});

  @override
  State<ApiLoginPage> createState() => _ApiLoginPageState();
}

class _ApiLoginPageState extends State<ApiLoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  String _countryCode = "+91";

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Deep dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Enter Your\nMobile Number",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Lorem ipsum dolor sit amet, consectetur. Porta at in hac vitae. Ut tortor at vehicula euismod mi viverra.",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  // Country Code Field
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[800]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _countryCode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Phone Number Field
                  Expanded(
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[800]!),
                      ),
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter Mobile Number",
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Continue Button
              Center(
                child: Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    return InkWell(
                      onTap: auth.isLoading
                          ? null
                          : () async {
                              if (_phoneController.text.isNotEmpty) {
                                final success = await auth.verifyOtp(
                                  _countryCode,
                                  _phoneController.text,
                                );
                                if (mounted) {
                                  if (success) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const HomeScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "OTP Verification Failed",
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: Colors.grey[800]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 24),
                            Text(
                              auth.isLoading ? "Please wait..." : "Continue",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Container(
                              height: 48,
                              width: 48,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD32F2F), // Premium Red
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
