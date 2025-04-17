// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:gcoffee_r/controller/auth/auth.dart';
import 'package:gcoffee_r/routes/route_name.dart';
import 'package:gcoffee_r/styles/notification_styles.dart';
import 'package:gcoffee_r/styles/sidebar.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:gcoffee_r/pages/customer/popup_order_type.dart';
import 'package:gcoffee_r/providers/cart_provider.dart';

// ignore: camel_case_types
class PageFavorite extends StatefulWidget {
  final String idMeja;
  const PageFavorite({super.key, required this.idMeja});

  @override
  State<PageFavorite> createState() => _PageFavoriteState();
}

// ignore: camel_case_types
class _PageFavoriteState extends State<PageFavorite> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _menuList = [];
  Map<int, double> _averageRatings = {};
  Map<int, bool> _favoriteStates = {};
  List<Map<String, dynamic>> get cartItems => _menuList;
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
          showToast(
            context,
            title: 'Berhasil',
            message: 'Menu di tambahkan ke favorit!',
            Type: ToastificationType.success,
          );
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
          showToast(
            context,
            title: 'Berhasil',
            message: 'Menu dihapus dari favorit!',
            Type: ToastificationType.success,
          );
        }
        await fetchFavorite();
      }
    } catch (e) {
      // If there's an error, revert the UI change
      if (mounted) {
        setState(() {
          _favoriteStates[menuId] = !(_favoriteStates[menuId] ?? false);
        });

        showToast(
          context,
          title: 'Error',
          message: 'Error mengupdate favorit!',
          Type: ToastificationType.error,
        );

        debugPrint('Error updating favoritemenus: $e');
      }
    }
  }

  String formatCurrency(int amount) {
    final format = NumberFormat('#,###', 'id_ID');
    return 'Rp. ${format.format(amount)}';
  }

  Future<void> fetchFavorite() async {
    try {
      final currentUser = supabase.auth.currentUser;

      if (currentUser != null) {
        // Mengambil data menu favorit berdasarkan user yang sedang login
        final response = await supabase
            .from('favoritemenus')
            .select('''
            *,
            menu:menu_id (
              id,
              nama_menu,
              deskripsi,
              harga,
              gambar
            )
          ''')
            .eq('user_id', currentUser.id);

        if (mounted) {
          setState(() {
            // Mengubah format data untuk menyesuaikan dengan struktur yang digunakan di _buildCard
            _menuList = List<Map<String, dynamic>>.from(
              response.map(
                (item) => {
                  'id': item['menu']['id'],
                  'nama_menu': item['menu']['nama_menu'],
                  'deskripsi': item['menu']['deskripsi'],
                  'harga': item['menu']['harga'],
                  'gambar': item['menu']['gambar'],
                },
              ),
            );
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching favorites: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        showToast(
          context,
          title: 'Error',
          message: 'Gagal mengambil data menu favorit: $e',
          Type: ToastificationType.error,
        );
      }
    }
  }

  Future<void> checkout(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final cartItems = cartProvider.cartItems;
    final totalPrice = cartProvider.getTotalPrice();

    if (cartItems.isEmpty) {
      showToast(
        context,
        title: 'Keranjang kosong!',
        message: "Tambahkan item terlebih dahulu ya!",
        Type: ToastificationType.info,
      );
      return;
    }

    // Tampilkan dialog untuk memilih tipe pesanan
    String? orderType;
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

    // Jika user tidak memilih tipe pesanan (menutup dialog), keluar dari fungsi
    if (orderType == null) return;

    try {
      String username = 'guest';
      String? userId;
      final currentUser = supabase.auth.currentUser;

      if (currentUser != null) {
        userId = currentUser.id;
        final profileData =
            await supabase
                .from('profiles')
                .select('username')
                .eq('id', userId)
                .single();

        if (profileData['username'] != null) {
          username = profileData['username'];
        }
      }

      final pesanan = cartItems.map((item) => item['name']).join(', ');

      final response =
          await supabase
              .from('pesanan')
              .insert({
                'username': username,
                'pesanan': pesanan,
                'nomor_meja': widget.idMeja,
                'total': totalPrice,
                'status_pesanan': 'Sedang dibuat',
                'tipe_pesanan':
                    orderType, // Menggunakan tipe pesanan yang dipilih
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
          message: 'user id tidak ditemukan. Error : $e',
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

  @override
  void initState() {
    super.initState();
    fetchFavorite(); // Mengganti fetchMenu() dengan fetchFavorite()
    _loadFavorites();
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
                    fontSize: MediaQuery.of(context).size.width < 600 ? 28 : 32,
                    fontFamily: 'Righteous',
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
                icon: HeroIcon(
                  HeroIcons.user,
                  size: MediaQuery.of(context).size.width < 600 ? 30 : 40,
                  color: Colors.grey,
                ),
              ),
            ),

            // Scrollable Content
            Padding(
              padding: const EdgeInsets.only(
                top: 80.0,
              ), // Add padding to avoid overlap
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
                            right: 15,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Menu Favoritku',
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
                              // Dynamically generate rows of cards
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
                      Padding(
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
              left:
                  isMobile
                      ? (_isCartOpen ? 60 : -600)
                      : (_isCartOpen ? 80 : -600),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                child: Container(
                  width: isMobile ? 450 : 500,
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
                                    padding: const EdgeInsets.only(right: 25.0),
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
                iconSize: MediaQuery.of(context).size.width < 600 ? 28 : 40,
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

  // Tambahkan method untuk menghitung lebar kartu
  double _getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      // Untuk mobile: kartu mengambil sekitar setengah lebar layar
      return (screenWidth - 40) / 2; // Memperhitungkan margin dan spacing
    } else {
      return 315; // Untuk desktop/layar besar
    }
  }

  // Tambahkan method untuk menentukan jumlah kartu per baris
  int _getMaxCardsPerRow(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return 2; // Selalu tampilkan 2 kartu per baris di mobile
    } else {
      return 4;
    }
  }

  // Ubah method _buildCards()
  List<Widget> _buildCards() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      // Layout mobile - gunakan pendekatan yang lebih langsung untuk 2 kolom
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 2, // Spacing yang lebih kecil untuk mobile
            runSpacing: 2,
            children: _menuList.map((menu) => _buildCard(menu)).toList(),
          ),
        ),
      ];
    } else {
      // Implementasi asli untuk layar yang lebih besar
      final maxPerRow = _getMaxCardsPerRow(context);
      List<Widget> rows = [];

      for (int i = 0; i < _menuList.length; i += maxPerRow) {
        List<Widget> rowChildren =
            _menuList
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

  // Ubah method _buildCard()
  Widget _buildCard(Map<String, dynamic> menu) {
    double averageRating = _averageRatings[menu['id']] ?? 0.0;
    int fullStars = averageRating.floor();
    bool hasHalfStar = (averageRating - fullStars) >= 0.5;
    final cardWidth = _getCardWidth(context);
    final imageHeight = cardWidth * 0.9;
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
                        onPressed: () async {
                          _toggleFavorited(menu['id'], menu);
                        },
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
}
