import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CorviaApp());
}

// ============================================================================
// 1. CHARTE GRAPHIQUE & THÈME OFFICIEL CORVIA
// ============================================================================
class CorviaColors {
  static const Color cyan = Color(0xFF00A8FF);       // Bleu cyan électrique
  static const Color lime = Color(0xFF00E676);       // Vert lime de validation
  static const Color accent = Color(0xFFFF5252);     // Accentuation
  static const Color background = Color(0xFF121212); // Fond sombre
  static const Color surface = Color(0xFF1E1E1E);    // Surface des cartes
  static const Color surfaceElevated = Color(0xFF252525);
  static const Color border = Color(0xFF2C2C2C);     // Bordures
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFA0A0A0);
}

class CorviaApp extends StatelessWidget {
  const CorviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CORVIA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: CorviaColors.background,
        primaryColor: CorviaColors.cyan,
        colorScheme: const ColorScheme.dark(
          primary: CorviaColors.cyan,
          secondary: CorviaColors.lime,
          error: CorviaColors.accent,
          surface: CorviaColors.surface,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: CorviaColors.textPrimary,
          displayColor: CorviaColors.textPrimary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: CorviaColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: CorviaColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: CorviaColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: CorviaColors.cyan, width: 1.5),
          ),
          labelStyle: const TextStyle(color: CorviaColors.textSecondary, fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      home: const AuthScreen(),
    );
  }
}

// ============================================================================
// 2. MODÈLES DE DONNÉES & ÉTAT GLOBAL (SINGLETON)
// ============================================================================
class TransactionItem {
  final String id;
  final String referenceCode;
  final String source;
  final String destination;
  final double amountHtg;
  final double amountUsd;
  final DateTime date;
  final String status;

  TransactionItem({
    required this.id,
    required this.referenceCode,
    required this.source,
    required this.destination,
    required this.amountHtg,
    required this.amountUsd,
    required this.date,
    required this.status,
  });
}

class PaymentProvider {
  final String id;
  final String name;
  final String iconSymbol;
  final Color color;
  final String type; // 'local' ou 'global'

  PaymentProvider({
    required this.id,
    required this.name,
    required this.iconSymbol,
    required this.color,
    required this.type,
  });
}

class MockFintechState extends ChangeNotifier {
  static final MockFintechState instance = MockFintechState._internal();
  factory MockFintechState() => instance;
  MockFintechState._internal();

  String userName = "Jean-Marc Baptiste";
  String userEmail = "j.baptiste@corvia.gateway";
  String userPhone = "+509 3712-4490";
  String kycTier = "Tier 1 (Basique)";
  double kycDailyLimit = 150.0;
  bool isKycPending = false;
  String? kycDocumentType;
  String? kycDocumentNumber;

  double balanceHtg = 84500.0;
  double balanceUsd = 642.50;
  final double exchangeRate = 132.50; // 1 USD = 132.50 HTG

  final List<TransactionItem> transactions = [
    TransactionItem(
      id: 'tx_1',
      referenceCode: 'CRV-BN-849102',
      source: 'Moncash (+509 3712-****)',
      destination: 'Binance Pay (USDT TRC20)',
      amountHtg: 6625.0,
      amountUsd: 50.0,
      date: DateTime.now().subtract(const Duration(minutes: 25)),
      status: 'Complété',
    ),
    TransactionItem(
      id: 'tx_2',
      referenceCode: 'CRV-WS-381900',
      source: 'Natcash (+509 4288-****)',
      destination: 'Wise Account (USD)',
      amountHtg: 15900.0,
      amountUsd: 120.0,
      date: DateTime.now().subtract(const Duration(hours: 4)),
      status: 'Complété',
    ),
  ];

  final List<PaymentProvider> inputProviders = [
    PaymentProvider(id: 'moncash', name: 'Moncash (Digicel)', iconSymbol: 'M', color: const Color(0xFFE50914), type: 'local'),
    PaymentProvider(id: 'natcash', name: 'Natcash (Natcom)', iconSymbol: 'N', color: const Color(0xFF0072CE), type: 'local'),
  ];

