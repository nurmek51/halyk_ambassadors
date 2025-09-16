import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final Dio _dio = Dio();
  String _logs = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dio.options.baseUrl =
        'http://localhost:8000'; // Replace with your API base URL
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  Future<void> _testOtpRequest() async {
    setState(() {
      _isLoading = true;
      _logs = 'Testing OTP request...\n';
    });

    try {
      final response = await _dio.post(
        '/auth/request-otp',
        data: {'phone_number': '+77001234567'},
      );

      setState(() {
        _logs += '✅ Success!\n';
        _logs += 'Status: ${response.statusCode}\n';
        _logs += 'Data: ${response.data}\n';
      });
    } on DioException catch (e) {
      setState(() {
        _logs += '❌ Error!\n';
        _logs += 'Type: ${e.type}\n';
        _logs += 'Status: ${e.response?.statusCode}\n';
        _logs += 'Message: ${e.message}\n';
        _logs += 'Data: ${e.response?.data}\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testOtpRequest,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Test OTP Request'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black87,
                child: SingleChildScrollView(
                  child: Text(
                    _logs,
                    style: const TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
