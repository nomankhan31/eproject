import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../widgets/filter_product_card.dart';

enum ProductSort { newest, priceLowHigh, priceHighLow, highestRating, nameAZ }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedBrand;
  double _minPrice = 0;
  double _maxPrice = 0;
  double _selectedMinRating = 0;
  double _availableMaxPrice = 0;
  bool _isGridView = true;
  bool _filtersExpanded = false;
  ProductSort _sort = ProductSort.newest;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = null;
      _selectedBrand = null;
      _minPrice = 0;
      _maxPrice = _availableMaxPrice;
      _selectedMinRating = 0;
      _sort = ProductSort.newest;
    });
  }

  List<ProductModel> _applyFilters(List<ProductModel> products) {
    final query = _searchQuery.trim().toLowerCase();

    final filtered = products.where((product) {
      final matchesSearch =
          query.isEmpty ||
          product.title.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);

      final matchesCategory =
          _selectedCategory == null || product.category == _selectedCategory;

      final matchesBrand =
          _selectedBrand == null || product.brand == _selectedBrand;

      final matchesPrice =
          product.price >= _minPrice && product.price <= _maxPrice;

      final matchesRating = product.rating >= _selectedMinRating;

      return matchesSearch &&
          matchesCategory &&
          matchesBrand &&
          matchesPrice &&
          matchesRating;
    }).toList();

    switch (_sort) {
      case ProductSort.newest:
        filtered.sort((a, b) {
          final dateA = a.createdAt ?? DateTime(2000);
          final dateB = b.createdAt ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });
        break;

      case ProductSort.priceLowHigh:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;

      case ProductSort.priceHighLow:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;

      case ProductSort.highestRating:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;

      case ProductSort.nameAZ:
        filtered.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
    }

    return filtered;
  }

  String _sortLabel(ProductSort sort) {
    switch (sort) {
      case ProductSort.newest:
        return 'Newest';
      case ProductSort.priceLowHigh:
        return 'Price: Low to High';
      case ProductSort.priceHighLow:
        return 'Price: High to Low';
      case ProductSort.highestRating:
        return 'Highest Rating';
      case ProductSort.nameAZ:
        return 'Name: A to Z';
    }
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() => _searchQuery = value);
      },
      decoration: InputDecoration(
        hintText: 'Search watches, brands...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilterPanel(List<ProductModel> products) {
    final categories =
        products
            .map((p) => p.category.trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    final brands =
        products
            .map((p) => p.brand.trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune),
                const SizedBox(width: 8),
                const Text(
                  'Filters',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear all'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Category
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'All Categories',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Categories'),
                ),
                ...categories.map(
                  (category) =>
                      DropdownMenuItem(value: category, child: Text(category)),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedCategory = value);
              },
            ),

            const SizedBox(height: 16),

            // Brand
            const Text('Brand', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedBrand,
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'All Brands',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Brands'),
                ),
                ...brands.map(
                  (brand) => DropdownMenuItem(value: brand, child: Text(brand)),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedBrand = value);
              },
            ),

            const SizedBox(height: 18),

            // Price range
            Row(
              children: [
                const Text(
                  'Price Range',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  'Rs. ${_minPrice.toStringAsFixed(0)} - '
                  'Rs. ${_maxPrice.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            RangeSlider(
              min: 0,
              max: _availableMaxPrice <= 0 ? 1000 : _availableMaxPrice,
              divisions: _availableMaxPrice > 0 && _availableMaxPrice <= 100000
                  ? 100
                  : null,
              values: RangeValues(
                _minPrice.clamp(
                  0,
                  _availableMaxPrice <= 0 ? 1000 : _availableMaxPrice,
                ),
                _maxPrice.clamp(
                  0,
                  _availableMaxPrice <= 0 ? 1000 : _availableMaxPrice,
                ),
              ),
              onChanged: (values) {
                setState(() {
                  _minPrice = values.start;
                  _maxPrice = values.end;
                });
              },
            ),

            const SizedBox(height: 12),

            // Rating
            const Text(
              'Minimum Rating',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: [0.0, 3.0, 4.0, 4.5].map((rating) {
                final selected = _selectedMinRating == rating;

                return ChoiceChip(
                  label: Text(rating == 0 ? 'All' : '${rating.toString()}+ ★'),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _selectedMinRating = rating;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortAndView(int count) {
    return Row(
      children: [
        Text(
          '$count products',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const Spacer(),

        DropdownButton<ProductSort>(
          value: _sort,
          underline: const SizedBox(),
          icon: const Icon(Icons.sort),
          items: ProductSort.values.map((sort) {
            return DropdownMenuItem(
              value: sort,
              child: Text(
                _sortLabel(sort),
                style: const TextStyle(fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _sort = value);
            }
          },
        ),

        IconButton(
          tooltip: 'Grid view',
          onPressed: () => setState(() => _isGridView = true),
          icon: Icon(
            Icons.grid_view,
            color: _isGridView ? Colors.deepOrange : Colors.grey,
          ),
        ),
        IconButton(
          tooltip: 'List view',
          onPressed: () => setState(() => _isGridView = false),
          icon: Icon(
            Icons.view_list,
            color: !_isGridView ? Colors.deepOrange : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildProducts(List<ProductModel> products) {
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 65, color: Colors.grey),
              const SizedBox(height: 12),
              const Text(
                'No products found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Try changing your search or filters.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _clearFilters,
                child: const Text('Clear Filters'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isGridView) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.66,
        ),
        itemBuilder: (context, index) {
          return FilterProductCard(product: products[index], isGrid: true);
        },
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return FilterProductCard(product: products[index], isGrid: false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Explore Watches',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Clear filters',
            onPressed: _clearFilters,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: StreamBuilder<List<ProductModel>>(
        stream: _productService.getProductsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading products: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allProducts = snapshot.data ?? [];

          if (allProducts.isEmpty) {
            return const Center(child: Text('No products available yet.'));
          }

          // Set the initial price range from Firestore products.
          final highestPrice = allProducts
              .map((p) => p.price)
              .reduce((a, b) => a > b ? a : b);

          if (_availableMaxPrice != highestPrice) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              setState(() {
                final oldMax = _availableMaxPrice;
                _availableMaxPrice = highestPrice;

                if (oldMax == 0) {
                  _maxPrice = highestPrice;
                } else if (_maxPrice > highestPrice) {
                  _maxPrice = highestPrice;
                }
              });
            });
          }

          final filteredProducts = _applyFilters(allProducts);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: _buildSearchBar(),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _filtersExpanded = !_filtersExpanded;
                            });
                          },
                          icon: const Icon(Icons.tune),
                          label: Text(
                            _filtersExpanded ? 'Hide Filters' : 'Show Filters',
                          ),
                        ),
                        const Spacer(),
                        if (_selectedCategory != null ||
                            _selectedBrand != null ||
                            _selectedMinRating > 0)
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text('Clear'),
                          ),
                      ],
                    ),

                    if (_filtersExpanded) _buildFilterPanel(allProducts),

                    _buildSortAndView(filteredProducts.length),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  child: _buildProducts(filteredProducts),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
