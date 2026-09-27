import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkLink IoT',
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}

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
      appBar: AppBar(title: Text(locationName)),
      body: StreamBuilder<DatabaseEvent>(
        stream: slotsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data?.snapshot.value;
          if (data == null) {
            return const Center(child: Text('No slots found.'));
          }

          final slotsMap = asStringKeyedMap(data);
          final slotNumbers = slotsMap.keys.map((k) => int.parse(k)).toList()..sort();
          final positions = _computePositions(slotNumbers.length, layoutShape);

          const double cellSize = 70;
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
              width: (maxX + 1) * cellSize + 40,
              height: (maxY + 1) * cellSize + 40,
              child: Stack(
                children: List.generate(slotNumbers.length, (index) {
                  final slotNum = slotNumbers[index];
                  final slotData = asStringKeyedMap(slotsMap[slotNum.toString()]);
                  final status = slotData['status'] ?? 'empty';
                  final pos = positions[index];

                  return Positioned(
                    left: pos.dx * cellSize + 20,
                    top: pos.dy * cellSize + 20,
                    child: Container(
                      width: cellSize - 10,
                      height: cellSize - 10,
                      decoration: BoxDecoration(
                        color: status == 'empty' ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black26),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$slotNum',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<void> _confirmAndSignOut(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sign Out'),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

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
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signup,
                    child: const Text('Sign Up'),
                  ),
          ],
        ),
      ),
    );
  }
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
      appBar: AppBar(title: const Text('ParkLink IoT Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
              },
              child: const Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locationsRef = FirebaseDatabase.instance.ref('locations');

    return Scaffold(
      appBar: AppBar(
      title: const Text('Admin Dashboard'),
      actions: [
        IconButton(
          icon: const Icon(Icons.sensor_door),
          tooltip: 'Gate status',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GateStatusScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Sign out',
          onPressed: () => _confirmAndSignOut(context),
        ),
      ],
    ),
      body: StreamBuilder<DatabaseEvent>(
        stream: locationsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data?.snapshot.value;
          if (data == null) {
            return const Center(child: Text('No locations found.'));
          }

          final locationsMap = asStringKeyedMap(data);

          return ListView(
            children: locationsMap.entries.map((entry) {
              final locationId = entry.key;
              final locationData = asStringKeyedMap(entry.value);
              final name = locationData['name'] ?? locationId;
              final totalSlots = locationData['total_slots'] ?? 0;

              return ListTile(
                title: Text(name),
                subtitle: Text('$totalSlots total slots'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

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
      appBar: AppBar(title: Text(locationName)),
      body: StreamBuilder<DatabaseEvent>(
        stream: slotsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data?.snapshot.value;
          if (data == null) {
            return const Center(child: Text('No slots found.'));
          }

          final slotsMap = asStringKeyedMap(data);
          final slotNumbers = slotsMap.keys.map((k) => int.parse(k)).toList()..sort();

          return ListView.builder(
            itemCount: slotNumbers.length,
            itemBuilder: (context, index) {
              final slotNum = slotNumbers[index].toString();
              final slotData = asStringKeyedMap(slotsMap[slotNum]);
              final status = slotData['status'] ?? 'empty';
              final sourceType = slotData['source_type'] ?? 'demo';
              final isSensor = sourceType == 'sensor';

              return ListTile(
                leading: Icon(
                  Icons.local_parking,
                  color: status == 'empty' ? Colors.green : Colors.red,
                ),
                title: Text('Slot $slotNum'),
                subtitle: Text(isSensor ? 'Sensor-controlled' : 'Demo — $status'),
                trailing: isSensor
                    ? const Text('Read-only', style: TextStyle(color: Colors.grey))
                    : ElevatedButton(
                        onPressed: () => _toggleSlot(slotNum, status),
                        child: Text(status == 'empty' ? 'Mark Occupied' : 'Mark Empty'),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}

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
      appBar: AppBar(title: const Text('Entry Gate Status')),
      body: StreamBuilder<DatabaseEvent>(
        stream: gateRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final status = snapshot.data?.snapshot.value ?? 'unknown';

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == 'open' ? Icons.lock_open : Icons.lock,
                  size: 80,
                  color: status == 'open' ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Gate is currently: $status',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => _setGateStatus('open'),
                  child: const Text('Set Open'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _setGateStatus('closed'),
                  child: const Text('Set Closed'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
class SearchAllSlotsScreen extends StatelessWidget {
  const SearchAllSlotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locationsRef = FirebaseDatabase.instance.ref('locations');

    return Scaffold(
      appBar: AppBar(title: const Text('All Empty Slots')),
      body: StreamBuilder<DatabaseEvent>(
        stream: locationsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data?.snapshot.value;
          if (data == null) {
            return const Center(child: Text('No locations found.'));
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
            return const Center(child: Text('No empty slots available right now.'));
          }

          return ListView.builder(
            itemCount: emptySlots.length,
            itemBuilder: (context, index) {
              final item = emptySlots[index];
              return ListTile(
                leading: const Icon(Icons.local_parking, color: Colors.green),
                title: Text('${item['locationName']} — Slot ${item['slotNumber']}'),
              );
            },
          );
        },
      ),
    );
  }
}

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locationsRef = FirebaseDatabase.instance.ref('locations');

    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Select Parking Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search all lots',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchAllSlotsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => _confirmAndSignOut(context),
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: locationsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data?.snapshot.value;
          if (data == null) {
            return const Center(child: Text('No locations found.'));
          }

          final locationsMap = asStringKeyedMap(data);

          return ListView(
            children: locationsMap.entries.map((entry) {
              final locationId = entry.key;
              final locationData = Map<String, dynamic>.from(entry.value as Map);

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

              return ListTile(
                title: Text(name),
                
                trailing: Text('$emptyCount / $totalSlots empty'),
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
              );
            }).toList(),
          );
        },
      ),
    );
  }
}