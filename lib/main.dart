import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gcoffee_r/providers/cart_provider.dart';
import 'package:gcoffee_r/routes/route_config.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String supabaseUrl = const String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://nnytkynvgdyodvqwwaaj.supabase.co',
);
String supabaseKey = const String.fromEnvironment(
  'SUPABASE_KEY',
  defaultValue:
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5ueXRreW52Z2R5b2R2cXd3YWFqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzgyMjAwOTEsImV4cCI6MjA1Mzc5NjA5MX0.dWMD219kVXI3imrbWO_qvUJNiH9oxKC-EgR4PEH7s48',
);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
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
      child: MaterialApp.router(
        routerConfig: RouteConfig.returnRouter(),
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
      ),
    );
  }
}
