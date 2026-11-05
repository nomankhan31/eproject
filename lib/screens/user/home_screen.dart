import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:watchhub/screens/customer/profile_screen.dart';
import 'package:watchhub/screens/customer/wishlist_screen.dart';

import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../services/banner_service.dart';
import '../../providers/wishlist_provider.dart';

import '../../widgets/home_header.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/banner_carousel.dart';
import '../../widgets/category_item.dart';
import '../../widgets/product_card.dart';

import 'search_screen.dart';
import '../customer/cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService productService = ProductService();
  final BannerService bannerService = BannerService();

  late final Stream<List<ProductModel>> allProductsStream;
  late final Stream<List<ProductModel>> featuredProductsStream;
  late final Stream<List<ProductModel>> bestSellersStream;

  late final Stream<QuerySnapshot<Map<String, dynamic>>> categoriesStream;

  int selectedIndex = 0;
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();

    allProductsStream = productService.getProducts();
    featuredProductsStream = productService.getFeaturedProducts();
    bestSellersStream = productService.getBestSellers();

    categoriesStream = FirebaseFirestore.instance
        .collection('categories')
        .snapshots();
  }

  void openPage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget sectionTitle(
    String title, {
    String action = 'See All',
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          if (onTap != null)
            TextButton(
              onPressed: onTap,
              child: Text(
                action,
                style: const TextStyle(color: Color(0xFFB8860B)),
              ),
            ),
        ],
      ),
    );
  }

  Widget productSection(Stream<List<ProductModel>> stream) {
    return StreamBuilder<List<ProductModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Unable to load products.');
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text('No products available yet.'),
          );
        }

        return SizedBox(
          height: 255,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return ProductCard(product: products[index]);
            },
          ),
        );
      },
    );
  }

  Widget categoriesSection() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: categoriesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Unable to load categories.');
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const SizedBox(
            height: 105,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        return SizedBox(
          height: 105,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              CategoryItem(
                name: 'All',
                imageUrl: '',
                selected: selectedCategory == 'All',
                onTap: () {
                  setState(() {
                    selectedCategory = 'All';
                  });
                },
              ),
              ...docs.map((doc) {
                final data = doc.data();
                final name = (data['name'] ?? '').toString();

                if (name.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: CategoryItem(
                    name: name,
                    imageUrl: (data['imageUrl'] ?? '').toString(),
                    selected: selectedCategory == name,
                    onTap: () {
                      setState(() {
                        selectedCategory = name;
                      });
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget filteredProducts() {
    return StreamBuilder<List<ProductModel>>(
      stream: allProductsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Unable to load products.');
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allProducts = snapshot.data ?? [];

        final filtered = selectedCategory == 'All'
            ? allProducts
            : allProducts.where((product) {
                return product.category.toLowerCase() ==
                    selectedCategory.toLowerCase();
              }).toList();

        if (filtered.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text('No watches in this category.')),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.66,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            return ProductCard(product: filtered[index]);
          },
        );
      },
    );
  }

  Widget homeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 15, 18, 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: HomeHeader(onCartTap: () => openPage(2))),
                Consumer<WishlistProvider>(
                  builder: (context, wishlist, child) {
                    return IconButton(
                      tooltip: 'My Wishlist',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WishlistScreen(),
                          ),
                        );
                      },
                      icon: Badge(
                        isLabelVisible: wishlist.itemCount > 0,
                        label: Text('${wishlist.itemCount}'),
                        child: const Icon(
                          Icons.favorite_border,
                          color: Colors.red,
                          size: 27,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Find Your Perfect Watch',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text(
              'Discover timeless watches for every moment.',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),

            const SizedBox(height: 20),

            SearchBarWidget(onTap: () => openPage(1)),

            const SizedBox(height: 25),

            StreamBuilder(
              stream: bannerService.getBanners(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const SizedBox.shrink();
                }

                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const SizedBox(
                    height: 175,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return BannerCarousel(banners: snapshot.data ?? []);
              },
            ),

            const SizedBox(height: 28),

            sectionTitle('Shop By Category'),
            categoriesSection(),

            const SizedBox(height: 25),

            sectionTitle('Featured Watches', onTap: () => openPage(1)),
            productSection(featuredProductsStream),

            const SizedBox(height: 25),

            sectionTitle('Best Sellers', onTap: () => openPage(1)),
            productSection(bestSellersStream),

            const SizedBox(height: 25),

            sectionTitle('Explore All Watches'),
            filteredProducts(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPages = [
      homeContent(),
      const SearchScreen(),
      const CartScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: selectedIndex, children: currentPages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: openPage,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFB8860B),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
