import 'package:ecommerce_app/constants/discount.dart';
import 'package:ecommerce_app/models/cart_model.dart';
import 'package:ecommerce_app/models/products_model.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewProduct extends StatefulWidget {
  const ViewProduct({super.key});

  @override
  State<ViewProduct> createState() => _ViewProductState();
}

class _ViewProductState extends State<ViewProduct> {
  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as ProductsModel;
    return Scaffold(
      appBar: AppBar(
        title: Text("Product Details"),
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  arguments.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 80,
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    arguments.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "₹ ${arguments.old_price}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "₹ ${arguments.new_price}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_downward, color: Colors.green, size: 20),
                      Text(
                        "${discountPercent(arguments.old_price, arguments.new_price)} %",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),
                  arguments.maxQuantity == 0
                      ? Text(
                          "Out of Stock",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        )
                      : Text(
                          "Only ${arguments.maxQuantity} left in stock",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                  SizedBox(height: 10),
                  Text(
                    arguments.description,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: arguments.maxQuantity != 0
          ? Row(
              children: [
                SizedBox(
                  height: 60,
                  width: MediaQuery.of(context).size.width * .5,
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<CartProvider>(
                        context,
                        listen: false,
                      ).addToCart(
                        CartModel(productId: arguments.id, quantity: 1),
                      );
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Added to cart")));
                    },
                    child: Text("Add to Cart"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 60,
                  width: MediaQuery.of(context).size.width * .5,
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<CartProvider>(
                        context,
                        listen: false,
                      ).addToCart(
                        CartModel(productId: arguments.id, quantity: 1),
                      );
                      Navigator.pushNamed(context, "/checkout");
                    },
                    child: Text("Buy Now"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(),
                    ),
                  ),
                ),
              ],
            )
          : SizedBox(),
    );
  }
}
