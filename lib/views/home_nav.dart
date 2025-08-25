import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/providers/user_provider.dart';
import 'package:ecommerce_app/views/cart_page.dart';
import 'package:ecommerce_app/views/home.dart';
import 'package:ecommerce_app/views/orders_page.dart';
import 'package:ecommerce_app/views/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeNav extends StatefulWidget {
  const HomeNav({super.key});

  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
  @override
  void initState() {
    Provider.of<UserProvider>(context, listen: false);
    super.initState();
  }

  int selectedIndex = 0;

  List pages = [HomePage(), OrdersPage(), CartPage(), ProfilePage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 20,
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey.shade400,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                size: 24,
              ),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                selectedIndex == 1 ? Icons.local_shipping : Icons.local_shipping_outlined,
                size: 24,
              ),
            ),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Consumer<CartProvider>(
              builder: (context, value, child) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  child: value.carts.length > 0
                      ? Badge(
                          label: Text(
                            value.carts.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Colors.red.shade500,
                          child: Icon(
                            selectedIndex == 2 ? Icons.shopping_cart : Icons.shopping_cart_outlined,
                            size: 24,
                          ),
                        )
                      : Icon(
                          selectedIndex == 2 ? Icons.shopping_cart : Icons.shopping_cart_outlined,
                          size: 24,
                        ),
                );
              },
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                selectedIndex == 3 ? Icons.person : Icons.person_outline,
                size: 24,
              ),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

                  );
                }
                return Icon(Icons.shopping_cart_outlined);
              },
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
