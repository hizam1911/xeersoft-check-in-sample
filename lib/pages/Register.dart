import 'package:xeersoft_check_ins/helpers/SqfliteDbHelper.dart';
import 'package:xeersoft_check_ins/services/ToastNotificationService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../enums/UserRole.dart';
import '../models/UserModel.dart';

class Register extends StatefulWidget {
  static const routeName = '/register';
  Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late final dbService;
  final formKey = GlobalKey<FormState>();

  // name, email, pass, confirm pass
  TextEditingController controllerUsername = TextEditingController();
  TextEditingController controllerFullName = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerConfirmPassword = TextEditingController();

  bool isObscurePass = true;
  bool isObscureCPass = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((value) async {
      dbService = context.read<SqfliteDbHelper>();
      // Initialize the database
      final dbHelper = SqfliteDbHelper();
      await dbHelper.database; // Await the database initialization
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                          if (v == null || v.isEmpty) return 'Required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10,),
                      TextFormField(
                        controller: controllerFullName,
                        decoration: InputDecoration(
                          labelText: 'FullName',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controllerPassword,
                              obscureText: isObscurePass,
                              decoration: InputDecoration(
                                labelText: 'Password',
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Required';
                                return null;
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isObscurePass = !isObscurePass;
                              });
                            },
                            icon: Icon(isObscurePass ? Icons.visibility_off : Icons.visibility),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controllerConfirmPassword,
                              obscureText: isObscureCPass,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Required';
                                return null;
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isObscureCPass = !isObscureCPass;
                              });
                            },
                            icon: Icon(isObscureCPass ? Icons.visibility_off : Icons.visibility),
                          ),
                        ],
                      )
                    ],
                  )
              ),
              const SizedBox(height: 20,),
              ElevatedButton(
                onPressed: () async {
                  bool valid = formKey.currentState?.validate() ?? false;
                  if(!valid) return null;
                  if(controllerPassword.text != controllerConfirmPassword.text) {
                    ToastNotificationService.showErrorNotification("Password didnt match!");
                    return null;
                  };
                  final user = UserModel(
                    username: controllerUsername.text,
                    fullname: controllerFullName.text,
                    password: controllerPassword.text,
                    role: UserRole.user,
                  );
                  int userId = await dbService.createUser(user.toMap());
                  if (userId != 0) {
                    ToastNotificationService.showSuccessNotification("User created!");
                  } else {
                    ToastNotificationService.showErrorNotification("Error occured!");
                  }
                  setState(() {
                    controllerUsername.clear();
                    controllerFullName.clear();
                    controllerPassword.clear();
                    controllerConfirmPassword.clear();
                  });
                  Navigator.pushNamed(context, '/');
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
