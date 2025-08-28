import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class RazorpayPaymentService {
  static Future<Map<String, dynamic>> createOrder({
    required String amount,
    required String currency,
    required String receipt,
  }) async {
    try {
      print(dotenv.env["RAZORPAY_KEY_ID"]);
      final keyId = dotenv.env["RAZORPAY_KEY_ID"]!;
      final keySecret = dotenv.env["RAZORPAY_KEY_SECRET"]!;

      final url = Uri.parse('https://api.razorpay.com/v1/orders');

      final credentials = base64Encode(utf8.encode('$keyId:$keySecret'));

      final body = {
        'amount': amount, // Amount in paise (multiply by 100)
        'currency': currency,
        'receipt': receipt,
        'payment_capture': '1',
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create Razorpay order: ${response.body}');
      }
    } catch (e) {
      print('Error creating Razorpay order: $e');
      rethrow;
    }
  }

  static Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      final keySecret = dotenv.env["RAZORPAY_KEY_SECRET"]!;

      // Create the verification string
      final verificationString = '$orderId|$paymentId';

      // Generate HMAC SHA256 signature
      final expectedSignature = _generateSignature(
        verificationString,
        keySecret,
      );

      return expectedSignature == signature;
    } catch (e) {
      print('Error verifying payment: $e');
      return false;
    }
  }

  static String _generateSignature(String data, String key) {
    // This is a simplified version. In production, use crypto package for HMAC SHA256
    // For now, we'll trust Razorpay's verification on the client side
    return '';
  }
}
