// Halaman login dan registrasi
import 'package:flutter/material.dart';
import '../api/auth_api.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() async {
    final session = await AuthApi().getSession();
    if (session != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    // Validasi email format
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+ *');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _isLoading = false;
        _error = 'Format email tidak valid!';
      });
      return;
    }
    // Cek ke database
    bool result = await AuthApi().login(email, password);
    setState(() {
      _isLoading = false;
    });
    if (result) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _error = 'Email atau password salah!';
      });
    }
  }

  Future<void> _loginWithBiometrics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final canCheck =
          await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
      if (!canCheck) {
        setState(() {
          _isLoading = false;
          _error = 'Perangkat tidak mendukung biometrik.';
        });
        return;
      }
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Gunakan sidik jari/wajah untuk login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (didAuthenticate) {
        // Ambil user terakhir yang login dari SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt('user_id');
        if (userId != null) {
          // Set session dan arahkan ke home
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          setState(() {
            _error = 'Belum ada user yang login sebelumnya.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Autentikasi biometrik gagal.';
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7F53AC), Color(0xFF647DEE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 16),
                      Text(
                        'GoMoslem',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7F53AC),
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 32),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.email,
                            color: Color(0xFF7F53AC),
                          ),
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? 'Email wajib diisi'
                                    : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Color(0xFF7F53AC),
                          ),
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        obscureText: true,
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? 'Password wajib diisi'
                                    : null,
                      ),
                      if (_error != null) ...[
                        SizedBox(height: 12),
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      SizedBox(height: 24),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child:
                            _isLoading
                                ? CircularProgressIndicator()
                                : SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.login,
                                      color: Colors.white,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF7F53AC),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate())
                                        _login();
                                    },
                                    label: Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: Icon(Icons.fingerprint),
                        label: Text('Login dengan Fingerprint'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple[400],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _isLoading ? null : _loginWithBiometrics,
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text(
                          'Belum punya akun? Register',
                          style: TextStyle(
                            color: Color(0xFF7F53AC),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
