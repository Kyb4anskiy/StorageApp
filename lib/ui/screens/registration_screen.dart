import 'package:flutter/material.dart';
import 'package:flutter_app/data/HelperDB.dart';
import 'package:flutter_app/domain/models/UserData.dart';
import 'package:flutter_app/ui/screens/auth_screen.dart';
import 'package:sqflite/sqflite.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _loginController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Регистрация',
                                style: theme.textTheme.titleLarge?.copyWith(fontSize: 28),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _loginController,
                                decoration: const InputDecoration(
                                  labelText: 'Логин',
                                ),
                                validator: (value) {
                                  final text = value ?? '';
                                  if (text.isEmpty) {
                                    return 'Введите логин';
                                  }
                                  if (text.contains(' ')) {
                                    return 'Пробелы недопустимы';
                                  }
                                  if (text.length < 4) {
                                    return 'Логин должен быть не менее 4 символов';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Почта',
                                ),
                                validator: (value) {
                                  final text = value ?? '';
                                  if (text.isEmpty) {
                                    return 'Введите почту';
                                  }
                                  final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[\w\.-]+$');
                                  if (!emailRegex.hasMatch(text)) {
                                    return 'Введите корректную почту';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Пароль',
                                ),
                                validator: (value) {
                                  final text = value ?? '';
                                  if (text.isEmpty) {
                                    return 'Введите пароль';
                                  }
                                  if (text.length < 6) {
                                    return 'Пароль должен быть не менее 6 символов';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _confirmController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Повторите пароль',
                                ),
                                validator: (value) {
                                  final text = value ?? '';
                                  if (text.isEmpty) {
                                    return 'Повторите пароль';
                                  }
                                  if (text != _passwordController.text) {
                                    return 'Пароли не совпадают';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: registration,
                                  child: const Text('Зарегистрироваться'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: yesAccount,
                                child: const Text('Уже есть аккаунт. Войти'),
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
          },
        ),
      ),
    );
  }

  void yesAccount() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
  }

  Future<void> registration() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    try {
      if (await HelperDB.instance.isEmailExists(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Пользователь с такой почтой уже существует'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            )
        );
        return;
      }

      final roleId = await HelperDB.instance.getRoleIdByCode('user');
      if (roleId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Что то пошло не так. Попробуйте позже'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            )
        );
        return;
      }

      await HelperDB.instance.insertUser(
        name: _loginController.text.trim(),
        email: email,
        password: _passwordController.text,
        roleId: roleId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Успешная регистрация'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen())
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
      );
    }

  }

  @override
  void dispose() {
    _loginController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}
