import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gcoffee_r/auth/auth.dart';
import 'package:gcoffee_r/pages/customer/favoritepage.dart';
import 'package:gcoffee_r/pages/customer/homepage_cust.dart';
import 'package:gcoffee_r/pages/customer/popup_order_type.dart';
import 'package:gcoffee_r/pages/customer/reviews.dart';
import 'package:gcoffee_r/pages/login.dart';
import 'package:gcoffee_r/providers/cart_provider.dart';
import 'package:gcoffee_r/styles/notification_styles.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

// ignore: camel_case_types
class myReviewsPage extends StatefulWidget {
  final String idMeja;
  const myReviewsPage({super.key, required this.idMeja});

  @override
  State<myReviewsPage> createState() => _MyReviewsPageState();
}

// Remove CartProvider class here and continue with _MyReviewsPageState
class _MyReviewsPageState extends State<myReviewsPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _reviewList = [];
  final TextEditingController deskripsiReview = TextEditingController();
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

  Future<void> fetchReviews() async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser != null) {
        // Get username from profiles first
        final userProfile =
            await supabase
                .from('profiles')
                .select('username')
                .eq('id', currentUser.id)
                .single();

        final username = userProfile['username'];
        debugPrint('Current username: $username'); // Debug

        // Get all completed orders for this username
        final orders = await supabase
            .from('pesanan')
            .select('id')
            .eq('username', username)
            .eq('status_pesanan', 'Selesai');

        debugPrint('Orders: $orders'); // Debug

        if (orders.isEmpty) {
          // No completed orders
          if (mounted) {
            setState(() {
              _reviewList = [];
              _isLoading = false;
            });
          }
          return;
        }

        // Extract order IDs
        List<int> orderIds =
            orders.map<int>((order) => order['id'] as int).toList();

        // Get all menu items from these orders using pesanan_menu relationship
        final menuItems = await supabase
            .from('pesanan_menu')
            .select('id_menu')
            .inFilter('id_pesanan', orderIds);

        debugPrint('Menu items from orders: $menuItems'); // Debug

        if (menuItems.isEmpty) {
          // No menu items found
          if (mounted) {
            setState(() {
              _reviewList = [];
              _isLoading = false;
            });
          }
          return;
        }

        // Extract menu IDs
        List<int> menuIds =
            menuItems.map<int>((item) => item['id_menu'] as int).toList();

        // Get detailed menu information
        final menuDetails = await supabase
            .from('menu')
            .select(
              'id, nama_menu, harga, gambar',
            ) // Assuming these are the actual column names
            .inFilter('id', menuIds);

        debugPrint('Menu details: $menuDetails'); // Debug

        // Format for display
        List<Map<String, dynamic>> reviewableMenus =
            menuDetails.map<Map<String, dynamic>>((menu) {
              return {
                'menu_id': menu['id'],
                'menu_name':
                    menu['nama_menu'], // Assuming this is the column name
                'menu_price': menu['harga'],
                'menu_image':
                    menu['gambar'], // Assuming this is the image column
              };
            }).toList();

        // Setelah mendapatkan menu details, ambil review yang sudah ada
        for (var menu in reviewableMenus) {
          final menuId = menu['menu_id'] as int;
          final existingReview =
              await supabase
                  .from('review')
                  .select('rating, review')
                  .eq('menu_id', menuId)
                  .eq('user_id', currentUser.id)
                  .maybeSingle();

          if (existingReview != null) {
            // Set rating yang sudah ada
            _ratings.putIfAbsent(menuId, () => existingReview['rating']);
            // Set text yang sudah ada
            _reviewControllers.putIfAbsent(
              menuId,
              () => TextEditingController(text: existingReview['review']),
            );
          }
        }

        if (mounted) {
          setState(() {
            _reviewList = reviewableMenus;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
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
    final currentUser = supabase.auth.currentUser;

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
      if (currentUser != null) {
        final response =
            await supabase
                .from('pesanan')
                .insert({
                  'user_id': currentUser.id, // Simpan user_id saat checkout
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

        showToast(
          context,
          title: 'Pesanan berhasil dibuat!',
          message: 'Silahkan untuk menunggu pesanan',
          Type: ToastificationType.success,
        );
      }
    } catch (e) {
      showToast(
        context,
        title: 'Gagal membuat pesanan',
        message: 'user id tidak ditemukan. Error : $e',
        Type: ToastificationType.error,
      );
    }
  }

  Future<void> saveReview(int menuId, String reviewText, int rating) async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser != null) {
        // Periksa apakah review sudah ada
        final existingReview =
            await supabase
                .from('review')
                .select()
                .eq('user_id', currentUser.id)
                .eq('menu_id', menuId)
                .maybeSingle();

        if (existingReview != null) {
          // Update review yang sudah ada
          await supabase
              .from('review')
              .update({'review': reviewText, 'rating': rating})
              .eq('id', existingReview['id']);
        } else {
          // Buat review baru
          await supabase.from('review').insert({
            'user_id': currentUser.id,
            'menu_id': menuId,
            'review': deskripsiReview,
            'rating': rating,
          });
        }

        showToast(
          context,
          title: 'Berhasil!',
          message: 'Review berhasil disimpan!',
          Type: ToastificationType.success,
        );

        // Refresh data setelah menyimpan
        fetchReviews();
      }
    } catch (e) {
      showToast(
        context,
        title: 'Gagal!',
        message: 'Error menyimpan review: $e',
        Type: ToastificationType.error,
      );
    }
  }

  Future<void> updateReview(int reviewId, String reviewText, int rating) async {
    try {
      await supabase
          .from('review')
          .update({'review': reviewText, 'rating': rating})
          .eq('id', reviewId);

      showToast(
        context,
        title: 'Berhasil!',
        message: 'Review berhasil diubah!',
        Type: ToastificationType.success,
      );
    } catch (e) {
      showToast(
        context,
        title: 'Gagal!',
        message: 'Error mengubah review: $e',
        Type: ToastificationType.error,
      );
    }
  }

  Future<void> deleteReview(int reviewId) async {
    try {
      await supabase.from('review').delete().eq('id', reviewId);

      showToast(
        context,
        title: 'Berhasil!',
        message: 'Review berhasil dihapus!',
        Type: ToastificationType.success,
      );
    } catch (e) {
      showToast(
        context,
        title: 'Gagal!',
        message: 'Error menghapus review: $e',
        Type: ToastificationType.error,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Map<int, int> _ratings = {}; // Menyimpan rating untuk setiap menu
  Map<int, TextEditingController> _reviewControllers =
      {}; // Menyimpan controller untuk setiap menu

  Widget _buildStarRating(int menuId) {
    // Inisialisasi rating jika belum ada
    _ratings.putIfAbsent(menuId, () => 0);

    return Row(
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            Icons.star,
            color: index < (_ratings[menuId] ?? 0) ? Colors.amber : Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _ratings[menuId] = index + 1;
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    fontSize: 32,
                    fontFamily: 'Righteous',
                  ),
                ),
              ),
            ),

            //profile button
            Positioned(
              //left: 1460,
              right: 30,
              top: 20,
              child: IconButton(
                onPressed: _toogleProfile,
                icon: HeroIcon(HeroIcons.user, size: 40, color: Colors.grey),
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
                          padding: const EdgeInsets.only(left: 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Review',
                                style: const TextStyle(
                                  fontFamily: 'Oxanium',
                                  fontSize: 32,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 127, 88, 56),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Menampilkan cards dalam Column
                              ..._reviewList
                                  .map(
                                    (review) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 20.0,
                                      ),
                                      child: _buildCard(review),
                                    ),
                                  )
                                  .toList(),
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

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Loginpage(),
                              ),
                            );
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
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              top: 0,
              left: _isMenuOpen ? 0 : -200,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                child: Container(
                  width: 80,
                  height: MediaQuery.of(context).size.height,
                  color: Color.fromARGB(255, 84, 47, 17),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      //home
                      Tooltip(
                        message: 'Home',
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        homePageCust(idMeja: widget.idMeja),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: SvgPicture.asset(
                              'assets/icons/home.svg',
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                      ),
                      //show cart
                      Tooltip(
                        message: 'Show Cart',
                        child: TextButton(
                          onPressed: () {
                            _toggleCart();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: HeroIcon(
                              HeroIcons.shoppingCart,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      //Favorit
                      Tooltip(
                        message: 'Favorit',
                        child: TextButton(
                          onPressed: () {
                            final supabase = Supabase.instance.client;
                            if (supabase.auth.currentUser != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          PageFavorite(idMeja: widget.idMeja),
                                ),
                              );
                            } else {
                              showToast(
                                context,
                                title: "Harus Login",
                                message:
                                    'Kamu harus login untuk mengakses favorit!',
                                Type: ToastificationType.warning,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Loginpage(),
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: HeroIcon(
                              HeroIcons.heart,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      //Reviews
                      Tooltip(
                        message: 'Reviews',
                        child: TextButton(
                          onPressed: () {
                            final supabase = Supabase.instance.client;
                            if (supabase.auth.currentUser != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          ReviewsPage(idMeja: widget.idMeja),
                                ),
                              );
                            } else {
                              showToast(
                                context,
                                title: "Harus Login",
                                message:
                                    'Kamu harus login untuk mengakses favorit!',
                                Type: ToastificationType.warning,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Loginpage(),
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Icon(
                              Icons.reviews_outlined,
                              size: 40,
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

  Widget _buildCard(Map<String, dynamic> review) {
    return SizedBox(
      width: 1300,
      child: Card(
        elevation: 3,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child:
                        review['menu_image'] != null &&
                                review['menu_image'].isNotEmpty
                            ? Image.network(
                              review['menu_image'],
                              fit: BoxFit.cover,
                              width: 220,
                              height: 200,
                            )
                            : const Placeholder(
                              fallbackWidth: 220,
                              fallbackHeight: 200,
                            ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    review['menu_name'],
                    style: const TextStyle(
                      fontFamily: 'Oxanium',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    formatCurrency(review['menu_price']),
                    style: const TextStyle(
                      fontFamily: 'Oxanium',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 84, 47, 17),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Beri rating :',
                      style: TextStyle(
                        fontFamily: 'Oxanium',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStarRating(review['menu_id']),
                    const SizedBox(height: 10),
                    Text(
                      'Deskripsikan pengalamanmu :',
                      style: TextStyle(
                        fontFamily: 'Oxanium',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _reviewControllers[review['menu_id']],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Tulis deskripsi review',
                      ),
                    ),
                    const SizedBox(height: 160),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            saveReview(
                              review['menu_id'],
                              _reviewControllers[review['menu_id']]?.text ?? '',
                              _ratings[review['menu_id']] ?? 0,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fixedSize: const Size(120, 40),
                          ),
                          child: const Text(
                            'Simpan',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            updateReview(
                              review['id'],
                              _reviewControllers[review['menu_id']]?.text ?? '',
                              _ratings[review['menu_id']] ?? 0,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fixedSize: const Size(120, 40),
                          ),
                          child: const Text(
                            'Edit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            deleteReview(review['id']);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              249,
                              66,
                              0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fixedSize: const Size(120, 40),
                          ),
                          child: const Text(
                            'Hapus',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Bersihkan semua controller
    for (var controller in _reviewControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
