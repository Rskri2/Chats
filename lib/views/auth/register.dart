import 'package:chatapp/services/exceptions.dart';
import 'package:chatapp/services/bloc/auth_event.dart';
import 'package:chatapp/services/bloc/auth_state.dart';
import 'package:chatapp/views/dialog/show_error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/bloc/auth_bloc.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _nameController;
  late final GlobalKey<FormState> _formKey;
  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context: context, content: 'Weak password');
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(
              context: context,
              content: 'Email already in use',
            );
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(
              context: context,
              content: 'Email is invalid',
            );
          } else {
            await showErrorDialog(
              context: context,
              content: 'Could not register. Try again',
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: EdgeInsets.all(2.0),
            child: const Text(
              'Register',
              style: TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: Colors.deepPurple,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: Column(
              children: [
                const Text(
                  'Welcome back',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const Text('Create account to continue'),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(2.0),
                        child: TextFormField(
                          controller: _nameController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.person),
                          ),

                          keyboardType: TextInputType.text,
                          autofocus: true,
                          autocorrect: false,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(2.0),
                        child: TextFormField(
                          controller: _emailController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Email address',
                            prefixIcon: Icon(Icons.email),
                          ),

                          keyboardType: TextInputType.emailAddress,
                          autofocus: true,
                          autocorrect: false,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(2.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          controller: _passwordController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: Icon(Icons.visibility_off),
                          ),
                          autocorrect: false,
                          obscureText: true,
                          autofocus: true,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2.0,
                        ),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final email = _emailController.text;
                                final password = _passwordController.text;
                                final name = _nameController.text;
                                context.read<AuthBloc>().add(
                                  AuthEventRegister(
                                    email: email,
                                    password: password,
                                    name: name,
                                  ),
                                );
                              }
                            },
                            child: const Text('Register'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2.0),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthEventLogout());
                      },
                      child: const Text('Already have an account? Login'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}
