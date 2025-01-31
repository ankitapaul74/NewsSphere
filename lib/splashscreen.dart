import 'package:flutter/material.dart';
import 'dart:async';
import 'homepage.dart'; // Your home page or NewsAppHome
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller with a duration of 4 seconds
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Define the scale animation (logo grows and fades in)
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Define the rotation animation (logo spins)
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Define the opacity animation for text (gradual fade-in)
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start the animation
    _controller.forward();

    // Navigate to the home screen after splash screen duration
    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NewsAppHome()), // Replace with your home screen
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900], // Background color of splash screen
      body: GestureDetector(
        onTap: () {
          // Navigate to home if the user taps on the splash screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NewsAppHome()),
          );
        },
        onHorizontalDragUpdate: (details) {
          // Swipe gesture to skip the splash screen
          if (details.primaryDelta! < -10) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NewsAppHome()),
            );
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated logo with rotation and scale transition
              RotationTransition(
                turns: _rotationAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Image.asset(
                    'assets/images/global-news.png', // Your logo asset
                    height: 150,
                    width: 150,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // AnimatedOpacity for both app name and tagline
              AnimatedBuilder(
                animation: _textOpacityAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textOpacityAnimation.value,
                    child: child,
                  );
                },
                child: Column(
                  children: [
                    // App name with animated opacity and drop shadow
                    Text(
                      'NewsSphere', // App name
                      style: GoogleFonts.openSans( // Using Google Fonts
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 48, // Larger size for better visibility
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.6), // Shadow color
                              offset: Offset(3, 3), // Shadow position
                              blurRadius: 6, // Shadow blur radius
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Tagline with animated opacity, custom font, and drop shadow
                    Text(
                      'Your World, Your News', // Tagline
                      style: GoogleFonts.openSans( // Using Google Fonts
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 22, // Slightly larger font size
                          fontWeight: FontWeight.w400,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.6), // Shadow color
                              offset: Offset(3, 3), // Shadow position
                              blurRadius: 6, // Shadow blur radius
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
      ),
    );
  }
}
