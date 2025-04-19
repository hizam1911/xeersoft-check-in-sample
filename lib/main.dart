import 'package:xeersoft_check_ins/pages/AdminControlPanel.dart';
import 'package:xeersoft_check_ins/pages/CheckInHistory.dart';
import 'package:xeersoft_check_ins/pages/Home.dart';
import 'package:xeersoft_check_ins/pages/Login.dart';
import 'package:xeersoft_check_ins/pages/Register.dart';
import 'package:xeersoft_check_ins/pages/SplashScreen.dart';
import 'package:xeersoft_check_ins/services/SharedPreferencesServices.dart';
import 'package:flutter/material.dart';
import 'package:xeersoft_check_ins/services/ToastNotificationService.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart';

import 'helpers/SqfliteDbHelper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  final dbHelper = SqfliteDbHelper();
  await dbHelper.database; // Await the database initialization

  // Request permissions
  // await requestPermissions();

  // Initialize the shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    String generatedError = details.exceptionAsString();
    print('Flutter Error: $generatedError');
  };

  runApp(MyApp(sharedPreferences: sharedPreferences,));
}

// Future<void> requestPermissions() async {
//   // Notification permission
//   var notificationStatus = await Permission.notification.status;
//   if (notificationStatus.isDenied) {
//     await Permission.notification.request();
//   }
// }

class MyApp extends StatefulWidget {
  final SharedPreferences sharedPreferences;
  const MyApp({super.key, required this.sharedPreferences});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<bool> getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    return isLoggedIn;
  }

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        // ChangeNotifierProvider(
        //   create: (_) => GlobalVariablesProvider(),
        //   child: MyApp(),
        // ),
        Provider<SharedPreferencesService>(
          create: (_) => SharedPreferencesService(widget.sharedPreferences),
        ),
        Provider<SqfliteDbHelper>(
          create: (_) => SqfliteDbHelper(),
        ),
        ChangeNotifierProvider(create: (context) => HomeLoadingState()),
        ChangeNotifierProvider(create: (context) => CheckInHistoryLoadingState()),
      ],
      child: ToastificationWrapper(
        child: MaterialApp(
          builder: (context, child) {
            // specifies whether text flows from left-to-right (TextDirection.ltr, e.g., English) or right-to-left (TextDirection.rtl, e.g., Arabic or Hebrew)
            return Directionality(textDirection: TextDirection.ltr, child: child!);
          },
          navigatorKey: ToastNotificationService().globalNavigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'XeeerSoft',
          routes: {
            SplashScreen.routeName: (_) => const SplashScreen(), // '/'
            AdminControlPanel.routeName: (_) => const AdminControlPanel(), // '/dbadmin'
            Login.routeName: (_) => Login(), // '/login'
            Register.routeName: (_) => Register(), // '/register'
            Home.routeName: (_) => Home(), // '/home'
          },
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true, // Material 3
            typography: Typography.material2021(),
            // textTheme: GoogleFonts.poppinsTextTheme( // Set Poppins as the default font
            //   Theme.of(context).textTheme,
            // ),
          ),
          // home: FutureBuilder(
          //   future: getPrefs(),
          //   builder: (context, snapshot) {
          //     if(snapshot.data == true) {
          //       return Home();
          //     }
          //     return Login();
          //   },
          // ),
        ),
      ),
    );
  }
}
