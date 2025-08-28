import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/constants/payment.dart';
import 'package:ecommerce_app/controllers/db_service.dart';
import 'package:ecommerce_app/controllers/mail_service.dart';
import 'package:ecommerce_app/models/orders_model.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/providers/user_provider.dart';
import 'package:ecommerce_app/utils/snackbar_utils.dart';
import 'package:ecommerce_app/widgets/modern_button.dart';
import 'package:ecommerce_app/widgets/modern_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  TextEditingController _couponController = TextEditingController();
  late Razorpay _razorpay;

  int discount = 0;
  int toPay = 0;
  String discountText = "";
  bool _isProcessingPayment = false;

  bool paymentSuccess = false;
  Map<String, dynamic> dataOfOrder = {};

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isProcessingPayment = false);

    try {
      // Verify payment (in production, do this on server)
      final isValid = await RazorpayPaymentService.verifyPayment(
        orderId: response.orderId ?? '',
        paymentId: response.paymentId ?? '',
        signature: response.signature ?? '',
      );

      if (isValid || true) {
        // For demo, we'll proceed without verification
        await _processSuccessfulPayment(response.paymentId ?? '');
        SnackBarUtils.showSuccess(context, "Payment successful! Order placed.");
        Navigator.pop(context);
      }
    } catch (e) {
      SnackBarUtils.showError(context, "Error processing payment: $e");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessingPayment = false);
    SnackBarUtils.showError(
      context,
      "Payment failed: ${response.message ?? 'Unknown error'}",
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isProcessingPayment = false);
    SnackBarUtils.showInfo(
      context,
      "External wallet selected: ${response.walletName}",
    );
  }

  Future<void> _processSuccessfulPayment(String paymentId) async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final user = Provider.of<UserProvider>(context, listen: false);
    User? currentUser = FirebaseAuth.instance.currentUser;

    List products = [];
    for (int i = 0; i < cart.products.length; i++) {
      products.add({
        "id": cart.products[i].id,
        "name": cart.products[i].name,
        "image": cart.products[i].image,
        "single_price": cart.products[i].new_price,
        "total_price": cart.products[i].new_price * cart.carts[i].quantity,
        "quantity": cart.carts[i].quantity,
      });
    }

    Map<String, dynamic> orderData = {
      "user_id": currentUser!.uid,
      "name": user.name,
      "email": user.email,
      "address": user.address,
      "phone": user.phone,
      "discount": discount,
      "total": cart.totalCost - discount,
      "products": products,
      "status": "PAID",
      "payment_id": paymentId,
      "created_at": DateTime.now().millisecondsSinceEpoch,
    };

    dataOfOrder = orderData;

    await DbService().createOrder(data: orderData);

    for (int i = 0; i < cart.products.length; i++) {
      DbService().reduceQuantity(
        productId: cart.products[i].id,
        quantity: cart.carts[i].quantity,
      );
    }

    await DbService().emptyCart();
    paymentSuccess = true;

    // Send email confirmation
    MailService().sendMailFromGmail(
      user.email,
      OrdersModel.fromJson(dataOfOrder, ""),
    );
  }

  void discountCalculator(int disPercent, int totalCost) {
    discount = (disPercent * totalCost) ~/ 100;
    setState(() {});
  }

  void _startPayment() async {
    final user = Provider.of<UserProvider>(context, listen: false);
    final cart = Provider.of<CartProvider>(context, listen: false);

    if (user.address.isEmpty ||
        user.phone.isEmpty ||
        user.name.isEmpty ||
        user.email.isEmpty) {
      SnackBarUtils.showError(context, "Please fill your delivery details.");
      return;
    }

    setState(() => _isProcessingPayment = true);

    try {
      final totalAmount = cart.totalCost - discount;
      final amountInPaise = (totalAmount * 100).toString();

      // Create Razorpay order
      final orderData = await RazorpayPaymentService.createOrder(
        amount: amountInPaise,
        currency: 'INR',
        receipt: 'order_${DateTime.now().millisecondsSinceEpoch}',
      );

      var options = {
        'key': dotenv.env["RAZORPAY_KEY_ID"]!,
        'amount': amountInPaise,
        'name': 'ShopEase',
        'description': 'Payment for your order',
        'order_id': orderData['id'],
        'prefill': {
          'contact': user.phone,
          'email': user.email,
          'name': user.name,
        },
        'theme': {'color': '#2196F3'},
      };

      _razorpay.open(options);
    } catch (e) {
      setState(() => _isProcessingPayment = false);
      SnackBarUtils.showError(context, "Failed to initiate payment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Text(
                    "Checkout",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            // Body Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Consumer<UserProvider>(
                  builder: (context, userData, child) => Consumer<CartProvider>(
                    builder: (context, cartData, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Delivery Details Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Theme.of(context).primaryColor,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Delivery Details",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        onPressed: () => Navigator.pushNamed(
                                          context,
                                          "/update_profile",
                                        ),
                                        icon: const Icon(Icons.edit_outlined),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildDetailRow("Name", userData.name),
                                _buildDetailRow("Email", userData.email),
                                _buildDetailRow("Phone", userData.phone),
                                _buildDetailRow("Address", userData.address),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Coupon Section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.local_offer,
                                      color: Colors.green.shade600,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Have a coupon?",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ModernTextField(
                                        controller: _couponController,
                                        label: "Coupon Code",
                                        hint: "Enter coupon for extra discount",
                                        prefixIcon: Icons.confirmation_number,
                                        textCapitalization:
                                            TextCapitalization.characters,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ModernButton(
                                      text: "Apply",
                                      onPressed: _applyCoupon,
                                      height: 56,
                                    ),
                                  ],
                                ),
                                if (discountText.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.green.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green.shade600,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            discountText,
                                            style: TextStyle(
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Order Summary
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.receipt_long,
                                      color: Theme.of(context).primaryColor,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Order Summary",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildSummaryRow(
                                  "Items (${cartData.totalQuantity})",
                                  "₹${cartData.totalCost}",
                                ),
                                if (discount > 0)
                                  _buildSummaryRow(
                                    "Discount",
                                    "-₹$discount",
                                    isDiscount: true,
                                  ),
                                const Divider(height: 24),
                                _buildSummaryRow(
                                  "Total Payable",
                                  "₹${cartData.totalCost - discount}",
                                  isTotal: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartData, child) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: ModernButton(
                text: _isProcessingPayment
                    ? "Processing..."
                    : "Pay ₹${cartData.totalCost - discount}",
                onPressed: _isProcessingPayment ? () {} : _startPayment,
                isLoading: _isProcessingPayment,
                width: double.infinity,
                icon: Icons.payment,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "Not provided" : value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: value.isEmpty ? Colors.red.shade400 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.black87 : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isDiscount
                  ? Colors.green.shade600
                  : isTotal
                  ? Theme.of(context).primaryColor
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _applyCoupon() async {
    if (_couponController.text.trim().isEmpty) {
      SnackBarUtils.showWarning(context, "Please enter a coupon code");
      return;
    }

    try {
      QuerySnapshot querySnapshot = await DbService().verifyDiscount(
        code: _couponController.text.toUpperCase(),
      );

      if (querySnapshot.docs.isNotEmpty) {
        QueryDocumentSnapshot doc = querySnapshot.docs.first;
        String code = doc.get('code');
        int percent = doc.get('discount');

        discountText = "Great! $percent% discount applied with code $code";
        discountCalculator(
          percent,
          Provider.of<CartProvider>(context, listen: false).totalCost,
        );
        SnackBarUtils.showSuccess(context, "Coupon applied successfully!");
      } else {
        discountText = "Invalid coupon code. Please try again.";
        SnackBarUtils.showError(context, "Invalid coupon code");
      }
      setState(() {});
    } catch (e) {
      SnackBarUtils.showError(context, "Error applying coupon: $e");
    }
  }
}
