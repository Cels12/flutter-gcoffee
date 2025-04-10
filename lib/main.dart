import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gcoffee_r/pages/homepage_responsive.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gcoffee_r/providers/cart_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_KEY']!,
    debug: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Color.fromARGB(255, 210, 156, 100),
          inputDecorationTheme: InputDecorationTheme(
            floatingLabelStyle: TextStyle(
              color: Color.fromARGB(255, 210, 156, 100),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 210, 156, 100)),
            ),
          ),
        ),
        home: Homepage(),
      ),
    );
  }
}
