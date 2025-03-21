import 'package:chatapp/services/bloc/auth_bloc.dart';
import 'package:chatapp/services/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.all(16.0),
          child: const Text(
            'Verify email',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Icon(Icons.email, size: 56)),

              Center(
                child: const Text(
                  'Please verify your email',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              Center(
                child: const Text(
                  'We just sent an email.Click the link in the email to verify your account',
                  softWrap: true,
                  maxLines: 2,
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 10.0,
                      ),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            context.read<AuthBloc>().add(AuthEventSendVerification());
                          },
                          child: const Text('Resend email'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 10.0,
                      ),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthEventLogout());
                          },
                          child: const Text('Login'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )

      ),
    );
  }
}
