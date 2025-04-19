import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:xeersoft_check_ins/pages/CheckInHistory.dart';

import '../helpers/SqfliteDbHelper.dart';
import '../models/CheckInModel.dart';
import '../models/UserModel.dart';
import '../services/SharedPreferencesServices.dart';
import '../services/ToastNotificationService.dart';
import '../utils/DialogUtils.dart';

class Home extends StatefulWidget {
  static const String routeName = "/home";
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final spService;
  UserModel? user;
  int userId = 0;
  int totalDaysThisMonth = 0;
  int totalDaysCheckInThisMonth = 0;
  int totalDaysMissedCheckInThisMonth = 0;
  int totalDaysRemainingCheckInThisMonth = 0;
  String checkedInDateTime = "";
  bool hasCheckInToday = false;

  @override
  void initState() {
    super.initState();
    spService = context.read<SharedPreferencesService>();
    initDashboard();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initDashboard() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getUser(context);
      totalDaysThisMonth = SqfliteDbHelper().getTotalDaysInCurrentMonth();
      if (user?.userId != 0 && user != null) {
        userId = user?.userId ?? 0;
        totalDaysCheckInThisMonth = await SqfliteDbHelper().getTrueCheckInsCountForCurrentMonth(userId);
        totalDaysMissedCheckInThisMonth = await SqfliteDbHelper().getMissedCheckInsCount(userId);
        totalDaysRemainingCheckInThisMonth = await SqfliteDbHelper().getRemainingCheckInsCount(userId);

        final checkInData = await SqfliteDbHelper().getTodayCheckInWithTime(userId);
        if (checkInData != null) {
          hasCheckInToday = checkInData[CheckInModel.columnCheckInStatus] == 1;
          checkedInDateTime = checkInData[CheckInModel.columnCheckInDateTime] as String;
        } else {
          hasCheckInToday = false;
          checkedInDateTime = "";
        }
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> getUser(BuildContext context) async {
    final username = spService.getUsername();
    user = await context.read<SqfliteDbHelper>().getUserByUsername(username);
  }

  String getCheckInStatus() {
    if (hasCheckInToday) {
      return "Checked-In for the day, thank you!";
    } else {
      return "Not Check-In yet for today!";
    }
  }

  String getCheckInTime() {
    if (checkedInDateTime != "") {
      final dateTime = DateTime.parse(checkedInDateTime);
      final formattedTime = DateFormat('HH:mm:ss').format(dateTime);
      return formattedTime;
    } else {
      return "Not Check-In yet for today!";
    }
  }

  List<PieChartSectionData> getSections() {
    final total = totalDaysThisMonth.toDouble();

    // Handle zero division case
    if (total == 0) {
      return [
        PieChartSectionData(
          value: 100, // Full circle but empty
          color: Colors.grey,
          title: 'No Data',
          radius: 60,
          showTitle: true,
        ),
      ];
    }

    return [
      PieChartSectionData(
        value: totalDaysCheckInThisMonth.toDouble(),
        color: Colors.green,
        title: '${(totalDaysCheckInThisMonth / total * 100).toStringAsFixed(1)}%',
        radius: 60,
        showTitle: true,
      ),
      PieChartSectionData(
        value: totalDaysMissedCheckInThisMonth.toDouble(),
        color: Colors.red,
        title: '${(totalDaysMissedCheckInThisMonth / total * 100).toStringAsFixed(1)}%',
        radius: 60,
        showTitle: true,
      ),
      PieChartSectionData(
        value: totalDaysRemainingCheckInThisMonth.toDouble(),
        color: Colors.blue,
        title: '${(totalDaysRemainingCheckInThisMonth / total * 100).toStringAsFixed(1)}%',
        radius: 60,
        showTitle: true,
      ),
    ];
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        SizedBox(width: 4),
        Text(text),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Hello, ${user?.fullname}!"),
          centerTitle: true,
        ),
        body: Container(
          margin: EdgeInsets.all(20),
          child: RefreshIndicator(
            onRefresh: initDashboard,
            child: ListView(
              children: [
                Text(
                  getCheckInStatus(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: hasCheckInToday ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: PieChart(
                    PieChartData(
                      sections: getSections(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegend(Colors.green, 'Checked-In'),
                    SizedBox(width: 16),
                    _buildLegend(Colors.red, 'Missed'),
                    SizedBox(width: 16),
                    _buildLegend(Colors.blue, 'Remaining'),
                  ],
                ),
                SizedBox(height: 40,),
                Text("Check-In Time: ${getCheckInTime()}"),
                Text("Total Days this month: $totalDaysThisMonth"),
                Text("Total Check-In this month: $totalDaysCheckInThisMonth"),
                Text("Total Missed Check-In this month: $totalDaysMissedCheckInThisMonth"),
                Text("Total Remaining Check-In this month: $totalDaysRemainingCheckInThisMonth"),
                SizedBox(height: 40,),
                ElevatedButton(
                    onPressed: hasCheckInToday ? null : () async {
                      final checkIn = CheckInModel(
                          userId: userId,
                          checkInStatus: true
                      );
                      int checkInId = await SqfliteDbHelper().createCheckIn(checkIn.toMap(), userId);
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
                      initDashboard();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasCheckInToday ? Colors.grey : Colors.green,
                      disabledBackgroundColor: Colors.grey,
                      disabledForegroundColor: Colors.white,
                    ),
                    child: Text("Check-In Today!", style: TextStyle(color: hasCheckInToday ? Colors.black : Colors.white,),)
                ),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CheckInHistory(userId: userId)),
                      );
                    },
                    child: Text("View Check-In History")
                ),
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
                    child: Text("Log Out")
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}

class HomeLoadingState with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}