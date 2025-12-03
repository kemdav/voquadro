import 'dart:io';
import 'package:flutter/material.dart';

class InternetCheckWrapper extends StatefulWidget {
  final Widget child;
  const InternetCheckWrapper({super.key, required this.child});

  @override
  State<InternetCheckWrapper> createState() => _InternetCheckWrapperState();
}

class _InternetCheckWrapperState extends State<InternetCheckWrapper> {
  bool _hasInternet = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (mounted) {
          setState(() {
            _hasInternet = true;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasInternet = false;
            _isLoading = false;
          });
        }
      }
    } on SocketException catch (_) {
      if (mounted) {
        setState(() {
          _hasInternet = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasInternet) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              const Text(
                "No Internet Connection",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Please check your connection and try again.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              FilledButton(
                onPressed: _checkConnection,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