  final List<PaymentProvider> outputProviders = [
    PaymentProvider(id: 'binance', name: 'Binance Pay (USDT)', iconSymbol: 'B', color: const Color(0xFFF3BA2F), type: 'global'),
    PaymentProvider(id: 'wise', name: 'Wise (USD / EUR)', iconSymbol: 'W', color: const Color(0xFF00E676), type: 'global'),
    PaymentProvider(id: 'meru', name: 'Meru Dollar Card', iconSymbol: 'M', color: const Color(0xFF9C27B0), type: 'global'),
  ];

  void addTransaction({
    required String source,
    required String destination,
    required double amountHtg,
    required double amountUsd,
  }) {
    final newTx = TransactionItem(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      referenceCode: 'CRV-${destination.substring(0, 2).toUpperCase()}-${Random().nextInt(899999) + 100000}',
      source: source,
      destination: destination,
      amountHtg: amountHtg,
      amountUsd: amountUsd,
      date: DateTime.now(),
      status: 'Complété',
    );
    transactions.insert(0, newTx);
    balanceHtg -= amountHtg;
    notifyListeners();
  }

  void submitKyc({required String docType, required String docNumber}) {
    kycDocumentType = docType;
    kycDocumentNumber = docNumber;
    kycTier = "Tier 2 (Vérifié)";
    kycDailyLimit = 1500.0;
    isKycPending = false;
    notifyListeners();
  }
}

