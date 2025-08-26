import 'package:ecommerce_app/controllers/db_service.dart';
import 'package:ecommerce_app/models/products_model.dart';
import 'package:ecommerce_app/widgets/empty_state_widget.dart';
import 'package:ecommerce_app/widgets/modern_loader.dart';
import 'package:ecommerce_app/widgets/modern_text_field.dart';
import 'package:ecommerce_app/constants/discount.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductsModel> _allProducts = [];
  List<ProductsModel> _filteredProducts = [];
  bool _isLoading = true;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadAllProducts();
  }

  void _loadAllProducts() async {
    // Load products from all categories
    final categories = ['electronics', 'clothing', 'books', 'home', 'sports'];
    List<ProductsModel> allProducts = [];
    
    for (String category in categories) {
      try {
        final snapshot = await DbService().readProducts(category).first;
        final products = ProductsModel.fromJsonList(snapshot.docs);
        allProducts.addAll(products);
      } catch (e) {
        print('Error loading products from $category: $e');
      }
    }
    
    setState(() {
      _allProducts = allProducts;
      _isLoading = false;
    });
  }

  void _searchProducts(String query) {
    setState(() {
      _hasSearched = true;
      if (query.isEmpty) {
        _filteredProducts = [];
      } else {
        _filteredProducts = _allProducts
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()) ||
                product.description.toLowerCase().contains(query.toLowerCase()) ||
                product.category.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Search Products",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: ModernTextField(
              controller: _searchController,
              label: "Search",
              hint: "Search for products...",
              prefixIcon: Icons.search,
              onChanged: _searchProducts,
            ),
          ),
          
          // Search Results
          Expanded(
            child: _isLoading
                ? const Center(child: ModernLoader())
                : !_hasSearched
                    ? EmptyStateWidget(
                        icon: Icons.search,
                        title: "Start Searching",
                        subtitle: "Enter a product name, category, or description to find what you're looking for.",
                        iconColor: Colors.blue,
                      )
                    : _filteredProducts.isEmpty
                        ? EmptyStateWidget(
                            icon: Icons.search_off,
                            title: "No Results Found",
                            subtitle: "We couldn't find any products matching '${_searchController.text}'. Try different keywords.",
                            iconColor: Colors.orange,
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    "/view_product",
                                    arguments: product,
                                  );
                                },
                                child: Container(
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
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
                                        const SizedBox(height: 8),
                                        Text(
                                          product.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          product.category.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              "₹${product.old_price}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey.shade600,
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "₹${product.new_price}",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.arrow_downward,
                                              color: Colors.green,
                                              size: 12,
                                            ),
                                            Text(
                                              "${discountPercent(product.old_price, product.new_price)}% OFF",
                                              style: const TextStyle(
                                                fontSize: 12,
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
                          ),
          ),
        ],
      ),
    );
  }
}