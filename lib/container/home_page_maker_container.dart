import 'package:ecommerce_app/container/banner_container.dart';
import 'package:ecommerce_app/container/zone_container.dart';
import 'package:ecommerce_app/controllers/db_service.dart';
import 'package:ecommerce_app/models/categories_model.dart';
import 'package:ecommerce_app/models/promo_banners_model.dart';
import 'package:ecommerce_app/widgets/modern_loader.dart';
import 'package:ecommerce_app/widgets/empty_state_widget.dart';
import 'package:flutter/material.dart';

class HomePageMakerContainer extends StatefulWidget {
  const HomePageMakerContainer({super.key});

  @override
  State<HomePageMakerContainer> createState() => _HomePageMakerContainerState();
}

class _HomePageMakerContainerState extends State<HomePageMakerContainer> {
  int min = 0;

  minCalculator(int a, int b) {
    return min = a > b ? b : a;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DbService().readCategories(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<CategoriesModel> categories =
              CategoriesModel.fromJsonList(snapshot.data!.docs)
                  as List<CategoriesModel>;
          if (categories.isEmpty) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: EmptyStateWidget(
                icon: Icons.inventory_2_outlined,
                title: "No Products Available",
                subtitle: "We're stocking up on amazing products. Come back soon for great deals!",
                iconColor: Colors.orange,
              ),
            );
          } else {
            return StreamBuilder(
              stream: DbService().readBanners(),
              builder: (context, bannerSnapshot) {
                if (bannerSnapshot.hasData) {
                  List<PromoBannersModel> banners =
                      PromoBannersModel.fromJsonList(bannerSnapshot.data!.docs)
                          as List<PromoBannersModel>;
                  
                    return Column(
                      children: [
                        for (
                          int i = 0;
                          i <
                              minCalculator(
                                categories.length,
                                bannerSnapshot.data!.docs.length,
                              );
                          i++
                        )
                          Column(
                            children: [
                              ZoneContainer(
                                category: categories[i].name,
                              ),
                              BannerContainer(
                                image: bannerSnapshot.data!.docs[i]["image"],
                                category:
                                    bannerSnapshot.data!.docs[i]["category"],
                              ),
                            ],
                          ),
                      ],
                    );
                } else {
                  return const Center(child: ModernLoader());
                }
              },
            );
          }
        } else {
          return const Center(child: ModernLoader());
        }
      },
    );
  }
}
