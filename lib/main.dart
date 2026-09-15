import 'package:flutter/material.dart';

void main() {
  runApp(const CorviaApp());
}

class CorviaApp extends StatelessWidget {
  const CorviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CORVIA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF00A8FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00A8FF),
          secondary: Color(0xFF00E676),
          surface: Color(0xFF1E1E1E),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _show2FA = false;

  void _handleLogin() {
    if (!_show2FA) {
      setState(() {
        _show2FA = true;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.bolt, size: 80, color: Color(0xFF00A8FF)),
            const SizedBox(height: 10),
            const Text(
              'CORVIA',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF00A8FF)),
            ),
            const Text(
              'Financial Gateway',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            if (!_show2FA) ...[
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email / Téléphone',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
            ] else ...[
              const Text(
                'Authentification 2FA',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Color(0xFF00E676)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'Code de sécurité (OTP)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A8FF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _show2FA ? 'VÉRIFIER & ACCÉDER' : 'SE CONNECTER',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedSource = 'Moncash';
  String selectedDestination = 'Binance';
  final _amountController = TextEditingController();

  final List<String> sources = ['Moncash', 'Natcash', 'Unibank'];
  final List<String> destinations = ['Binance', 'Wise', 'Meru'];

  void _processRecharge() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction initiée'),
        content: Text(
          'Recharge de ${_amountController.text} HTG depuis $selectedSource vers $selectedDestination en cours de traitement.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _amountController.clear();
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFF00E676))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CORVIA Dashboard'),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00A8FF), Color(0xFF00E676)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Solde estimé', style: TextStyle(color: Colors.black87, fontSize: 14)),
                  SizedBox(height: 8),
                  Text('\$1,250.00 USD', style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Nouvelle Recharge', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedSource,
                    decoration: const InputDecoration(labelText: 'Source de paiement (Local)'),
                    items: sources.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => setState(() => selectedSource = val!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedDestination,
                    decoration: const InputDecoration(labelText: 'Destination (Compte en ligne)'),
                    items: destinations.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (val) => setState(() => selectedDestination = val!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Montant (HTG)'),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _processRecharge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5252),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('EFFECTUER LA RECHARGE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
