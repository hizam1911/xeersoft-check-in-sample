import 'package:xeersoft_check_ins/models/CheckInModel.dart';
import 'package:xeersoft_check_ins/models/UserModel.dart';
import 'package:xeersoft_check_ins/services/ToastNotificationService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/UserRole.dart';
import '../helpers/SqfliteDbHelper.dart';
import '../services/SharedPreferencesServices.dart';
import '../utils/DialogUtils.dart';
import 'DatabaseViewer.dart';

class AdminControlPanel extends StatefulWidget {
  static const String routeName = "/dbadmin";
  const AdminControlPanel({super.key});

  @override
  State<AdminControlPanel> createState() => _AdminControlPanelState();
}

class _AdminControlPanelState extends State<AdminControlPanel> {
  late final spService;
  final dbService = SqfliteDbHelper();

  @override
  void initState() {
    spService = context.read<SharedPreferencesService>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await dbService.database;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Console'),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
              ),

              // Add User
              ElevatedButton(
                  onPressed: () async {
                    final user = UserModel(
                      username: "user",
                      fullname: "Ali User",
                      password: "user",
                      role: UserRole.user,
                    );
                    int userId = await dbService.createUser(user.toMap());
                    if (userId > 0) {
                      ToastNotificationService.showSuccessNotification("User created!");
                    } else {
                      if (userId == -1) {
                        ToastNotificationService.showErrorNotification("User exist!");
                      } else {
                        ToastNotificationService.showErrorNotification("Error occured!");
                      }
                    }
                  },
                  child: const Text("Add User")
              ),

              // Add Admin
              ElevatedButton(
                  onPressed: () async {
                    final user = UserModel(
                      username: "admin",
                      fullname: "Ali Admin",
                      password: "admin",
                      role: UserRole.admin,
                    );
                    int userId = await dbService.createUser(user.toMap());
                    if (userId > 0) {
                      print("userId is $userId");
                      ToastNotificationService.showSuccessNotification("Admin created!");
                    } else {
                      if (userId == -1) {
                        ToastNotificationService.showErrorNotification("Admin exist!");
                      } else {
                        ToastNotificationService.showErrorNotification("Error occured!");
                      }
                    }
                  },
                  child: const Text("Add Admin")
              ),

              // Add CheckIn
              ElevatedButton(
                  onPressed: () async {
                    final checkIn = CheckInModel(
                      userId: 1,
                      checkInStatus: true
                    );
                    int checkInId = await dbService.createCheckIn(checkIn.toMap(), checkIn.userId);
                    if (checkInId > 0) {
                      print("checkInId is $checkInId");
                      ToastNotificationService.showSuccessNotification("Check-In created!");
                    } else {
                      if (checkInId == -1) {
                        ToastNotificationService.showErrorNotification("Check-In exist!");
                      } else {
                        ToastNotificationService.showErrorNotification("Error occured!");
                      }
                    }
                  },
                  child: const Text("Add Check-In"),
              ),

              // View Database Listing
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const DatabaseViewer()));
                  },
                  child: const Text("View Database Listing")
              ),

              // Log Out
              ElevatedButton(
                onPressed: () async {
                  bool? ok = await DialogUtils.showDialogPopup(context, "Logout", "Are you sure to logout?");
                  if (ok == null) return;
                  if (!ok) return;
                  if (!context.mounted) return;
                  await SharedPreferencesService(spService.sharedPreferences).clear();
                  if (!context.mounted) return;
                  Navigator.pushReplacementNamed(context, '/login');
                  // Navigator.pushNamedAndRemoveUntil(context, '/login', (Route<dynamic> route) => false);
                },
                child: Text('Log Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
