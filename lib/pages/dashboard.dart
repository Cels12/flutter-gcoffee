import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gcoffee_r/pages/styles/textstyles.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final TextEditingController search = TextEditingController();
  bool _isMenuOpen = false;
  final String initialValue = 'Filter';
  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background utama
          Container(
            color: Color.fromARGB(255, 247, 247, 247),
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

          // Cards information
          Positioned(
            top: 80,
            left: 110,
            child: Column(
              children: [
                // card untuk penjualan harian
                SizedBox(
                  width: 430,
                  height: 220,
                  child: Card(
                    elevation: 3,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icon di kiri
                          Icon(
                            Icons
                                .trending_up_rounded, // Ganti dengan sesuai kebutuhan
                            size: 120,
                            color: Colors.grey[300], // Warna ikon sesuai gambar
                          ),
                          const SizedBox(
                            width: 20,
                          ), // Spasi antara ikon dan teks
                          // Kolom teks di kanan
                          Expanded(
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 40,
                                ), // Spasi antara teks dan angka
                                const Text(
                                  "Penjualan hari ini",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Oxanium',
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ), // Spasi antara teks dan angka
                                const Text(
                                  "15",
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Oxanium',
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
                SizedBox(height: 10), // Spacing
                // card untuk penjualan bulanan
                SizedBox(
                  width: 430,
                  height: 220,
                  child: Card(
                    elevation: 3,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icon di kiri
                          SvgPicture.asset(
                            'assets/icons/Chart_trendUp.svg',
                            width: 200,
                            height: 200,
                          ),
                          const SizedBox(
                            width: 20,
                          ), // Spasi antara ikon dan teks
                          // Kolom teks di kanan
                          Expanded(
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 40,
                                ), // Spasi antara teks dan angka
                                const Text(
                                  "Penjualan bulan ini",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Oxanium',
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ), // Spasi antara teks dan angka
                                const Text(
                                  "412",
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Oxanium',
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
                SizedBox(height: 10),
                //card untuk jumlah menu
                SizedBox(
                  width: 430,
                  height: 220,
                  child: Card(
                    elevation: 3,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icon di kiri
                          SvgPicture.asset(
                            'assets/icons/Coffee_cup.svg',
                            width: 80,
                            height: 80,
                          ),
                          const SizedBox(
                            width: 20,
                          ), // Spasi antara ikon dan teks
                          // Kolom teks di kanan
                          Expanded(
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 40,
                                ), // Spasi antara teks dan angka
                                const Text(
                                  "Jumlah menu",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Oxanium',
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ), // Spasi antara teks dan angka
                                const Text(
                                  "6",
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Oxanium',
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
              ],
            ),
          ),
          // Teks Laporan,filter, sama button laporan
          Positioned(
            top: 60,
            left: 565,
            child: Column(
              children: [
                Text(
                  'Laporan',
                  style: TextStyle(
                    fontSize: 40,
                    fontFamily: 'Oxanium',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 150,
            left: 565,
            child: Row(
              children: [
                SizedBox(
                  width: 250,
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(40, 217, 217, 217),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      label: Text(
                        'Cari...',
                        style: TextStyle(
                          fontFamily: 'Righteous',
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 250,
                  child: PopupMenuButton<String>(
                    initialValue: initialValue,
                    onSelected: (String value) {
                      debugPrint('Filter Dipilih: $value');
                    },
                    itemBuilder:
                        (BuildContext context) => <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'semua',
                            child: Text('Semua'),
                          ),
                          PopupMenuItem<String>(
                            value: 'dibayar',
                            child: Text('Dibayar'),
                          ),
                          PopupMenuItem<String>(
                            value: 'selesai',
                            child: Text('Selesai'),
                          ),
                        ],
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 12.5,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(40, 217, 217, 217),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Filter',
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Righteous',
                            ),
                          ),
                          SizedBox(width: 140),
                          Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 176),
                TextButton(
                  onPressed: () {
                    debugPrint('Download laporan');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 127, 88, 56),
                    fixedSize: Size(250, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    'Download Laporan',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Oxanium',
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          //table data
          Positioned(
            top: 220,
            left: 565,
            child: Container(
              color: Colors.white,
              child: DataTable(
                sortAscending: true,
                border: TableBorder.all(
                  color: const Color.fromARGB(255, 0, 0, 0), // Garis antar sel
                  width: 1,
                ),
                // Judul dari data table
                columns: [
                  DataColumn(
                    label: Text('ID Pemesanan', style: getDescBlack(context)),
                  ),
                  DataColumn(
                    label: Text('Username', style: getDescBlack(context)),
                  ),
                  DataColumn(
                    label: Text('Pesanan', style: getDescBlack(context)),
                  ),
                  DataColumn(
                    label: Text('Nomor Meja', style: getDescBlack(context)),
                  ),
                  DataColumn(
                    label: Text('Total', style: getDescBlack(context)),
                  ),
                  DataColumn(
                    label: Text(
                      'Status Pemesanan',
                      style: getDescBlack(context),
                    ),
                  ),
                  DataColumn(
                    label: Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: Text('Aksi', style: getDescBlack(context)),
                    ),
                  ),
                ],
                //isi dari table
                rows: [
                  DataRow(
                    cells: [
                      DataCell(Text('P0001', style: getDescBlack(context))),
                      DataCell(
                        Text('UjangGatotkaca', style: getDescBlack(context)),
                      ),
                      DataCell(Text('Cappucino', style: getDescBlack(context))),
                      DataCell(Text('M03', style: getDescBlack(context))),
                      DataCell(
                        Text('Rp. 21,000', style: getDescBlack(context)),
                      ),
                      DataCell(
                        Text('Sedang dibuat', style: getDescBlack(context)),
                      ),
                      DataCell(
                        Row(
                          children: [
                            Text('Dibayar', style: getDescBlack(context)),
                            const SizedBox(height: 10, width: 5),
                            Text('Selesai', style: getDescBlack(context)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('P0002', style: getDescBlack(context))),
                      DataCell(
                        Text('DikaSlebew', style: getDescBlack(context)),
                      ),
                      DataCell(Text('Americano', style: getDescBlack(context))),
                      DataCell(Text('M13', style: getDescBlack(context))),
                      DataCell(
                        Text('Rp. 18,000', style: getDescBlack(context)),
                      ),
                      DataCell(
                        Text('Sedang dibuat', style: getDescBlack(context)),
                      ),
                      DataCell(
                        Row(
                          children: [
                            Text('Dibayar', style: getDescBlack(context)),
                            const SizedBox(height: 10, width: 5),
                            Text('Selesai', style: getDescBlack(context)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('P0003', style: getDescBlack(context))),
                      DataCell(Text('USA911', style: getDescBlack(context))),
                      DataCell(Text('Mochacino', style: getDescBlack(context))),
                      DataCell(Text('M02', style: getDescBlack(context))),
                      DataCell(
                        Text('Rp. 18,000', style: getDescBlack(context)),
                      ),
                      DataCell(
                        Text('Sedang dibuat', style: getDescBlack(context)),
                      ),
                      DataCell(
                        Row(
                          children: [
                            Text('Dibayar', style: getDescBlack(context)),
                            const SizedBox(height: 10, width: 5),
                            Text('Selesai', style: getDescBlack(context)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Sidebar
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
                    Tooltip(
                      message: 'Home',
                      child: TextButton(
                        onPressed: () => debugPrint('Home'),
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
                    Tooltip(
                      message: 'Hellnaw',
                      child: TextButton(
                        onPressed: () => debugPrint('Add menu'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Icon(
                            Icons.add_circle_outline_outlined,
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
          //sidebar
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
          // Area di luar sidebar untuk menutup menu saat diklik
          if (_isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleMenu,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.transparent),
              ),
            ),
        ],
      ),
    );
  }
}
