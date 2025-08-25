import 'package:ecommerce_app/container/category_container.dart';
import 'package:ecommerce_app/container/discount_container.dart';
import 'package:ecommerce_app/container/home_page_maker_container.dart';
import 'package:ecommerce_app/container/promo_container.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "Discover",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                // Add search functionality
              },
              icon: const Icon(
                Icons.search,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            PromoContainer(),
            const SizedBox(height: 8),
            DiscountContainer(),
            const SizedBox(height: 8),
            CategoryContainer(),
            const SizedBox(height: 8),
            HomePageMakerContainer(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
