import 'package:flutter/material.dart';
import 'package:flutter_app/domain/models/UserData.dart';
import 'package:flutter_app/ui/screens/home_screen.dart';
import 'package:flutter_app/ui/screens/registration_screen.dart';

import '../../data/HelperDB.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 420),
                      child: Card(
                        elevation: 0,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  "Авторизация",
                                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 28),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 15),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: "Почта",
                                  ),
                                  validator: (value) {
                                    final text = (value ?? '');
                                    if (text.isEmpty) {
                                      return 'Введите почту';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: "Пароль",
                                  ),
                                  validator: (value) {
                                    final text = value ?? '';
                                    if (text.isEmpty) {
                                      return 'Введите пароль';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  height: 46,
                                  child: ElevatedButton(
                                    onPressed: authorization,
                                    child: Text("Войти"),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextButton(
                                  onPressed: noAccount,
                                  child: Text(
                                    "Нет аккаунта. Зарегистрироваться",
                                    style: theme.textTheme.labelLarge?.copyWith(fontSize: 14),
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
              ),
            );
          }
        ),
      ),
    );
  }

  void noAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationScreen()),
    );
  }

  Future<void> authorization() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final user = await HelperDB.instance.getUserByEmailAndPassword(
          email: email,
          password: password
      );
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Неверная почта или пароль'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 1),
          )
        );
        return;
      }

      UserData userData = UserData.fromMap(user);
      UserData.setUser(userData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Успешный вход'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        )
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
            (route) => false,
      );
      
    } catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
