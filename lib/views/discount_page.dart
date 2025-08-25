import 'package:ecommerce_app/controllers/db_service.dart';
import 'package:ecommerce_app/models/coupon_model.dart';
import 'package:ecommerce_app/widgets/empty_state_widget.dart';
import 'package:ecommerce_app/widgets/modern_loader.dart';
import 'package:flutter/material.dart';

class DiscountPage extends StatefulWidget {
  const DiscountPage({super.key});

  @override
  State<DiscountPage> createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Discount Coupons",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
      ),
      body: StreamBuilder(
        stream: DbService().readDiscounts(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<CouponModel> discounts =
                CouponModel.fromJsonList(snapshot.data!.docs)
                    as List<CouponModel>;

            if (discounts.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.local_offer_outlined,
                title: "No Coupons Available",
                subtitle: "There are no discount coupons available at the moment. Check back later for great deals!",
                iconColor: Colors.blue,
              );
            } else {
              return ListView.builder(
                itemCount: discounts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.discount_outlined),
                    title: Text(discounts[index].code),
                    subtitle: Text(discounts[index].desc),
                  );
                },
              );
            }
          } else {
            return const Center(child: ModernLoader());
          }
        },
      ),
    );
  }
}
