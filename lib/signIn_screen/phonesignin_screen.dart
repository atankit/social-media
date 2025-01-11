import 'package:dummy_socialmedia/signIn_screen/otp_screen.dart';
import 'package:dummy_socialmedia/signIn_services/auth.dart';
import 'package:flutter/material.dart';

class PhoneSignInScreen extends StatefulWidget {
  const PhoneSignInScreen({super.key});

  @override
  State<PhoneSignInScreen> createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends State<PhoneSignInScreen> {
  final AuthService authService = AuthService();

  String phoneNumber = '';
  String verificationId = '';

  String formatPhoneNumber(String number) {
    if (!number.startsWith('+')) {
      return '+91$number'; // Add default country code if missing
    }
    return number;
  }

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
              "Enter Your Mobile Number",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "We Will Send You A Confirmation Code",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),

            // Phone Number Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  const Text(
                    "(+91)",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.black54, width: 1.5)),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        phoneNumber,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
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
                        setState(() {
                          phoneNumber += "0";
                        });
                      },
                    );
                  } else if (index == 11) {
                    return _buildBackspaceButton(
                      onTap: () {
                        setState(() {
                          if (phoneNumber.isNotEmpty) {
                            phoneNumber = phoneNumber.substring(0, phoneNumber.length - 1);
                          }
                        });
                      },
                    );
                  }
                  return _buildNumberButton(
                    "${index + 1}",
                    onTap: () {
                      setState(() {
                        phoneNumber += "${index + 1}";
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Next Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (phoneNumber.length == 10) {
                  String formattedPhoneNumber = formatPhoneNumber(phoneNumber);
                  await authService.signInWithPhone(
                    formattedPhoneNumber,
                        (id) {
                      verificationId = id;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OTPScreen(verificationId: verificationId),
                        ),
                      );
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter a valid 10-digit phone number.")),
                  );
                }
              },
              child: const Text(
                "Next",
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
