import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommerce_app/controllers/db_service.dart';
import 'package:ecommerce_app/models/promo_banners_model.dart';
import 'package:ecommerce_app/widgets/modern_loader.dart';
import 'package:ecommerce_app/widgets/empty_state_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PromoContainer extends StatefulWidget {
  const PromoContainer({super.key});

  @override
  State<PromoContainer> createState() => _PromoContainerState();
}

class _PromoContainerState extends State<PromoContainer> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DbService().readPromos(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<PromoBannersModel> promos =
              PromoBannersModel.fromJsonList(snapshot.data!.docs)
                  as List<PromoBannersModel>;
          if (promos.isEmpty) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: EmptyStateWidget(
                icon: Icons.campaign_outlined,
                title: "No Promotions Available",
                subtitle: "Check back later for exciting offers and deals!",
                iconColor: Colors.purple,
              ),
            );
          } else {
            return CarouselSlider(
              items: promos
                  .map(
                    (promo) => GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          "/specific",
                          arguments: {"name": promo.category},
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            promo.image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 50,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
              options: CarouselOptions(
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                aspectRatio: 16 / 9,
                viewportFraction: 0.9,
                enlargeCenterPage: true,
                scrollDirection: Axis.horizontal,
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
