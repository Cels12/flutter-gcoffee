import 'package:flutter/material.dart';
import 'package:gcoffee_r/controller/auth/auth.dart';
import 'package:gcoffee_r/styles/notification_styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:gcoffee_r/pages/customer/popup_order_type.dart';
import 'package:gcoffee_r/providers/cart_provider.dart';
import 'package:gcoffee_r/routes/route_name.dart';
import 'package:go_router/go_router.dart';
import 'package:gcoffee_r/styles/sidebar.dart';

// ignore: camel_case_types
class homePageCust extends StatefulWidget {
  final String idMeja;
  const homePageCust({super.key, required this.idMeja});

  @override
  State<homePageCust> createState() => _HomePageCustState();
}

// Remove CartProvider class here and continue with _HomePageCustState
class _HomePageCustState extends State<homePageCust> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _menuList = [];
  Map<int, double> _averageRatings = {};
  // ignore: prefer_final_fields
  Map<int, bool> _favoriteStates = {};
  List<Map<String, dynamic>> _filteredMenuList = [];
  final TextEditingController search = TextEditingController();
  bool _isLoading = true;
  bool _isMenuOpen = false;
  bool _isCartOpen = false;

  bool _isProfileOpen = false;
  void _toogleProfile() {
    setState(() {
      _isProfileOpen = !_isProfileOpen;
    });
  }

  void _toggleCart() {
    setState(() {
      _isCartOpen = !_isCartOpen;
    });
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _toggleFavorited(int menuId, Map<String, dynamic> menu) async {
    final authService = AuthService();

    // Redirect to LoginPage if the user is not logged in
    if (!authService.isLoggedIn()) {
      showToast(
        context,
        title: "Perlu Login",
        message: "Kamu harus login dulu!",
        Type: ToastificationType.warning,
      );
      context.goNamed(RouteNames.loginScreen);
      return;
    }

    // Toggle the favorite state in UI immediately for responsiveness
    setState(() {
      _favoriteStates[menuId] = !(_favoriteStates[menuId] ?? false);
    });

    try {
      if (_favoriteStates[menuId] == true) {
        // Add the menu to the favoritemenus table
        await supabase.from('favoritemenus').insert({
          'user_id': supabase.auth.currentUser!.id, // Current user's ID
          'menu_id': menuId, // Menu ID
          'menu_name': menu['nama_menu'], // Menu name
          'menu_price': menu['harga'], // Menu price
          'menu_image': menu['gambar'], // Menu image URL
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Menu added to favorites')));
        }
      } else {
        // Remove the menu from the favoritemenus table
        await supabase
            .from('favoritemenus')
            .delete()
            .eq('user_id', supabase.auth.currentUser!.id)
            .eq('menu_id', menuId);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Menu removed from favorites')),
          );
        }
      }
    } catch (e) {
      // If there's an error, revert the UI change
      if (mounted) {
        setState(() {
          _favoriteStates[menuId] = !(_favoriteStates[menuId] ?? false);
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating favorites: $e')));

        debugPrint('Error updating favoritemenus: $e');
      }
    }
  }

  String formatCurrency(int amount) {
    final format = NumberFormat('#,###', 'id_ID');
    return 'Rp. ${format.format(amount)}';
  }

  Future<void> searchMenu(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredMenuList = _menuList;
      });
      return;
    } else if (!_menuList.any(
      (menu) => menu['nama_menu'].toLowerCase().contains(query.toLowerCase()),
    )) {
      debugPrint('Menu tidak ditemukan');
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [Icon(Icons.error), Text('Menu tidak ditemukan!')],
      );
    }

    setState(() {
      _filteredMenuList =
          _menuList.where((menu) {
            final menuName = menu['nama_menu'].toLowerCase();
            final searchQuery = query.toLowerCase();
            return menuName.contains(searchQuery);
          }).toList();
    });
  }

  Future<void> fetchRatings() async {
    try {
      final response = await supabase.from('review').select('menu_id, rating');

      Map<int, List<int>> ratingsMap = {};

      for (var item in response) {
        int menuId = item['menu_id'];
        int rating = item['rating'];

        if (!ratingsMap.containsKey(menuId)) {
          ratingsMap[menuId] = [];
        }
        ratingsMap[menuId]!.add(rating);
      }
      if (mounted) {
        setState(() {
          _averageRatings = ratingsMap.map((menuId, ratings) {
            double average = ratings.reduce((a, b) => a + b) / ratings.length;
            return MapEntry(menuId, average);
          });
        });
      }
    } catch (e) {
      debugPrint('Error fetching ratings: $e');
    }
  }

  Future<void> fetchMenu() async {
    try {
      final response = await supabase.from('menu').select();
      if (mounted) {
        setState(() {
          _menuList = List<Map<String, dynamic>>.from(response);
          _filteredMenuList = _menuList;
          _isLoading = false;
        });
      }
      await fetchRatings();
    } catch (e) {
      debugPrint('Error fetching menu: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> checkout(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final cartItems = cartProvider.cartItems;
    final totalPrice = cartProvider.getTotalPrice();

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Keranjang kosong!')));
      return;
    }

    try {
      // Ambil current user dari Supabase
      final currentUser = supabase.auth.currentUser;
      String username = 'guest';
      String? userId;

      if (currentUser != null) {
        userId = currentUser.id;

        // Cek apakah user sudah ada di tabel profiles
        try {
          final profileData =
              await supabase
                  .from('profiles')
                  .select('username, email')
                  .eq('id', userId)
                  .single();

          // Jika belum ada, buat profile baru untuk OAuth user
          username = profileData['username'];
        } catch (e) {
          debugPrint('Error getting/creating profile: $e');
          username = currentUser.userMetadata?['full_name'] ?? 'User Google';
        }
      }

      String? orderType;
      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return PopUpOrderType(
              onOrderTypeSelected: (type) {
                orderType = type;
              },
            );
          },
        );
      }

      // Jika user tidak memilih tipe pesanan (menutup dialog), keluar dari fungsi
      if (orderType == null) return;

      // Lanjutkan dengan proses checkout seperti biasa
      final response =
          await supabase
              .from('pesanan')
              .insert({
                'user_id': userId, // Tambahkan user_id ke pesanan
                'username': username,
                'pesanan': cartItems.map((item) => item['name']).join(', '),
                'nomor_meja': widget.idMeja,
                'total': totalPrice,
                'status_pesanan': 'Sedang dibuat',
                'tipe_pesanan': orderType,
              })
              .select('id')
              .single();

      // Get the inserted pesanan ID
      final pesananId = response['id'];

      // Insert each id_menu into the pesanan_menu table
      for (final item in cartItems) {
        await supabase.from('pesanan_menu').insert({
          'id_pesanan': pesananId,
          'id_menu': item['id'],
        });
      }

      // Clear the cart after successful checkout
      cartProvider.clearCart();

      if (context.mounted) {
        showToast(
          context,
          title: 'Pesanan berhasil dibuat!',
          message: 'Silahkan untuk menunggu pesanan',
          Type: ToastificationType.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showToast(
          context,
          title: 'Gagal membuat pesanan',
          message: e.toString(),
          Type: ToastificationType.error,
        );
      }
    }
  }

  Future<void> _loadFavorites() async {
    final authService = AuthService();

    if (authService.isLoggedIn()) {
      try {
        // Fetch all favorites for the current user
        final response = await supabase
            .from('favoritemenus')
            .select('menu_id')
            .eq('user_id', supabase.auth.currentUser!.id);

        // Create a map of menu IDs to favorite status
        if (mounted) {
          setState(() {
            for (var item in response) {
              // Make sure to use the correct type for the menu_id
              int menuId = item['menu_id'];
              _favoriteStates[menuId] = true;
            }
          });
        }
      } catch (e) {
        debugPrint('Error loading favorites: $e');
      }
    }
  }

  void _onSearchChanged() {
    searchMenu(search.text);
  }

  @override
  void initState() {
    super.initState();
    fetchMenu();
    _loadFavorites();
    search.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    search.removeListener(_onSearchChanged);
    search.dispose();
    super.dispose();
  }

  double _getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      // For mobile: make cards take up roughly half the screen width
      return (screenWidth - 40) / 2; // Account for margins and spacing
    } else if (screenWidth < 1200) {
      return (screenWidth - 40) / 2; // For tablets
    } else {
      return 315; // For desktop/large screens
    }
  }

  int _getMaxCardsPerRow(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return 2; // Always show 2 cards per row on mobile
    } else if (screenWidth < 1200) {
      return 2;
    } else {
      return 4;
    }
  }

  List<Widget> _buildCards() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      // Mobile layout - use a more direct approach for 2 columns
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 2, // Reduced spacing for mobile
            runSpacing: 2,
            children:
                _filteredMenuList.map((menu) => _buildCard(menu)).toList(),
          ),
        ),
      ];
    } else {
      // Original implementation for larger screens
      final maxPerRow = _getMaxCardsPerRow(context);
      List<Widget> rows = [];

      for (int i = 0; i < _filteredMenuList.length; i += maxPerRow) {
        List<Widget> rowChildren =
            _filteredMenuList
                .skip(i)
                .take(maxPerRow)
                .map(
                  (menu) => Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: _buildCard(menu),
                  ),
                )
                .toList();

        rows.add(
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 2,
            runSpacing: 2,
            children: rowChildren,
          ),
        );
      }
      return rows;
    }
  }

  Widget _buildCard(Map<String, dynamic> menu) {
    double averageRating = _averageRatings[menu['id']] ?? 0.0;
    int fullStars = averageRating.floor();
    bool hasHalfStar = (averageRating - fullStars) >= 0.5;
    final cardWidth = _getCardWidth(context);
    final imageHeight = cardWidth * 0.7;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SizedBox(
      width: cardWidth,
      child: Card(
        elevation: 3,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 10 : 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: cardWidth - (isMobile ? 16 : 30),
                    height: imageHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        menu['gambar'],
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Icon(
                              Icons.broken_image,
                              size: isMobile ? 40 : 50,
                              color: Colors.grey,
                            ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(77, 51, 51, 51),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () => _toggleFavorited(menu['id'], menu),
                        icon: HeroIcon(
                          HeroIcons.heart,
                          style:
                              (_favoriteStates[menu['id']] ?? false)
                                  ? HeroIconStyle.solid
                                  : HeroIconStyle.outline,
                          size: isMobile ? 16 : 20,
                          color:
                              (_favoriteStates[menu['id']] ?? false)
                                  ? Colors.red
                                  : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < fullStars
                        ? Icons.star
                        : (index == fullStars && hasHalfStar
                            ? Icons.star_half
                            : Icons.star_border),
                    color:
                        index < fullStars || (index == fullStars && hasHalfStar)
                            ? Colors.amber
                            : Colors.grey,
                    size: isMobile ? 16 : 20,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                menu['nama_menu'],
                style: TextStyle(
                  fontFamily: 'Oxanium',
                  fontSize: isMobile ? 24 : 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                menu['deskripsi'],
                style: TextStyle(
                  fontFamily: 'Oxanium',
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 15),
              Text(
                formatCurrency(menu['harga']),
                style: TextStyle(
                  fontFamily: 'Oxanium',
                  fontSize: isMobile ? 24 : 30,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 84, 47, 17),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Provider.of<CartProvider>(
                      context,
                      listen: false,
                    ).addToCart(menu);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: const Color.fromARGB(255, 127, 88, 56),
                    padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
                  ),
                  child: Text(
                    'Pesan',
                    style: TextStyle(
                      fontFamily: 'Oxanium',
                      fontSize: isMobile ? 16 : 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Stack(
          children: [
            // Background
            Container(color: const Color.fromARGB(255, 247, 247, 247)),

            // Fixed GCoffee Text
            Positioned(
              top: 15, // Adjust the vertical position
              left: 50, // Adjust the horizontal position
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.only(left: _isMenuOpen ? 50 : 20),
                child: Text(
                  'GCoffee',
                  style: TextStyle(
                    color: Color.fromARGB(255, 84, 47, 17),
                    fontSize: 32,
                    fontFamily: 'Righteous',
                  ),
                ),
              ),
            ),

            //field cari
            isMobile
                ? Positioned(
                  right: 100,
                  top: 20,
                  child: SizedBox(
                    width: 100,
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.search),
                    ),
                  ),
                )
                : Positioned(
                  right: 100,
                  top: 20,
                  child: SizedBox(
                    width: 300,
                    child: TextField(
                      controller: search,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        labelText: 'Cari menu...',
                        labelStyle: TextStyle(
                          fontFamily: 'Oxanium',
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),

            //profile button
            Positioned(
              right: 30,
              top: 20,
              child: IconButton(
                onPressed: _toogleProfile,
                icon: HeroIcon(HeroIcons.user, size: 40, color: Colors.grey),
              ),
            ),

            // Scrollable Content
            Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left:
                                MediaQuery.of(context).size.width < 600
                                    ? 20
                                    : 100,
                            right: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Varian Kopi',
                                style: TextStyle(
                                  fontFamily: 'Oxanium',
                                  fontSize:
                                      MediaQuery.of(context).size.width < 600
                                          ? 24
                                          : 32,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 127, 88, 56),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ..._buildCards(),
                            ],
                          ),
                        ),
                      ),
            ),

            //profile dropdown menu
            AnimatedPositioned(
              duration: Duration(microseconds: 300),
              top: _isProfileOpen ? 80 : -200,
              right: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 200,
                  height: 100,
                  color: const Color.fromARGB(255, 210, 156, 108),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      supabase.auth.currentUser != null
                          ? Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: TextButton(
                              onPressed: () async {
                                final authService = AuthService();
                                await authService.signOut();
                                if (context.mounted) {
                                  context.goNamed(RouteNames.loginScreen);
                                }
                              },
                              child: Text(
                                'Logout',
                                style: TextStyle(
                                  fontFamily: 'Oxanium',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                          : Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    if (context.mounted) {
                                      context.goNamed(RouteNames.loginScreen);
                                    }
                                  },
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      fontFamily: 'Oxanium',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () async {
                                    if (context.mounted) {
                                      context.goNamed(RouteNames.signUpScreen);
                                    }
                                  },
                                  child: Text(
                                    'Daftar',
                                    style: TextStyle(
                                      fontFamily: 'Oxanium',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),

            //cart
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              top: 0,
              left: _isCartOpen ? 80 : -600,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                child: Container(
                  width: 500,
                  height: MediaQuery.of(context).size.height,
                  color: Color.fromRGBO(255, 255, 255, 1),
                  child: Stack(
                    children: [
                      // Close button in the top-right corner
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _isCartOpen = false;
                            });
                          },
                          icon: Icon(Icons.close, size: 40),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 80.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Text(
                                'Pesananmu',
                                style: TextStyle(
                                  fontFamily: 'Oxanium',
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(
                                    255,
                                    155,
                                    155,
                                    155,
                                  ),
                                ),
                              ),
                            ),
                            //teks list menu di cart
                            Divider(
                              thickness: 1,
                              color: Color.fromARGB(255, 155, 155, 155),
                            ),
                            Expanded(
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: cartProvider.cartItems.length,
                                itemBuilder: (context, index) {
                                  final item = cartProvider.cartItems[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                      vertical: 8.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Item Name
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            item['name'], // Display the name of the item
                                            style: const TextStyle(
                                              fontFamily: 'Oxanium',
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        // Quantity Controls
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Reduce Quantity Button
                                              IconButton(
                                                icon: Icon(
                                                  Icons.remove_circle_outline,
                                                  color:
                                                      item['quantity'] > 1
                                                          ? Colors.red
                                                          : Colors
                                                              .grey, // Grey when disabled
                                                ),
                                                onPressed:
                                                    item['quantity'] > 1
                                                        ? () {
                                                          cartProvider
                                                              .updateQuantity(
                                                                index,
                                                                item['quantity'] -
                                                                    1,
                                                              );
                                                        }
                                                        : null, // Disable the button when quantity <= 1
                                              ),

                                              // Quantity Display
                                              Text(
                                                '${item['quantity']}',
                                                style: const TextStyle(
                                                  fontFamily: 'Oxanium',
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),

                                              // Add Quantity Button
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.add_circle_outline,
                                                ),
                                                color: Colors.green,
                                                onPressed: () {
                                                  cartProvider.updateQuantity(
                                                    index,
                                                    item['quantity'] + 1,
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Item Price
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Rp. ${item['harga'] * item['quantity']}', // Display the total price for the item
                                            style: const TextStyle(
                                              fontFamily: 'Oxanium',
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),

                                        // Remove Item Button
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          color: Colors.red,
                                          onPressed: () {
                                            cartProvider.removeFromCart(index);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (context, index) => const Divider(
                                      thickness: 1,
                                      color: Color.fromARGB(255, 155, 155, 155),
                                    ),
                              ),
                            ),

                            Divider(
                              thickness: 1,
                              color: Color.fromARGB(255, 155, 155, 155),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Sub Total :',
                                    style: TextStyle(
                                      fontFamily: 'Oxanium',
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(
                                        255,
                                        155,
                                        155,
                                        155,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: Text(
                                      'Rp. ${cartProvider.getTotalPrice()}',
                                      style: TextStyle(
                                        fontFamily: 'Oxanium',
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromARGB(
                                          255,
                                          155,
                                          155,
                                          155,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: ElevatedButton(
                                  onPressed: () => checkout(context),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      127,
                                      88,
                                      56,
                                    ),
                                    fixedSize: const Size(300, 40),
                                  ),
                                  child: Text(
                                    'Checkout',
                                    style: TextStyle(
                                      fontFamily: 'Oxanium',
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //sidebar
            buildSidebar(
              context: context,
              isMenuOpen: _isMenuOpen,
              toggleCart: _toggleCart,
              idMeja: widget.idMeja,
            ),
            Positioned(
              top: 12,
              left: 10,
              child: IconButton(
                iconSize: 40,
                color: Color.fromARGB(255, 210, 156, 108),
                onPressed: _toggleMenu,
                icon: Icon(Icons.menu),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
