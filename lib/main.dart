import 'package:flutter/material.dart';
import 'package:gcoffee_r/providers/cart_provider.dart';
import 'package:gcoffee_r/routes/route_config.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String supabaseUrl = const String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: '',
);
String supabaseKey = const String.fromEnvironment(
  'SUPABASE_KEY',
  defaultValue:
      '',
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
