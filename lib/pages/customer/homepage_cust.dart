import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gcoffee_r/auth/auth.dart';
import 'package:gcoffee_r/pages/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ignore: camel_case_types
class homePageCust extends StatefulWidget {
  final String idMeja;
  const homePageCust({Key? key, required this.idMeja});

  @override
  State<homePageCust> createState() => _homePageCustState();
}

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  void addToCart(Map<String, dynamic> item) {
    final existingIndex = _cartItems.indexWhere(
      (cartItem) => cartItem['id'] == item['id'],
    );
    if (existingIndex != -1) {
      // If the item already exists in the cart, increase its quantity
      _cartItems[existingIndex]['quantity'] += 1;
    } else {
      // Add a new item to the cart with an initial quantity of 1
      _cartItems.add({
        'id': item['id'],
        'name': item['nama_menu'],
        'harga': item['harga'],
        'quantity': 1,
      });
    }
    notifyListeners();
  }

  void removeFromCart(int index) {
    _cartItems.removeAt(index);
    notifyListeners();
  }

  void updateQuantity(int index, int newQuantity) {
    _cartItems[index]['quantity'] = newQuantity;
    notifyListeners();
  }

  double getTotalPrice() {
    return _cartItems.fold(
      0,
      (total, item) => total + (item['harga'] * item['quantity']),
    );
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}

// ignore: camel_case_types
class _homePageCustState extends State<homePageCust> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _menuList = [];
  List<Map<String, dynamic>> get cartItems => _menuList;
  bool _isLoading = true;
  bool _isMenuOpen = false;
  bool _isCartOpen = false;

  void _toggleCart() {
    setState(() {
      _isCartOpen = !_isCartOpen;
    });
  }

  Map<String, bool> _favoriteStates = {};
  void _toggleFavorited(String menuId, Map<String, dynamic> menu) async {
    final authService = AuthService();

    if (!authService.isLoggedIn()) {
      // Redirect to LoginPage if the user is not logged in
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Loginpage()),
      );
      return;
    }

    // If the user is logged in, toggle the favorite state
    setState(() {
      _favoriteStates[menuId] = !(_favoriteStates[menuId] ?? false);
    });

    try {
      if (_favoriteStates[menuId] == true) {
        // Add the menu to the favoriteMenus table
        await supabase.from('favoriteMenus').insert({
          'user_id': supabase.auth.currentUser!.id, // Current user's ID
          'menu_id': menuId, // Menu ID
          'menu_name': menu['nama_menu'], // Menu name
          'menu_price': menu['harga'], // Menu price
          'menu_image': menu['gambar'], // Menu image URL
        });
      } else {
        // Remove the menu from the favoriteMenus table
        await supabase
            .from('favoriteMenus')
            .delete()
            .eq('user_id', supabase.auth.currentUser!.id)
            .eq('menu_id', menuId);
      }
    } catch (e) {
      debugPrint('Error updating favoriteMenus: $e');
    }
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

  Future<void> fetchMenu() async {
    try {
      final response = await supabase.from('menu').select();
      if (mounted) {
        setState(() {
          _menuList = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
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
      // Combine all menu names into a single string
      final pesanan = cartItems.map((item) => item['name']).join(', ');

      // Insert the main pesanan row
      final response =
          await supabase
              .from('pesanan')
              .insert({
                'username': 'guest',
                'pesanan': pesanan,
                'nomor_meja': widget.idMeja,
                'total': totalPrice,
                'status_pesanan': 'Sedang dibuat',
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Pesanan berhasil dibuat!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuat pesanan: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMenu();
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
                                'Varian Kopi',
                                style: const TextStyle(
                                  fontFamily: 'Oxanium',
                                  fontSize: 32,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 127, 88, 56),
                                ),
                              ),

                              // Dynamically generate rows of cards
                              ..._buildCards(),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Placeholder(),
                              ),
                            );
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Placeholder(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Icon(
                              Icons.reviews_outlined,
                              size: 40,
                              color: Colors.white,
                              weight: 1,
                            ),
                          ),
                        ),
                      ),
                      //about
                      Tooltip(
                        message: 'About',
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Placeholder(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: HeroIcon(
                              HeroIcons.informationCircle,
                              size: 45,
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

  List<Widget> _buildCards() {
    int maxPerRow = 4;
    List<Widget> rows = [];

    for (
      int kondisiAwal = 0;
      kondisiAwal < _menuList.length;
      kondisiAwal += maxPerRow
    ) {
      List<Widget> rowChildren =
          _menuList
              .skip(kondisiAwal)
              .take(maxPerRow)
              .map(
                (menu) => Padding(
                  padding: const EdgeInsets.only(right: 30.0),
                  child: _buildCard(menu),
                ),
              )
              .toList();
      rows.add(
        Padding(
          padding: const EdgeInsets.only(right: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: rowChildren,
          ),
        ),
      );
    }
    return rows;
  }

  Widget _buildCard(Map<String, dynamic> menu) {
    final menuId = menu['id']; // Unique identifier for the menu item

    return SizedBox(
      width: 315,
      height: 565,
      child: Card(
        elevation: 3,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  // Image
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: 350,
                    height: 280,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        menu['gambar'],
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => const Icon(
                              Icons.broken_image,
                              size: 100,
                              color: Colors.grey,
                            ),
                      ),
                    ),
                  ),

                  // Favorite Button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(77, 51, 51, 51),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () {
                          _toggleFavorited(menuId, menu); // Pass the menu ID
                        },
                        icon: HeroIcon(
                          HeroIcons.heart,
                          style:
                              (_favoriteStates[menuId] ?? false)
                                  ? HeroIconStyle.solid
                                  : HeroIconStyle.outline,
                          size: 20,
                          color:
                              (_favoriteStates[menuId] ?? false)
                                  ? Colors.red
                                  : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Other card content...
              Text(
                menu['nama_menu'], // Replace with your menu name field
                style: const TextStyle(
                  fontFamily: 'Oxanium',
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                menu['deskripsi'], // Replace with your menu description field
                style: const TextStyle(
                  fontFamily: 'Oxanium',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 15),
              Text(
                formatCurrency(menu['harga']),
                style: const TextStyle(
                  fontFamily: 'Oxanium',
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 84, 47, 17),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
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
                  fixedSize: const Size(300, 40),
                ),
                child: const Text(
                  'Pesan',
                  style: TextStyle(
                    fontFamily: 'Oxanium',
                    fontSize: 20,
                    color: Colors.white,
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
