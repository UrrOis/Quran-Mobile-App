import 'package:flutter/material.dart';
import '../api/auth_api.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _success;

  void _register() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    // Validasi email format
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text;
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+\u0000*');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _isLoading = false;
        _error = 'Format email tidak valid!';
      });
      return;
    }
    if (password.length < 6) {
      setState(() {
        _isLoading = false;
        _error = 'Password minimal 6 karakter!';
      });
      return;
    }
    bool result = await AuthApi().register(name, email, password);
    setState(() {
      _isLoading = false;
    });
    if (result) {
      setState(() {
        _success = 'Registrasi berhasil! Silakan login.';
      });
    } else {
      setState(() {
        _error = 'Email sudah terdaftar!';
      });
    }
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
                        'Register',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 32),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person,
                            color: Color(0xFF7F53AC),
                          ),
                          labelText: 'Nama',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? 'Nama wajib diisi'
                                    : null,
                      ),
                      SizedBox(height: 16),
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
                      if (_success != null) ...[
                        SizedBox(height: 12),
                        Text(
                          _success!,
                          style: TextStyle(
                            color: Colors.green,
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
                                      Icons.app_registration,
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
                                        _register();
                                    },
                                    label: Text(
                                      'Register',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text(
                          'Sudah punya akun? Login',
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