// ============================================================================
// 3. ÉCRAN D'ACCUEIL : CRÉATION DE COMPTE (DÉFAUT) & CONNEXION
// ============================================================================
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Par défaut sur 'false' (Inscription) dès la première visite de l'utilisateur
  bool isLogin = false;
  final TextEditingController _fullNameController = TextEditingController(text: 'Jean-Marc Baptiste');
  final TextEditingController _emailController = TextEditingController(text: 'j.baptiste@corvia.gateway');
  final TextEditingController _phoneController = TextEditingController(text: '+509 3712-4490');
  final TextEditingController _passwordController = TextEditingController(text: 'CorviaPass2026!');
  bool _obscurePassword = true;

  void _onProceed() {
    if (!isLogin && _fullNameController.text.trim().isNotEmpty) {
      MockFintechState.instance.userName = _fullNameController.text.trim();
      MockFintechState.instance.userEmail = _emailController.text.trim();
      MockFintechState.instance.userPhone = _phoneController.text.trim();
    }
    // Redirection vers l'étape de validation 2FA obligatoire
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TwoFactorScreen(
          userIdentifier: isLogin ? _emailController.text : _phoneController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo & Badge CORVIA
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: CorviaColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: CorviaColors.cyan.withOpacity(0.4), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: CorviaColors.cyan.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.bolt_rounded, color: CorviaColors.cyan, size: 38),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'CORVIA',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      color: CorviaColors.cyan,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Passerelle Financière Moncash & Natcash vers Global',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: CorviaColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Onglets de sélection : Créer un compte (défaut) / Déjà un compte
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: CorviaColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: CorviaColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isLogin = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !isLogin ? CorviaColors.cyan : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Créer un compte',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: !isLogin ? Colors.black : CorviaColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isLogin = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isLogin ? CorviaColors.cyan : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Déjà un compte',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isLogin ? Colors.black : CorviaColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Formulaire dynamique
                if (!isLogin) ...[
                  TextField(
                    controller: _fullNameController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      labelText: 'Nom Complet (selon pièce d\'identité)',
                      prefixIcon: Icon(Icons.person_outline_rounded, color: CorviaColors.cyan),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Numéro Mobile (+509 Haïti)',
                      prefixIcon: Icon(Icons.phone_android_rounded, color: CorviaColors.cyan),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Adresse Email',
                    prefixIcon: Icon(Icons.email_outlined, color: CorviaColors.cyan),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: CorviaColors.cyan),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: CorviaColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Mot de passe oublié ?',
                        style: TextStyle(color: CorviaColors.cyan, fontSize: 12),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                // Bouton d'action principal
                ElevatedButton(
                  onPressed: _onProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CorviaColors.cyan,
                    foregroundColor: Colors.black,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(isLogin ? 'Se connecter à mon compte' : 'Créer mon compte CORVIA'),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Bascule rapide sous le formulaire
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => isLogin = !isLogin),
                    child: Text(
                      isLogin
                          ? 'Première visite ? Créer un compte maintenant'
                          : 'Vous possédez déjà un compte ? Connectez-vous',
                      style: const TextStyle(color: CorviaColors.cyan, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Badge de conformité réglementaire
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.shield_outlined, size: 16, color: CorviaColors.lime),
                    SizedBox(width: 6),
                    Text(
                      'Sécurisé par OWASP MASVS & Chiffrement AES-256',
                      style: TextStyle(fontSize: 11, color: CorviaColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 4. ÉCRAN 2FA : VÉRIFICATION OTP À 6 CHIFFRES
// ============================================================================
class TwoFactorScreen extends StatefulWidget {
  final String userIdentifier;
  const TwoFactorScreen({super.key, required this.userIdentifier});

  @override
  State<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _secondsRemaining = 45;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _verifyOtp() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigationShell()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: CorviaColors.lime.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: CorviaColors.lime, width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.verified_user_rounded, color: CorviaColors.lime, size: 32),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Vérification 2FA Sécurisée',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Un code de sécurité à 6 chiffres a été transmis à :\n${widget.userIdentifier}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: CorviaColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 32),

              // 6 cases pour le code OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 46,
                    height: 54,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: CorviaColors.cyan,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: CorviaColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: CorviaColors.border),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (val.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              Center(
                child: Text(
                  _secondsRemaining > 0
                      ? 'Expire dans 00:${_secondsRemaining.toString().padLeft(2, '0')}'
                      : 'Code expiré',
                  style: const TextStyle(color: CorviaColors.textSecondary, fontSize: 13),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CorviaColors.lime,
                  foregroundColor: Colors.black,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : const Text('Valider & Accéder à la Passerelle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 5. NAVIGATION & TABLEAU DE BORD AVEC DÉCONNEXION
// ============================================================================
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    RechargeScreen(),
    KycScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: CorviaColors.surface,
          border: Border(top: BorderSide(color: CorviaColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          selectedItemColor: CorviaColors.cyan,
          unselectedItemColor: CorviaColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Comptes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.swap_horizontal_circle_outlined),
              activeIcon: Icon(Icons.swap_horizontal_circle_rounded),
              label: 'Recharge',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.verified_user_outlined),
              activeIcon: Icon(Icons.verified_user_rounded),
              label: 'KYC',
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
  bool _showHtg = true;
  final NumberFormat _currencyFormat = NumberFormat("#,##0.00", "en_US");

  @override
  Widget build(BuildContext context) {
    final state = MockFintechState.instance;

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: CorviaColors.background,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: CorviaColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: CorviaColors.cyan.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: CorviaColors.cyan, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CORVIA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: CorviaColors.cyan,
                      ),
                    ),
                    Text(
                      state.userName,
                      style: const TextStyle(fontSize: 11, color: CorviaColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: CorviaColors.lime.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: CorviaColors.lime.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: CorviaColors.lime, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      state.kycTier,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CorviaColors.lime),
                    ),
                  ],
                ),
              ),
              // Bouton de déconnexion pour retourner à la page d'accueil
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: CorviaColors.textSecondary, size: 20),
                tooltip: 'Déconnexion (Page d\'accueil)',
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(width: 6),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Carte de Solde
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [CorviaColors.surface, CorviaColors.surfaceElevated],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: CorviaColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Solde Disponible', style: TextStyle(color: CorviaColors.textSecondary, fontSize: 13)),
                          GestureDetector(
                            onTap: () => setState(() => _showHtg = !_showHtg),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: CorviaColors.cyan.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(_showHtg ? 'Voir USD' : 'Voir HTG', style: const TextStyle(color: CorviaColors.cyan, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _showHtg
                            ? '${_currencyFormat.format(state.balanceHtg)} HTG'
                            : '\$ ${_currencyFormat.format(state.balanceUsd)} USD',
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Activité Récente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...state.transactions.map((tx) => ListTile(
                  tileColor: CorviaColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text(tx.destination, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(tx.source, style: const TextStyle(color: CorviaColors.textSecondary, fontSize: 12)),
                  trailing: Text(
                    '+${_currencyFormat.format(tx.amountUsd)} USD',
                    style: const TextStyle(color: CorviaColors.lime, fontWeight: FontWeight.bold),
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Écrans de Recharge et KYC intégrés
class RechargeScreen extends StatelessWidget {
  const RechargeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Module Passerelle Multi-Rails')));
  }
}

class KycScreen extends StatelessWidget {
  const KycScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Module KYC Identity')));
  }
}
