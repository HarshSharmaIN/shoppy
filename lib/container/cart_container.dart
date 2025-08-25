  import 'package:ecommerce_app/constants/discount.dart';
  import 'package:ecommerce_app/models/cart_model.dart';
  import 'package:ecommerce_app/providers/cart_provider.dart';
  import 'package:ecommerce_app/utils/snackbar_utils.dart';
  import 'package:ecommerce_app/widgets/modern_card.dart';
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  
  class CartContainer extends StatefulWidget {
    final String image, name, productId;
    final int new_price, old_price, maxQuantity, selectedQuantity;
    const CartContainer({
      super.key,
      required this.image,
      required this.name,
      required this.productId,
      required this.new_price,
      required this.old_price,
      required this.maxQuantity,
      required this.selectedQuantity,
    });
  
    @override
    State<CartContainer> createState() => _CartContainerState();
  }
  
  class _CartContainerState extends State<CartContainer> {
    int count = 1;
  
    increaseCount(int max) async {
      if (count >= max) {
        SnackBarUtils.showWarning(context, "Maximum quantity reached");
        return;
      } else {
        Provider.of<CartProvider>(
          context,
          listen: false,
        ).addToCart(CartModel(productId: widget.productId, quantity: count));
        setState(() {
          count++;
        });
      }
    }
  
    decreaseCount() async {
      if (count > 1) {
        Provider.of<CartProvider>(
          context,
          listen: false,
        ).decreaseCount(widget.productId);
        setState(() {
          count--;
        });
      }
    }
  
    @override
    void initState() {
      count = widget.selectedQuantity;
      super.initState();
    }
  
    @override
    Widget build(BuildContext context) {
      return ModernCard(
        margin: const EdgeInsets.only(bottom: 16),
        child: Container(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              "\₹${widget.old_price}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "\₹${widget.new_price}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_downward,
                              color: Colors.green,
                              size: 16,
                            ),
                            Text(
                              "${discountPercent(widget.old_price, widget.new_price)}%",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        Provider.of<CartProvider>(
                          context,
                          listen: false,
                        ).deleteItem(widget.productId);
                        SnackBarUtils.showInfo(context, "Item removed from cart");
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Quantity:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: decreaseCount,
                              icon: const Icon(Icons.remove, size: 18),
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                "$count",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => increaseCount(widget.maxQuantity),
                              icon: const Icon(Icons.add, size: 18),
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Total",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        "₹${widget.new_price * count}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
  
                    ),
                    child: IconButton(
                      onPressed: () async {
                        increaseCount(widget.maxQuantity);
                      },
                      icon: Icon(Icons.add),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "$count",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade300,
                    ),
                    child: IconButton(
                      onPressed: () async {
                        decreaseCount();
                      },
                      icon: Icon(Icons.remove),
                    ),
                  ),
                  SizedBox(width: 8),
                  Spacer(),
                  Text("Total:"),
                  SizedBox(width: 8),
                  Text(
                    "\₹${widget.new_price * count}",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
