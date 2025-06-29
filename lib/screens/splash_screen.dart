import 'package:flutter/material.dart';
import 'dart:async';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import '../utils/asset_helper.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _progressAnimation;

  String _loadingText = 'Initializing PharmaPOS...';
  String _pharmacyName = 'PharmaPOS Desktop'; // Updated for desktop
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLoadingSequence();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Progress animation controller
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Text animations
    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Progress animation
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _startLoadingSequence() async {
    try {
      // Start logo animation
      _logoController.forward();

      // Wait a bit then start text animation
      await Future.delayed(const Duration(milliseconds: 800));
      _textController.forward();

      // Start progress animation
      await Future.delayed(const Duration(milliseconds: 500));
      _progressController.forward();

      // Simulate loading steps with actual database initialization
      await _performActualLoading();

      // Navigate to home screen
      if (mounted && !_hasError) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _loadingText = 'Error: $e';
      });
    }
  }

  Future<void> _performActualLoading() async {
    final loadingSteps = [
      'Initializing offline database...',
      'Setting up local storage...',
      'Loading pharmacy inventory...',
      'Preparing point of sale system...',
      'Finalizing setup...',
    ];

    for (int i = 0; i < loadingSteps.length; i++) {
      if (mounted) {
        setState(() {
          _loadingText = loadingSteps[i];
        });
      }

      // Perform actual initialization on specific steps
      if (i == 0) {
        // Initialize database
        try {
          await DatabaseService.instance.database;
          print('✅ Database initialized successfully');
        } catch (e) {
          print('❌ Database initialization failed: $e');
          throw Exception('Failed to initialize database: $e');
        }
      } else if (i == 1) {
        // Test database connection
        try {
          final isConnected = await DatabaseService.instance.testConnection();
          if (!isConnected) {
            throw Exception('Database connection test failed');
          }
          print('✅ Database connection verified');
        } catch (e) {
          print('❌ Database connection test failed: $e');
          throw Exception('Database connection failed: $e');
        }
      } else if (i == 2) {
        // Load initial data
        try {
          final products = await DatabaseService.instance.getAllProducts();
          final invoices = await DatabaseService.instance.getAllInvoices();
          print('✅ Loaded ${products.length} products and ${invoices.length} invoices');
        } catch (e) {
          print('❌ Failed to load initial data: $e');
          throw Exception('Failed to load data: $e');
        }
      }

      await Future.delayed(Duration(milliseconds: 800 + (i * 200)));
    }

    // Final delay to show completion
    if (mounted) {
      setState(() {
        _loadingText = 'Ready! Opening PharmaPOS...';
      });
    }
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              Colors.white,
              AppTheme.primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Section
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Opacity(
                      opacity: _logoOpacityAnimation.value,
                      child: AssetHelper.getSplashLogoWidget(
                        size: 120,
                        fallbackColor: AppTheme.primaryColor,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Pharmacy Name Section
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _textSlideAnimation,
                    child: Opacity(
                      opacity: _textOpacityAnimation.value,
                      child: Column(
                        children: [
                          Text(
                            _pharmacyName,
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                              fontSize: 42,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Offline-Ready POS System',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Professional Pharmacy Management Solution',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 60),

              // Loading Section
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textOpacityAnimation.value,
                    child: Column(
                      children: [
                        // Loading Text
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Text(
                            _loadingText,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: _hasError ? Colors.red[700] : Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Progress Bar
                        if (!_hasError) ...[
                          Container(
                            width: 320,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  width: 320 * _progressAnimation.value,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.primaryColor,
                                        AppTheme.primaryColor.withOpacity(0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Loading Indicator
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ] else ...[
                          // Error state
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _hasError = false;
                                _loadingText = 'Retrying...';
                              });
                              _startLoadingSequence();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 80),

              // Footer
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textOpacityAnimation.value * 0.7,
                    child: Column(
                      children: [
                        Text(
                          'Version 1.0.0 - Desktop Edition',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[400],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '© 2024 PharmaPOS. All rights reserved.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[400],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}