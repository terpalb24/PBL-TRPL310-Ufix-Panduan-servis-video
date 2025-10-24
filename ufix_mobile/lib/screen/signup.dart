import 'package:flutter/material.dart';
import 'package:ufix_mobile/models/user_model.dart';
import 'package:ufix_mobile/services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty ||
        _displayNameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await ApiService.signUp(
      _emailController.text,
      _displayNameController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (result['success'] == true || result['statusCode'] == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pendaftaran Berhasil! Silakan Login.')),
      );
      Navigator.pushReplacementNamed(context, '/login'); // ke halaman login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Pendaftaran Gagal.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: const Color(0xFFF7F7FA)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0x19183A64),
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    minimumSize: Size(75, 75),
                    backgroundColor: Color(0xFFF7F7FA),
                    padding: const EdgeInsets.all(8),
                    foregroundColor: Color(0xFF4B92DB),
                    shadowColor: Color(0xD8183A64),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back_ios),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: EdgeInsetsGeometry.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Welcome text
                      SizedBox(
                        width: 330,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat Datang!',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 38,
                                fontFamily: 'Kodchasan',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Buat akun dan mulai memperbaiki',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontFamily: 'Kodchasan',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      // Email field
                      SizedBox(
                        width: 350,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Kodchasan',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 50,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFEAEAEA),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: const Color(0xFFD9D9D9),
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: TextField(
                                controller: _emailController, // Add this
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  hintText: 'Masukkan Email',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      // Display Name field
                      SizedBox(
                        width: 350,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nama Tampilan',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Kodchasan',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              width: double.infinity,
                              height: 50,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFEAEAEA),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: const Color(0xFFD9D9D9),
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: TextField(
                                controller: _displayNameController, // Add this
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  hintText: 'Masukan Nama Tampilan',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      // Password field
                      SizedBox(
                        width: 350,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kata Sandi',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Kodchasan',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: double.infinity,
                              height: 50,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFEAEAEA),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: const Color(0xFFD9D9D9),
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  hintText: 'Masukan Kata Sandi',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      // Repeat Password field
                      SizedBox(
                        width: 350,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ulangi Kata Sandi',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Kodchasan',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: double.infinity,
                              height: 50,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFEAEAEA),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: const Color(0xFFD9D9D9),
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: TextField(
                                controller:
                                    _confirmPasswordController, // Add this
                                obscureText: true,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  hintText: 'Masukkan Kata Sandi',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      // Signup button
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
                          onPressed: _isLoading ? null : _signUp, // Change this
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFF7F7FA),
                                    ),
                                  ),
                                )
                              : Text(
                                  'Buat Akun',
                                  style: TextStyle(
                                    color: const Color(0xFFF7F7FA),
                                    fontSize: 20,
                                    fontFamily: 'Kodchasan',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                      // Add some bottom space for keyboard
                      SizedBox(height: 40),
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
