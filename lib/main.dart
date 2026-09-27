import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

Map<String, dynamic> asStringKeyedMap(dynamic data) {
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  } else if (data is List) {
    final map = <String, dynamic>{};
    for (var i = 0; i < data.length; i++) {
      if (data[i] != null) {
        map[i.toString()] = data[i];
      }
    }
    return map;
  }
  return {};
}

// ─────────────────────────────────────────────
//  Design tokens
// ─────────────────────────────────────────────

class _AppColors {
  _AppColors._();

  static const Color primary = Color(0xFF1565C0); // deep blue
  static const Color primaryLight = Color(0xFFE3F0FF);
  static const Color accent = Color(0xFF0D47A1);
  static const Color surface = Color(0xFFF7F9FC);
  static const Color card = Colors.white;
  static const Color scaffold = Color(0xFFF1F4F8);
  static const Color textPrimary = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF5F6B7A);
  static const Color border = Color(0xFFE2E8F0);
  static const Color available = Color(0xFF2E7D32);
  static const Color availableBg = Color(0xFFE8F5E9);
  static const Color occupied = Color(0xFFC62828);
  static const Color occupiedBg = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFF57C00);
  static const Color divider = Color(0xFFEEF1F5);
}

class _AppRadius {
  _AppRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

// ─────────────────────────────────────────────
//  App root
// ─────────────────────────────────────────────

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(
      ThemeData.light().textTheme,
    );

    return MaterialApp(
      title: 'ParkLink IoT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: _AppColors.primary,
        scaffoldBackgroundColor: _AppColors.scaffold,
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0.5,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _AppColors.textPrimary,
          ),
          iconTheme: const IconThemeData(color: _AppColors.textPrimary),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: _AppColors.card,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_AppRadius.md),
            side: const BorderSide(color: _AppColors.border, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_AppRadius.sm),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _AppColors.primary,
            side: const BorderSide(color: _AppColors.primary, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_AppRadius.sm),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _AppColors.primary,
            textStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _AppColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_AppRadius.sm),
            borderSide: const BorderSide(color: _AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_AppRadius.sm),
            borderSide: const BorderSide(color: _AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_AppRadius.sm),
            borderSide:
                const BorderSide(color: _AppColors.primary, width: 1.5),
          ),
          labelStyle: GoogleFonts.inter(
            color: _AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: GoogleFonts.inter(color: _AppColors.textSecondary),
        ),
        dividerTheme: const DividerThemeData(
          color: _AppColors.divider,
          thickness: 1,
          space: 0,
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_AppRadius.lg),
          ),
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.white,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// ─────────────────────────────────────────────
//  Reusable widgets
// ─────────────────────────────────────────────

/// A subtle status chip used throughout the app.
class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color backgroundColor;
  final IconData? icon;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header for list screens.
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: _AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Slot map screen
// ─────────────────────────────────────────────

class SlotMapScreen extends StatelessWidget {
  final String locationId;
  final String locationName;
  final String layoutShape;

  const SlotMapScreen({
    super.key,
    required this.locationId,
    required this.locationName,
    required this.layoutShape,
  });

  List<Offset> _computePositions(int count, String shape) {
    List<Offset> positions = [];

    if (shape == 'Linear') {
      for (int i = 0; i < count; i++) {
        positions.add(Offset(i.toDouble(), 0));
      }
    } else if (shape == 'L') {
      int verticalCount = (count / 2).ceil();
      int horizontalCount = count - verticalCount;
      for (int i = 0; i < verticalCount; i++) {
        positions.add(Offset(0, i.toDouble()));
      }
      for (int i = 0; i < horizontalCount; i++) {
        positions.add(Offset((i + 1).toDouble(), (verticalCount - 1).toDouble()));
      }
    } else if (shape == 'T') {
      int topCount = (count / 2).ceil();
      int stemCount = count - topCount;
      int midCol = (topCount / 2).floor();
      for (int i = 0; i < topCount; i++) {
        positions.add(Offset(i.toDouble(), 0));
      }
      for (int i = 0; i < stemCount; i++) {
        positions.add(Offset(midCol.toDouble(), (i + 1).toDouble()));
      }
    } else {
      for (int i = 0; i < count; i++) {
        positions.add(Offset((i % 5).toDouble(), (i ~/ 5).toDouble()));
      }
    }
    return positions;
  }

