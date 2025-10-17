// lib/screens/welcome_unlogged.dart
import 'package:flutter/material.dart';
import 'login.dart';

class WelcomeUnlogged extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(  // ADD SCAFFOLD
      body: Container(
        width: MediaQuery.of(context).size.width,  // MAKE RESPONSIVE
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(color: const Color(0xFFF7F7F7)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [  // REMOVE 'spacing: 189' - NOT VALID
            Container(
              width: 346,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 346,
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
                  const SizedBox(height: 16),  // ADD SPACING
                  Container(
                    width: double.infinity,
                    height: 181,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage("https://placehold.co/346x181"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),  // ADD SPACING
                  SizedBox(
                    width: 346,
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
            const SizedBox(height: 189),  // ADD SPACING AS SEPARATE WIDGET
            Container(
              width: 412,
              height: 195,
              padding: const EdgeInsets.symmetric(horizontal: 74, vertical: 51),
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
                children: [  // REMOVE 'spacing: 7'
                  Container(
                    width: 264,
                    height: 39,
                    padding: const EdgeInsets.symmetric(horizontal: 98, vertical: 5),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF4B92DB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [  // REMOVE 'spacing: 10'
                        SizedBox(
                          width: 68,
                          height: 29,
                          child: Text(
                            'Sign In',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFFF7F7F7),
                              fontSize: 20,
                              fontFamily: 'Kodchasan',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 7),  // ADD SPACING
                  // Login button navigates to the login screen
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ScreenLogin()),
                      );
                    },
                    child: Container(
                      width: 264,
                      height: 39,
                      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 6),
                      decoration: ShapeDecoration(
                        color: const Color(0xFF4B92DB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 64,
                            height: 27,
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: const Color(0xFFF7F7F7),
                                fontSize: 20,
                                fontFamily: 'Kodchasan',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}