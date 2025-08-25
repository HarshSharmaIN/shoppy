import 'package:ecommerce_app/constants/discount.dart';
import 'package:ecommerce_app/controllers/db_service.dart';
import 'package:ecommerce_app/models/products_model.dart';
import 'package:ecommerce_app/widgets/empty_state_widget.dart';
import 'package:ecommerce_app/widgets/modern_loader.dart';
import 'package:flutter/material.dart';

class SpecificProducts extends StatefulWidget {
  const SpecificProducts({super.key});

  @override
  State<SpecificProducts> createState() => _SpecificProductsState();
}

class _SpecificProductsState extends State<SpecificProducts> {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
        title: Text(
          "${args["name"].substring(0, 1).toUpperCase()}${args["name"].substring(1)} ",
        ),
      ),
      body: StreamBuilder(
        stream: DbService().readProducts(args["name"]),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<ProductsModel> products =
                ProductsModel.fromJsonList(snapshot.data!.docs)
                    as List<ProductsModel>;
            if (products.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.inventory_2_outlined,
                title: "No Products Available",
                subtitle: "We couldn't find any products in this category. Check back later!",
                iconColor: Colors.orange,
              );
            } else {
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of items per row
                  crossAxisSpacing: 8.0, // Space between items horizontally
                  mainAxisSpacing: 8.0, // Space between items vertically
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "/view_product",
                        arguments: product,
                      );
                    },
                    child: Card(
                      color: Colors.grey.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.image,
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                          size: 40,
                                        ),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Row(
                              children: [
                                SizedBox(width: 2),
                                Text(
                                  "\₹${product.old_price}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "\₹${product.new_price}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(
                                  Icons.arrow_downward,
                                  color: Colors.green,
                                  size: 14,
                                ),
                                Text(
                                  "${discountPercent(product.old_price, product.new_price)}%",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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
