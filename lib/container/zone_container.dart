import 'dart:math';

import 'package:ecommerce_app/constants/discount.dart';
import 'package:ecommerce_app/controllers/db_service.dart';
import 'package:ecommerce_app/models/products_model.dart';
import 'package:ecommerce_app/widgets/modern_loader.dart';
import 'package:flutter/material.dart';

class ZoneContainer extends StatefulWidget {
  final String category;
  const ZoneContainer({super.key, required this.category});

  @override
  State<ZoneContainer> createState() => _ZoneContainerState();
}

class _ZoneContainerState extends State<ZoneContainer> {
  Widget specialQuote({required int price, required int dis}) {
    int random = Random().nextInt(2);

    List<String> quotes = ["Starting at ₹$price", "Get upto $dis% off"];

    return Text(quotes[random], style: TextStyle(color: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DbService().readProducts(widget.category),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<ProductsModel> products =
              ProductsModel.fromJsonList(snapshot.data!.docs)
                  as List<ProductsModel>;
          if (products.isEmpty) {
            return const SizedBox.shrink();
          } else {
            return Container(
              margin: EdgeInsets.all(4),
              padding: EdgeInsets.symmetric(horizontal: 10),
              color: Colors.green.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Text(
                          "${widget.category.substring(0, 1).toUpperCase() + widget.category.substring(1)}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              "/specific",
                              arguments: {"name": widget.category},
                            );
                          },
                          icon: Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),
                  // show max 4 products
                  Wrap(
                    spacing: 4,
                    children: [
                      for (
                        int i = 0;
                        i < (products.length > 4 ? 4 : products.length);
                        i++
                      )
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              "/view_product",
                              arguments: products[i],
                            );
                          },
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * .43,
                            padding: EdgeInsets.all(8),

                            color: Colors.white,
                            height: 180,
                            margin: const EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Image.network(
                                        products[i].image,
                                        height: 100,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey,
                                            size: 40,
                                          );
                                        },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return const CircularProgressIndicator();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  products[i].name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                specialQuote(
                                  price: products[i].new_price,
                                  dis: int.parse(
                                    discountPercent(
                                      products[i].old_price,
                                      products[i].new_price,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }
        } else {
          return const Center(child: ModernLoader());
        }
      },
    );
  }
}