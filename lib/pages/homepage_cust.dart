import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';

class homePageCust extends StatefulWidget {
  const homePageCust({super.key});

  @override
  State<homePageCust> createState() => _homePageCustState();
}

class _homePageCustState extends State<homePageCust> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _menuList = [];
  bool _isLoading = true;
  bool _isMenuOpen = false;
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

  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background
          Container(
            color: const Color.fromARGB(255, 247, 247, 247),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 50,
                  ),
                  child: Row(
                    children: <Widget>[
                      // Teks GCoffee yang bergeser mengikuti sidebar
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: EdgeInsets.only(
                          left: _isMenuOpen ? 50 : 20,
                        ), // Bergeser
                        child: Text(
                          'GCoffee',
                          style: TextStyle(
                            color: Color.fromARGB(255, 84, 47, 17),
                            fontSize: 32,
                            fontFamily: 'Righteous',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Cards
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 80.0, left: 100),
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
                              builder: (context) => homePageCust(),
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
    return SizedBox(
      width: 315,
      height: 550,
      child: Card(
        elevation: 3,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 15),

              // Rating stars
              Row(
                children: List.generate(
                  5,
                  (index) => const Icon(
                    Icons.star,
                    color: Colors.amberAccent,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 5),

              // Menu name
              Text(
                menu['nama_menu'], // Replace with your menu name field
                style: const TextStyle(
                  fontFamily: 'Oxanium',
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),

              // Menu description
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

              // Price
              Text(
                formatCurrency(
                  menu['harga'],
                ), // Replace with your menu price field
                style: const TextStyle(
                  fontFamily: 'Oxanium',
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 84, 47, 17),
                ),
              ),
              const SizedBox(height: 15),

              // Order button
              ElevatedButton(
                onPressed: () {
                  debugPrint('Order ${menu['nama_menu']}');
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