  @override
  Widget build(BuildContext context) {
    final slotsRef = FirebaseDatabase.instance.ref('locations/$locationId/slots');

    return Scaffold(
      appBar: AppBar(
        title: Text(locationName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          // Legend
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _legendDot(_AppColors.available, 'Available'),
                const SizedBox(width: 24),
                _legendDot(_AppColors.occupied, 'Occupied'),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: slotsRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _AppColors.primary,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return _buildEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Something went wrong',
                    subtitle: '${snapshot.error}',
                  );
                }

                final data = snapshot.data?.snapshot.value;
                if (data == null) {
                  return _buildEmptyState(
                    icon: Icons.grid_off_rounded,
                    title: 'No slots found',
                    subtitle: 'This location has no parking slots configured.',
                  );
                }

                final slotsMap = asStringKeyedMap(data);
                final slotNumbers = slotsMap.keys.map((k) => int.parse(k)).toList()..sort();
                final positions = _computePositions(slotNumbers.length, layoutShape);

                const double cellSize = 80;
                double maxX = 0, maxY = 0;
                for (var p in positions) {
                  if (p.dx > maxX) maxX = p.dx;
                  if (p.dy > maxY) maxY = p.dy;
                }

                return InteractiveViewer(
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(200),
                  minScale: 0.3,
                  maxScale: 4.0,
                  child: SizedBox(
                    width: (maxX + 1) * cellSize + 60,
                    height: (maxY + 1) * cellSize + 60,
                    child: Stack(
                      children: List.generate(slotNumbers.length, (index) {
                        final slotNum = slotNumbers[index];
                        final slotData = asStringKeyedMap(slotsMap[slotNum.toString()]);
                        final status = slotData['status'] ?? 'empty';
                        final pos = positions[index];
                        final isEmpty = status == 'empty';

                        return Positioned(
                          left: pos.dx * cellSize + 30,
                          top: pos.dy * cellSize + 30,
                          child: Container(
                            width: cellSize - 12,
                            height: cellSize - 12,
                            decoration: BoxDecoration(
                              color: isEmpty
                                  ? _AppColors.availableBg
                                  : _AppColors.occupiedBg,
                              borderRadius: BorderRadius.circular(_AppRadius.md),
                              border: Border.all(
                                color: isEmpty
                                    ? _AppColors.available.withValues(alpha: 0.4)
                                    : _AppColors.occupied.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isEmpty
                                      ? Icons.check_circle_rounded
                                      : Icons.directions_car_rounded,
                                  size: 22,
                                  color: isEmpty
                                      ? _AppColors.available
                                      : _AppColors.occupied,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '$slotNum',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isEmpty
                                        ? _AppColors.available
                                        : _AppColors.occupied,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: _AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Sign-out dialog
// ─────────────────────────────────────────────

Future<void> _confirmAndSignOut(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Sign Out',
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
      content: Text(
        'Are you sure you want to sign out?',
        style: GoogleFonts.inter(color: _AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _AppColors.occupied,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Sign Out'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}

// ─────────────────────────────────────────────
//  Login screen
// ─────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  bool _obscurePassword = true;

Future<void> _login() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    print('Step 1: trying to sign in...');
    final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    print('Step 2: signed in! uid = ${userCredential.user!.uid}');

    final uid = userCredential.user!.uid;

    print('Step 3: reading role from database...');
    final snapshot = await FirebaseDatabase.instance.ref('users/$uid/role').get();
    print('Step 4: got role = ${snapshot.value}');

    if (!mounted) return;

    if (snapshot.exists && snapshot.value == 'admin') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const UserHomeScreen()),
      );
    }
  } on FirebaseAuthException catch (e) {
    print('FirebaseAuthException: ${e.message}');
    setState(() {
      _errorMessage = e.message ?? 'Login failed';
    });
  } catch (e) {
    print('OTHER ERROR: $e');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo area
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.local_parking_rounded,
                    size: 36,
                    color: _AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'ParkLink IoT',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: _AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in to manage your parking spaces',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                // Form card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(_AppRadius.lg),
                    border: Border.all(color: _AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Email',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'you@example.com',
                          prefixIcon: Icon(Icons.email_outlined, size: 20),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Password',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon:
                              const Icon(Icons.lock_outline_rounded, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: _AppColors.textSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _AppColors.occupiedBg,
                            borderRadius:
                                BorderRadius.circular(_AppRadius.sm),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  size: 18, color: _AppColors.occupied),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: _AppColors.occupied,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      SizedBox(
                        height: 48,
                        child: _isLoading
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: _AppColors.primary,
                                  ),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: _login,
                                child: const Text('Sign In'),
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const SignupScreen()),
                        );
                      },
                      child: Text(
                        'Sign up',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Signup screen
// ─────────────────────────────────────────────

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _signup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // New signups are always regular users — no role node needed,
      // since our code treats "no role" as a normal user.
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const UserHomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Signup failed';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo area
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 36,
                    color: _AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Create Account',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: _AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Get started with ParkLink IoT',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                // Form card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(_AppRadius.lg),
                    border: Border.all(color: _AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Email',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'you@example.com',
                          prefixIcon: Icon(Icons.email_outlined, size: 20),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Password',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon:
                              const Icon(Icons.lock_outline_rounded, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: _AppColors.textSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _AppColors.occupiedBg,
                            borderRadius:
                                BorderRadius.circular(_AppRadius.sm),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  size: 18, color: _AppColors.occupied),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: _AppColors.occupied,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      SizedBox(
                        height: 48,
                        child: _isLoading
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: _AppColors.primary,
                                  ),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: _signup,
                                child: const Text('Create Account'),
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        'Sign in',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Admin home screen
// ─────────────────────────────────────────────

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locationsRef = FirebaseDatabase.instance.ref('locations');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: false,
        actions: [
          _AppBarAction(
            icon: Icons.sensor_door_outlined,
            tooltip: 'Gate status',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GateStatusScreen()),
              );
            },
          ),
          _AppBarAction(
            icon: Icons.logout_rounded,
            tooltip: 'Sign out',
            onPressed: () => _confirmAndSignOut(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          // Header strip
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parking Locations',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage and control individual slots',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: locationsRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _AppColors.primary,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return _buildEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Something went wrong',
                    subtitle: '${snapshot.error}',
                  );
                }

                final data = snapshot.data?.snapshot.value;
                if (data == null) {
                  return _buildEmptyState(
                    icon: Icons.location_off_rounded,
                    title: 'No locations found',
                    subtitle: 'Add a parking location to get started.',
                  );
                }

                final locationsMap = asStringKeyedMap(data);
                final entries = locationsMap.entries.toList();

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final locationId = entry.key;
                    final locationData = asStringKeyedMap(entry.value);
                    final name = locationData['name'] ?? locationId;
                    final totalSlots = locationData['total_slots'] ?? 0;

                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(_AppRadius.md),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AdminSlotControlScreen(
                                locationId: locationId,
                                locationName: name,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: _AppColors.primaryLight,
                                  borderRadius:
                                      BorderRadius.circular(_AppRadius.sm),
                                ),
                                child: const Icon(
                                  Icons.location_on_outlined,
                                  color: _AppColors.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: _AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '$totalSlots total slots',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: _AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: _AppColors.textSecondary,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Admin slot control screen
// ─────────────────────────────────────────────

class AdminSlotControlScreen extends StatelessWidget {
  final String locationId;
  final String locationName;

  const AdminSlotControlScreen({
    super.key,
    required this.locationId,
    required this.locationName,
  });

  Future<void> _toggleSlot(String slotNumber, String currentStatus) async {
    final newStatus = currentStatus == 'empty' ? 'occupied' : 'empty';
    final slotRef = FirebaseDatabase.instance
        .ref('locations/$locationId/slots/$slotNumber/status');
    await slotRef.set(newStatus);
  }

  @override
  Widget build(BuildContext context) {
    final slotsRef = FirebaseDatabase.instance.ref('locations/$locationId/slots');

    return Scaffold(
      appBar: AppBar(
        title: Text(locationName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const _SectionHeader(
            title: 'SLOT MANAGEMENT',
            subtitle: 'Toggle slot status or view sensor data',
          ),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: slotsRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _AppColors.primary,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return _buildEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Something went wrong',
                    subtitle: '${snapshot.error}',
                  );
                }

                final data = snapshot.data?.snapshot.value;
                if (data == null) {
                  return _buildEmptyState(
                    icon: Icons.grid_off_rounded,
                    title: 'No slots found',
                    subtitle: 'This location has no slots configured.',
                  );
                }

                final slotsMap = asStringKeyedMap(data);
                final slotNumbers = slotsMap.keys.map((k) => int.parse(k)).toList()..sort();

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: slotNumbers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final slotNum = slotNumbers[index].toString();
                    final slotData = asStringKeyedMap(slotsMap[slotNum]);
                    final status = slotData['status'] ?? 'empty';
                    final sourceType = slotData['source_type'] ?? 'demo';
                    final isSensor = sourceType == 'sensor';
                    final isEmpty = status == 'empty';

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isEmpty
                                    ? _AppColors.availableBg
                                    : _AppColors.occupiedBg,
                                borderRadius:
                                    BorderRadius.circular(_AppRadius.sm),
                              ),
                              child: Icon(
                                Icons.local_parking_rounded,
                                color: isEmpty
                                    ? _AppColors.available
                                    : _AppColors.occupied,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Slot $slotNum',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: _AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  _StatusChip(
                                    label: isSensor
                                        ? 'Sensor'
                                        : isEmpty
                                            ? 'Available'
                                            : 'Occupied',
                                    color: isSensor
                                        ? _AppColors.primary
                                        : isEmpty
                                            ? _AppColors.available
                                            : _AppColors.occupied,
                                    backgroundColor: isSensor
                                        ? _AppColors.primaryLight
                                        : isEmpty
                                            ? _AppColors.availableBg
                                            : _AppColors.occupiedBg,
                                    icon: isSensor
                                        ? Icons.sensors_rounded
                                        : isEmpty
                                            ? Icons.check_circle_outline_rounded
                                            : Icons.block_rounded,
                                  ),
                                ],
                              ),
                            ),
                            if (isSensor)
                              Text(
                                'Read-only',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: _AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            else
                              SizedBox(
                                height: 36,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    side: BorderSide(
                                      color: isEmpty
                                          ? _AppColors.occupied
                                          : _AppColors.available,
                                      width: 1.5,
                                    ),
                                    foregroundColor: isEmpty
                                        ? _AppColors.occupied
                                        : _AppColors.available,
                                    textStyle: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onPressed: () => _toggleSlot(slotNum, status),
                                  child: Text(isEmpty
                                      ? 'Mark Occupied'
                                      : 'Mark Empty'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Gate status screen
// ─────────────────────────────────────────────

class GateStatusScreen extends StatelessWidget {
  const GateStatusScreen({super.key});

  Future<void> _setGateStatus(String status) async {
    final gateRef = FirebaseDatabase.instance.ref('gate/status');
    await gateRef.set(status);
  }

  @override
  Widget build(BuildContext context) {
    final gateRef = FirebaseDatabase.instance.ref('gate/status');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry Gate'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: gateRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _AppColors.primary,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return _buildEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Something went wrong',
                    subtitle: '${snapshot.error}',
                  );
                }

                final status = snapshot.data?.snapshot.value ?? 'unknown';
                final isOpen = status == 'open';

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Gate status indicator
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: isOpen
                                ? _AppColors.availableBg
                                : _AppColors.occupiedBg,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isOpen
                                  ? _AppColors.available.withValues(alpha: 0.3)
                                  : _AppColors.occupied.withValues(alpha: 0.3),
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            isOpen
                                ? Icons.lock_open_rounded
                                : Icons.lock_rounded,
                            size: 48,
                            color: isOpen
                                ? _AppColors.available
                                : _AppColors.occupied,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          isOpen ? 'Gate Open' : 'Gate Closed',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: _AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Current status: $status',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: _AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Control buttons
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _AppColors.available,
                                  ),
                                  onPressed: () => _setGateStatus('open'),
                                  icon: const Icon(
                                      Icons.lock_open_rounded, size: 18),
                                  label: const Text('Open Gate'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _AppColors.occupied,
                                  ),
                                  onPressed: () => _setGateStatus('closed'),
                                  icon: const Icon(
                                      Icons.lock_rounded, size: 18),
                                  label: const Text('Close Gate'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Search all slots screen
// ─────────────────────────────────────────────

class SearchAllSlotsScreen extends StatelessWidget {
  const SearchAllSlotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locationsRef = FirebaseDatabase.instance.ref('locations');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Slots'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: locationsRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _AppColors.primary,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return _buildEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Something went wrong',
                    subtitle: '${snapshot.error}',
                  );
                }

                final data = snapshot.data?.snapshot.value;
                if (data == null) {
                  return _buildEmptyState(
                    icon: Icons.location_off_rounded,
                    title: 'No locations found',
                    subtitle: 'There are no parking locations yet.',
                  );
                }

                final locationsMap = asStringKeyedMap(data);
                final List<Map<String, dynamic>> emptySlots = [];

                locationsMap.forEach((locationId, locationValue) {
                  final locationData = asStringKeyedMap(locationValue);
                  final locationName = locationData['name'] ?? locationId;

                  if (locationData['slots'] != null) {
                    final slotsMap = asStringKeyedMap(locationData['slots']);
                    slotsMap.forEach((slotNum, slotValue) {
                      final slotData = asStringKeyedMap(slotValue);
                      if (slotData['status'] == 'empty') {
                        emptySlots.add({
                          'locationName': locationName,
                          'slotNumber': slotNum,
                        });
                      }
                    });
                  }
                });

                if (emptySlots.isEmpty) {
                  return _buildEmptyState(
                    icon: Icons.event_busy_rounded,
                    title: 'All slots occupied',
                    subtitle: 'No empty parking slots are available right now.',
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary bar
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _AppColors.availableBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${emptySlots.length} available',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _AppColors.available,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: emptySlots.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = emptySlots[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _AppColors.availableBg,
                                      borderRadius: BorderRadius.circular(
                                          _AppRadius.sm),
                                    ),
                                    child: const Icon(
                                      Icons.local_parking_rounded,
                                      color: _AppColors.available,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${item['locationName']}',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Slot ${item['slotNumber']}',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: _AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _StatusChip(
                                    label: 'Available',
                                    color: _AppColors.available,
                                    backgroundColor: _AppColors.availableBg,
                                    icon: Icons.check_circle_outline_rounded,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  User home screen
// ─────────────────────────────────────────────

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locationsRef = FirebaseDatabase.instance.ref('locations');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_parking_rounded,
                size: 16,
                color: _AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'ParkLink',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          _AppBarAction(
            icon: Icons.search_rounded,
            tooltip: 'Search all lots',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchAllSlotsScreen()),
              );
            },
          ),
          _AppBarAction(
            icon: Icons.logout_rounded,
            tooltip: 'Sign out',
            onPressed: () => _confirmAndSignOut(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          // Header
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a Location',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'View real-time slot availability',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: locationsRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _AppColors.primary,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _buildEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Something went wrong',
                    subtitle: '${snapshot.error}',
                  );
                }

                final data = snapshot.data?.snapshot.value;
                if (data == null) {
                  return _buildEmptyState(
                    icon: Icons.location_off_rounded,
                    title: 'No locations found',
                    subtitle: 'No parking locations are available yet.',
                  );
                }

                final locationsMap = asStringKeyedMap(data);
                final entries = locationsMap.entries.toList();

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final locationId = entry.key;
                    final locationData =
                        Map<String, dynamic>.from(entry.value as Map);

                    final name = locationData['name'] ?? locationId;
                    final totalSlots = locationData['total_slots'] ?? 0;
                    final shape = locationData['layout_shape'] ?? 'Linear';

                    int emptyCount = 0;
                    if (locationData['slots'] != null) {
                      final slotsMap = asStringKeyedMap(locationData['slots']);
                      emptyCount = slotsMap.values.where((slot) {
                        final slotData = asStringKeyedMap(slot);
                        return slotData['status'] == 'empty';
                      }).length;
                    }

                    final bool hasEmpty = emptyCount > 0;

                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(_AppRadius.md),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SlotMapScreen(
                                locationId: locationId,
                                locationName: name,
                                layoutShape: shape,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: hasEmpty
                                      ? _AppColors.availableBg
                                      : _AppColors.occupiedBg,
                                  borderRadius:
                                      BorderRadius.circular(_AppRadius.sm),
                                ),
                                child: Icon(
                                  Icons.location_on_outlined,
                                  color: hasEmpty
                                      ? _AppColors.available
                                      : _AppColors.occupied,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: _AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // Availability bar
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: totalSlots > 0
                                                  ? emptyCount / totalSlots
                                                  : 0,
                                              minHeight: 6,
                                              backgroundColor:
                                                  _AppColors.border,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                hasEmpty
                                                    ? _AppColors.available
                                                    : _AppColors.occupied,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '$emptyCount / $totalSlots',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: hasEmpty
                                                ? _AppColors.available
                                                : _AppColors.occupied,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: _AppColors.textSecondary,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Helper widgets
// ─────────────────────────────────────────────

class _AppBarAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _AppBarAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            child: Icon(icon, size: 21, color: _AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

Widget _buildEmptyState({
  required IconData icon,
  required String title,
  String? subtitle,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: _AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    ),
  );
}