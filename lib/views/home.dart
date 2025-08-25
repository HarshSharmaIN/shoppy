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
      appBar: AppBar(
        title: Text(
          "Best Deals",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            PromoContainer(),
            DiscountContainer(),
            CategoryContainer(),

            HomePageMakerContainer(),
          ],
        ),
      ),
    );
  }
}
