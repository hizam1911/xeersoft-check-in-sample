import 'package:xeersoft_check_ins/enums/UserRole.dart';
import 'package:xeersoft_check_ins/helpers/SqfliteDbHelper.dart';
import 'package:xeersoft_check_ins/services/ToastNotificationService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/SharedPreferencesServices.dart';

class Login extends StatefulWidget {
  static const String routeName = "/login";

  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();

  TextEditingController controllerUsername = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();

  bool isObscure = true;

  late final spService;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((value) async {
      spService = context.read<SharedPreferencesService>();

      // Initialize the database
      final dbHelper = SqfliteDbHelper();
      await dbHelper.database; // Await the database initialization
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text("Login"),
          ),
          body: Container(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50,),
                  Text("HELLO AND WELCOME!", style: TextStyle(fontWeight: FontWeight.bold),),
                  const SizedBox(height: 10,),
                  Container(
                    child: Image.asset('assets/images/company-logo.png', scale: 1,),
                  ),
                  const SizedBox(height: 10,),
                  Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: controllerUsername,
                            decoration: InputDecoration(
                              labelText: 'Username',
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return "Required";
                              return null;
                            },
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: controllerPassword,
                                  obscureText: isObscure,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return "Required";
                                    return null;
                                  },
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    isObscure = !isObscure;
                                  });
                                },
                                icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                              ),
                            ],
                          )
                        ],
                      )
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          bool valid = formKey.currentState?.validate() ?? false;
                          if (!valid) return null;
                          //login backend here
                          bool isUserExist = await SqfliteDbHelper().login(spService, controllerUsername.text, controllerPassword.text);
                          if (!isUserExist) {
                            ToastNotificationService.showErrorNotification("Username and Password didnt match or user not exist!");
                            return null;
                          };
                          String currentUserRole = SharedPreferencesService(spService.sharedPreferences).getRole();
                          if (currentUserRole == UserRole.admin.name) {
                            Navigator.pushNamed(context, '/dbadmin');
                          } else if (currentUserRole == UserRole.user.name) {
                            Navigator.pushNamed(context, '/home');
                          }
                        },
                        child: Text("Log In"),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text("Register", style: TextStyle(decoration: TextDecoration.underline),),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        )
    );
  }
}
