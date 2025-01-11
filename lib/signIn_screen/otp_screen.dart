import 'package:dummy_socialmedia/bottomNavBar/social_media.dart';
import 'package:dummy_socialmedia/signIn_services/auth.dart';
import 'package:flutter/material.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;

  const OTPScreen({super.key, required this.verificationId});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();

  Widget _buildNumberButton(String number, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade400, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          number,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton({VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.pinkAccent,
          borderRadius: BorderRadius.circular(12.0),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.backspace_outlined, color: Colors.black, size: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Back Button
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, size: 28, color: Colors.pinkAccent),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              "Enter Code Sent To Your Number",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "We have sent a 6-digit code",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 15),

            // OTP Boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return Container(
                  width: 50,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _otpController.text.length > index ? _otpController.text[index] : '',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // Custom Keypad
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                ),
                itemCount: 12, // 9 numbers + 0 + backspace
                itemBuilder: (context, index) {
                  if (index == 9) {
                    return const SizedBox.shrink(); // Empty space
                  } else if (index == 10) {
                    return _buildNumberButton(
                      "0",
                      onTap: () {
                        if (_otpController.text.length < 6) {
                          setState(() {
                            _otpController.text += "0";
                          });
                        }
                      },
                    );
                  } else if (index == 11) {
                    return _buildBackspaceButton(
                      onTap: () {
                        if (_otpController.text.isNotEmpty) {
                          setState(() {
                            _otpController.text = _otpController.text
                                .substring(0, _otpController.text.length - 1);
                          });
                        }
                      },
                    );
                  }
                  return _buildNumberButton(
                    "${index + 1}",
                    onTap: () {
                      if (_otpController.text.length < 6) {
                        setState(() {
                          _otpController.text += "${index + 1}";
                        });
                      }
                    },
                  );
                },
              ),
            ),

            // Verify Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (_otpController.text.length == 6) {
                  try {
                    final user = await authService.verifyOtp(
                      widget.verificationId,
                      _otpController.text,
                    );

                    if (user != null) {
                      // OTP verified successfully
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("OTP Verified Successfully!")),
                        );
                        // Navigate to home screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SocialMediaApp()),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Invalid OTP. Please try again.")),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Invalid OTP. Please try again.")),
                      );
                    }
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Enter a 6-digit OTP.")),
                    );
                  }
                }
              },
              child: const Text(
                "Verify",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

