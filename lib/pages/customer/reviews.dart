// ignore_for_file: unused_field, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:gcoffee_r/controller/auth/auth.dart';
import 'package:gcoffee_r/pages/customer/popup_order_type.dart';
import 'package:gcoffee_r/providers/cart_provider.dart';
import 'package:gcoffee_r/routes/route_name.dart';
import 'package:gcoffee_r/styles/notification_styles.dart';
import 'package:gcoffee_r/styles/sidebar.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

// ignore: camel_case_types
class ReviewsPage extends StatefulWidget {
  final String idMeja;
  const ReviewsPage({super.key, required this.idMeja});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

// Remove CartProvider class here and continue with _ReviewsPageState
class _ReviewsPageState extends State<ReviewsPage> {
  final supabase = Supabase.instance.client;
  Map<int, bool> _favoriteStates = {};
  Map<String, dynamic> _reviewUserData = {};
  Map<String, dynamic> _reviewMenuData = {};
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

  String formatCurrency(int amount) {
    final format = NumberFormat('#,###', 'id_ID');
    return 'Rp. ${format.format(amount)}';
  }

  List<Map<String, dynamic>> _reviewsList = [];

  Future<void> fetchAllReviews() async {
    try {
      setState(() {
        _isLoading = true;
      });

      //fetch reviews
      final response = await supabase
          .from('review')
          .select('''
            *,
            user_id (
              id,
              username,
              roles
            ),
            menu_id (
              id,
              nama_menu,
              gambar
            )
          ''')
          .order('created_at', ascending: false);

      //process the review data
      List<Map<String, dynamic>> processedReviews = [];
      Map<String, dynamic> userData = {};
      Map<String, dynamic> menuData = {};

      for (var item in response) {
        if (item['user_id'] != null) {
          String userId = item['user_id']['id'];
          userData[userId] = item['user_id'];
        }

        if (item['menu_id'] != null) {
          int menuId = item['menu_id']['id'];
          menuData[menuId.toString()] = item['menu_id'];
        }
        processedReviews.add(item);
      }
      if (mounted) {
        setState(() {
          _reviewsList = processedReviews;
          _reviewUserData = userData;
          _reviewMenuData = menuData;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching reviews $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showToast(
          context,
          title: 'Gagal memuat alasan',
          message: 'Terjadi kesalahan saat memuat data review',
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
        message: 'Kamu harus punya pesanan dulu!',
        Type: ToastificationType.warning,
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
    fetchAllReviews();
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final cartProvider = Provider.of<CartProvider>(context);

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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reviews',
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
                        ElevatedButton(
                          onPressed: () {
                            context.goNamed(
                              RouteNames.myreview,
                              extra: widget.idMeja,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fixedSize: Size(
                              isMobile ? screenWidth * 0.3 : 150,
                              40,
                            ),
                            backgroundColor: Color.fromARGB(255, 127, 88, 56),
                          ),
                          child: Text(
                            'ReviewKu',
                            style: TextStyle(
                              fontFamily: 'Oxanium',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child:
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 40,
                                  right: 40,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ..._reviewsList.map(
                                      (review) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 20.0,
                                        ),
                                        child: _buildEnhancedReviewCard(review),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                  ),
                ],
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

  Widget _buildEnhancedReviewCard(Map<String, dynamic> review) {
    // Get user data
    final userData = review['user_id'] ?? {};
    final username = userData['username'] ?? 'Anonymous';

    // Get menu data
    final menuData = review['menu_id'] ?? {};
    final menuName = menuData['nama_menu'] ?? 'Menu tidak tersedia';
    final menuImage = menuData['gambar'];

    // Format date
    String formattedDate = '';
    if (review['created_at'] != null) {
      try {
        // Print the raw value for debugging
        debugPrint('Raw created_at value: ${review['created_at']}');

        // Handle different possible formats
        DateTime dateTime;
        if (review['created_at'] is String) {
          dateTime = DateTime.parse(review['created_at']);
        } else if (review['created_at'] is DateTime) {
          dateTime = review['created_at'];
        } else {
          // Try to convert timestamp to DateTime if it's another format
          final timestamp = review['created_at'].toString();
          dateTime = DateTime.parse(timestamp);
        }

        // Make sure locale is imported and available
        formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
      } catch (e) {
        debugPrint('Error formatting date: $e');
        formattedDate = 'Tanggal tidak tersedia';
      }
    }

    return SizedBox(
      child: Card(
        color: Colors.white,
        elevation: 4,
        margin: EdgeInsets.only(bottom: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User profile icon
                  CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 127, 88, 56),
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : 'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  // Username and date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: TextStyle(
                            fontFamily: 'Oxanium',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Menu badge if available
                  if (menuName != 'Menu tidak tersedia')
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(
                          255,
                          210,
                          156,
                          108,
                        ).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color.fromARGB(255, 210, 156, 108),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.coffee,
                            size: 16,
                            color: Color.fromARGB(255, 127, 88, 56),
                          ),
                          SizedBox(width: 5),
                          Text(
                            menuName,
                            style: TextStyle(
                              color: Color.fromARGB(255, 127, 88, 56),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              SizedBox(height: 12),

              // Rating stars
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    color:
                        index < (review['rating'] ?? 0)
                            ? Colors.amber
                            : Colors.grey[300],
                    size: 24,
                  );
                }),
              ),

              SizedBox(height: 12),

              // Review text
              Text(
                review['review'] ?? 'No review text',
                style: TextStyle(
                  fontFamily: 'Oxanium',
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),

              // If there's a menu image, show it
              if (menuImage != null && menuImage.toString().isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        menuImage,
                        height: 200,
                        width: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[400],
                              ),
                            ),
                          );
                        },
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
