import 'package:flutter/material.dart';
import 'package:gcoffee_r/styles/notification_styles.dart';
import 'package:gcoffee_r/styles/sidebarADmin.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

class ReviewsAdmin extends StatefulWidget {
  const ReviewsAdmin({super.key});

  @override
  State<ReviewsAdmin> createState() => _ReviewsAdminState();
}

class _ReviewsAdminState extends State<ReviewsAdmin> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic> _reviewUserData = {};
  Map<String, dynamic> _reviewMenuData = {};
  bool _isLoading = true;
  bool _isMenuOpen = false;

  // fungsi fungsi
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

      List<Map<String, dynamic>> processedReviews = [];
      Map<String, dynamic> userData = {};
      Map<String, dynamic> menuData = {};

      for (var item in response) {
        if (item['user_id'] != null) {
          String userId = item['user_id']['id'];
          menuData[userId.toString()] = item['user_id'];
        }
        if (item['menu_id'] != null) {
          String menuId = item['menu_id']['id'];
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
      debugPrint('Error fetching reviews : $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showToast(
          context,
          title: 'Gagal',
          message: "Terjadi kesalahan saat memuat data review",
          Type: ToastificationType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    fontSize:
                        MediaQuery.of(context).size.width < 1200 ? 28 : 32,
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
                                MediaQuery.of(context).size.width < 1200
                                    ? 24
                                    : 32,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 127, 88, 56),
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

            //sidebar
            buildSidebarAdmin(context: context, isMenuOpen: _isMenuOpen),
            //sidebar menu icon
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
                        ).withValues(alpha: 0.2),
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
