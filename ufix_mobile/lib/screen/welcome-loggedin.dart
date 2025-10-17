// lib/screens/welcome_loggedin.dart
import 'package:flutter/material.dart';
import 'homepage.dart';

class WelcomeLoggedin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(color: const Color(0xFFF7F7F7)),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            // Top section: make flexible so it doesn't force overflow
            Expanded(
              flex: 3,
              child: Container(
                width: 348,
                // remove fixed height to allow expansion/shrinking
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 348,
                      child: Text(
                        'Selamat datang di',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontFamily: 'Kodchasan',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Make image flexible so it scales with available space
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        // Use local asset logo.png (place file at assets/logo.png)
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 316,
                      child: Text(
                        'Solusi untuk kebutuhan elektronikmu',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Kodchasan',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Use flexible spacing instead of a large fixed SizedBox to avoid overflow
            Spacer(),
            Container(
              width: double.infinity,
              height: 195,
              padding: const EdgeInsets.symmetric(horizontal: 72, vertical: 71),
              decoration: ShapeDecoration(
                color: const Color(0xD8183A64),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(150),
                    topRight: Radius.circular(150),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Homepage()),
                      );
                    },
                    child: Container(
                      width: 264,
                      height: 39,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: ShapeDecoration(
                        color: const Color(0xFF4B92DB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Masuk',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFFF7F7F7),
                            fontSize: 20,
                            fontFamily: 'Kodchasan',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
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
    );
  }
}