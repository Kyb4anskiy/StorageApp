import 'package:flutter/material.dart';
import 'package:flutter_app/domain/models/UserData.dart';
import 'package:flutter_app/ui/screens/home_screen.dart';
import 'package:flutter_app/ui/screens/register_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginController = TextEditingController();
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
                                  controller: _loginController,
                                  decoration: InputDecoration(
                                    labelText: "Логин",
                                  ),
                                  validator: (value) {
                                    final text = (value ?? '');
                                    if (text.isEmpty) {
                                      return 'Введите логин';
                                    }
                                    if (text.contains(' ')) {
                                      return 'Пробелы недопустимы';
                                    }
                                    // if (text.length < 4) {
                                    //   return 'Логин содержит не менее 4 символов';
                                    // }
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
                                    // if (text.length < 6) {
                                    //   return 'Пароль содержит не менее 6 символов';
                                    // }
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
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  void authorization() {
    if (_formKey.currentState?.validate() ?? true) {
        for (var user in users) {
        if (_loginController.text == user.login &&
            _passwordController.text == user.password) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Успешный вход"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
                (route) => false,
          );
          return;
          }
        }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Неверные логин или пароль!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
  }
}
