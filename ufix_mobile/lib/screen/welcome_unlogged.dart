// lib/screens/welcome_unlogged.dart
import 'package:flutter/material.dart';

class WelcomeUnlogged extends StatelessWidget {
  const WelcomeUnlogged({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width, // responsive width and height
            height: MediaQuery.of(context).size.height,
            color: const Color(0xFFF7F7F7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Bagian atas: teks & gambar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: SizedBox(
                    width: 346,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat datang di',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontFamily: 'Kodchasan',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          height: 181,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('Asset/logo.png'), // Fixed path
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Solusi untuk kebutuhan elektronikmu',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Kodchasan',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Spacer to push buttons to bottom
                const Expanded(
                  child: SizedBox(),
                ),

                // Bagian bawah: tombol Sign In & Login
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 74, vertical: 51),
                  decoration: const ShapeDecoration(
                    color: Color(0xD8183A64),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(150),
                        topRight: Radius.circular(150),
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tombol Sign In
                      Container(
                        width: 264,
                        height: 39,
                        decoration: ShapeDecoration(
                          color: const Color(0xFF4B92DB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: const Text(
                            'Buat Akun',
                            style: TextStyle(
                              color: Color(0xFFF7F7FA),
                              fontSize: 20,
                              fontFamily: 'Kodchasan',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 7),

                      // Tombol Login
                      Container(
                        width: 264,
                        height: 39,
                        decoration: ShapeDecoration(
                          color: const Color(0xFF4B92DB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Color(0xFFF7F7FA),
                              fontSize: 20,
                              fontFamily: 'Kodchasan',
                              fontWeight: FontWeight.w500,
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
      ),
    );
  }
}