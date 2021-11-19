import 'package:dart_mysql/dart_mysql.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DNA.dart';
import 'history_item.dart';
import 'item.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // for reporting
  final omumiController = TextEditingController();
  final ekhtesasiController = TextEditingController();
  final khalesController = TextEditingController();
  final sleepController = TextEditingController();
  final schoolController = TextEditingController();

  // for sign in
  final login_phoneController = TextEditingController();
  final login_hashController = TextEditingController();

  // for sign up
  final hashController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  final adminPhoneController = TextEditingController();

  List<Item>? allUsers;
  List<HistoryItem>? histories;

  late SharedPreferences prefs;
  MySqlConnection? conn;

  int userId = 0;
  int avgScore = 0;
  String name = '';
  String date = '';
  String whichDay = 'امروز';
  String historyModeName = '';
  String historyModePhone = '';
  double historyModeAverage = 0;
  int historyModeUserId = 0;
  int historyModePaymentDate = -1;

  bool widgetsEnabled = true;
  bool justSent = false;
  bool adminMode = true;
  bool historyMode = false;
  bool leaderBoardMode = false;
  bool editMode = false;
  bool noUserRanksVisible = true;
  bool firstTime = true;

  bool is1 = false,
      is2 = false,
      is3 = false,
      is4 = false,
      is5 = false,
      is6 = false,
      is7 = false,
      is8 = false,
      is9 = false;

  var settings = new ConnectionSettings(
      host: '158.58.187.220',
      port: 3306,
      user: 'reportadmin',
      password: '3.1415926535Takht',
      timeout: Duration(seconds: 5),
      db: 'adarbase_reportdb');

  Future<int> getUserId() async {
    prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id') ?? 0;
    avgScore = prefs.getInt('avg_score') ?? 0;
    name = prefs.getString('name') ?? '';
    if (name != '')
      name = name + '، دمت گرم!';
    else
      name = 'دمت گرم!';
    return userId;
  }

  late final future = getUserId();

  DNA dna = new DNA();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.grey.shade100,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (adminMode)
          return adminModeWidget();
        else if (justSent)
          return successWidget();
        else {
          if (snapshot.hasData) {
            if (userId != 0) {
              if (DateTime.now().hour < 18) whichDay = 'دیشب';
              date = 'گزارش ' + whichDay;

              if (firstTime) loadIfExists();
              return profileWidget();
            } else
              return signInWidget();
          } else
            return Scaffold(
              backgroundColor: Colors.grey.shade100,
              body: Center(
                child: SizedBox(
                  width: 25.0,
                  height: 25.0,
                  child: CircularProgressIndicator(),
                ),
              ),
            );
        }
      },
    );
  }

  @override
  void dispose() {
    try {
      if (conn != null) conn!.close();
    } finally {
      super.dispose();
    }
  }

  // WIDGETS FOR DIFFERENT MODES

  Widget welcomeWidget() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              children: [],
            ),
          ),
        ),
      ),
    );
  }

  Widget signUpWidget() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 84.0, 0.0, 24.0),
                  child: Text(
                    'ثبت نام در آدار مشاور',
                    style: TextStyle(
                      fontSize: 25.0,
                      color: Colors.lightBlue.shade700,
                      fontFamily: 'IranSansMed',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 24.0),
                  child: Lottie.asset(
                    'assets/anim/welcome.json',
                    animate: true,
                    repeat: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 0.0,
                    child: TextField(
                      enabled: widgetsEnabled,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        LengthLimitingTextInputFormatter(11),
                      ],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "شماره‌ی همراه",
                        border: InputBorder.none,
                        suffixIcon: Icon(
                          Icons.text_fields_outlined,
                          color: Colors.white,
                        ),
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                        ),
                      ),
                      textAlign: TextAlign.center,
                      controller: phoneController,
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 0.0,
                    child: TextField(
                      enabled: widgetsEnabled,
                      decoration: InputDecoration(
                        hintText: "رمز عبور",
                        suffixIcon: Icon(
                          Icons.text_fields_outlined,
                          color: Colors.white,
                        ),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.lock_outline,
                        ),
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.0),
                      controller: hashController,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 0.0,
                    child: TextField(
                      enabled: widgetsEnabled,
                      decoration: InputDecoration(
                        hintText: "نام و نام خانوادگی",
                        suffixIcon: Icon(
                          Icons.text_fields_outlined,
                          color: Colors.white,
                        ),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.text_fields_outlined,
                        ),
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.0),
                      controller: nameController,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 0.0),
                  child: Text(
                    '\u202E' +
                        dna.createAnagram(
                            'برای ثبت نام در آدار مشاور، اطلاعات خود را وارد کنید.'),
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Colors.grey.shade500,
                      fontFamily: 'IranSans',
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 32.0),
                  child: Card(
                    color: widgetsEnabled
                        ? Colors.green.shade700
                        : Colors.grey.shade500,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 0.0,
                    child: AbsorbPointer(
                      absorbing: !widgetsEnabled,
                      child: InkWell(
                          enableFeedback: widgetsEnabled,
                          borderRadius: BorderRadius.circular(20.0),
                          onTap: () {
                            if (phoneController.text.length != 11)
                              Fluttertoast.showToast(
                                  msg: "شماره‌ی همراه واردشده کوتاه است!",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 15.0);
                            else if (phoneController.text.length == 0 ||
                                hashController.text.length == 0 ||
                                nameController.text.length == 0)
                              Fluttertoast.showToast(
                                  msg: "لطفاً تمامی اطلاعات را وارد کنید!",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 15.0);
                            else
                              signIn();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: widgetsEnabled
                                ? Text(
                                    'ثبت نام',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'IranSansMed',
                                      fontSize: 15.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                : Center(
                                    child: SizedBox(
                                        height: 25.0,
                                        width: 25.0,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3.0,
                                          color: Colors.white,
                                        )),
                                  ),
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget signInWidget() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 84.0, 0.0, 24.0),
                      child: Text(
                        'خوش اومدی!',
                        style: TextStyle(
                          fontSize: 25.0,
                          color: Colors.lightBlue.shade700,
                          fontFamily: 'IranSansMed',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 24.0),
                      child: Lottie.asset(
                        'assets/anim/welcome.json',
                        animate: true,
                        repeat: true,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 0.0,
                  child: TextField(
                    enabled: widgetsEnabled,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      LengthLimitingTextInputFormatter(11),
                    ],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "شماره‌ی همراه",
                      border: InputBorder.none,
                      suffixIcon: Icon(
                        Icons.text_fields_outlined,
                        color: Colors.white,
                      ),
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                      ),
                    ),
                    textAlign: TextAlign.center,
                    controller: login_phoneController,
                    style: TextStyle(fontSize: 14.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 0.0,
                  child: TextField(
                    enabled: widgetsEnabled,
                    decoration: InputDecoration(
                      hintText: "رمز عبور",
                      suffixIcon: Icon(
                        Icons.text_fields_outlined,
                        color: Colors.white,
                      ),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.lock_outline,
                      ),
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.0),
                    controller: login_hashController,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 0.0),
                child: Text(
                  '\u202E' +
                      dna.createAnagram(
                          'برای ورود به نرم‌افزار، شماره‌ی همراه و رمز عبور خود را وارد کنید. اگر رمز عبوری ندارید، می‌توانید آن را از مشاور خود دریافت کنید.'),
                  style: TextStyle(
                    fontSize: 13.0,
                    color: Colors.grey.shade500,
                    fontFamily: 'IranSans',
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 32.0),
                child: Card(
                  color: widgetsEnabled
                      ? Colors.green.shade700
                      : Colors.grey.shade500,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 0.0,
                  child: AbsorbPointer(
                    absorbing: !widgetsEnabled,
                    child: InkWell(
                        enableFeedback: widgetsEnabled,
                        borderRadius: BorderRadius.circular(20.0),
                        onTap: () {
                          if (login_phoneController.text.length != 11)
                            Fluttertoast.showToast(
                                msg: "شماره‌ی همراه واردشده کوتاه است!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 15.0);
                          else if (login_phoneController.text.length == 0 ||
                              login_hashController.text.length == 0)
                            Fluttertoast.showToast(
                                msg: "شماره‌ی همراه و رمز عبور را وارد کنید!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 15.0);
                          else if (login_phoneController.text == '9611001079' &&
                              login_hashController.text == '1034') {
                            setState(() {
                              adminMode = true;
                            });
                            setState(() {});
                          } else
                            signIn();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: widgetsEnabled
                              ? Text(
                                  'ورود به نرم‌افزار',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'IranSansMed',
                                    fontSize: 15.0,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : Center(
                                  child: SizedBox(
                                      height: 25.0,
                                      width: 25.0,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3.0,
                                        color: Colors.white,
                                      )),
                                ),
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget profileWidget() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 84.0, 0.0, 0.0),
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 25.0,
                          color: Colors.lightBlue.shade700,
                          fontFamily: 'IranSansMed',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Visibility(
                      visible: avgScore != 0,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 32.0),
                        child: Text(
                          'میانگین تراز: ' + avgScore.toString(),
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Padding(
                      padding: avgScore == 0
                          ? const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 32.0)
                          : const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                      child: Text(
                        date,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                      child: Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 0.0,
                        child: TextField(
                          enabled: widgetsEnabled,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            LengthLimitingTextInputFormatter(4),
                          ],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "تعداد تست‌های اختصاصی",
                            border: InputBorder.none,
                            suffixIcon: Icon(
                              Icons.text_fields_outlined,
                              color: Colors.white,
                            ),
                            prefixIcon: Icon(
                              Icons.check_circle_outline,
                            ),
                          ),
                          textAlign: TextAlign.center,
                          controller: ekhtesasiController,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                      child: Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 0.0,
                        child: TextField(
                          enabled: widgetsEnabled,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            LengthLimitingTextInputFormatter(3),
                          ],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "تعداد تست‌های عمومی",
                            suffixIcon: Icon(
                              Icons.text_fields_outlined,
                              color: Colors.white,
                            ),
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.check_circle_outline,
                            ),
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14.0),
                          controller: omumiController,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 16.0),
                      child: Text(
                        '\u202E' +
                            dna.createAnagram(
                                'مجموع تعداد تست‌های اختصاصی و عمومی خود را به ترتیب در کادرهای بالا وارد کنید.'),
                        style: TextStyle(
                          fontSize: 13.0,
                          color: Colors.grey.shade500,
                          fontFamily: 'IranSans',
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                      child: Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 0.0,
                        child: TextField(
                          enabled: widgetsEnabled,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9\.]')),
                          ],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "زمان خالص مطالعه",
                            border: InputBorder.none,
                            suffixIcon: Icon(
                              Icons.text_fields_outlined,
                              color: Colors.white,
                            ),
                            prefixIcon: Icon(
                              Icons.book_outlined,
                            ),
                          ),
                          textAlign: TextAlign.center,
                          controller: khalesController,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
                      child: Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 0.0,
                        child: TextField(
                          enabled: widgetsEnabled,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9\.]')),
                          ],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "زمان خواب",
                            border: InputBorder.none,
                            suffixIcon: Icon(
                              Icons.text_fields_outlined,
                              color: Colors.white,
                            ),
                            prefixIcon: Icon(
                              Icons.bedroom_child_outlined,
                            ),
                          ),
                          textAlign: TextAlign.center,
                          controller: sleepController,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                      child: Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 0.0,
                        child: TextField(
                          enabled: widgetsEnabled,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9\.]')),
                          ],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "زمان مدرسه و کلاس",
                            suffixIcon: Icon(
                              Icons.text_fields_outlined,
                              color: Colors.white,
                            ),
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.school_outlined,
                            ),
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14.0),
                          controller: schoolController,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 16.0),
                      child: Text(
                        '\u202E' +
                            dna.createAnagram(
                                'زمان خالص یعنی مجموع زمان‌های مطالعاتی امروز که با کرونومتر گرفته شده است؛ در حالی که زمان آزاد به کل زمان‌های روز به جز مواقع خواب و کلاس گفته می‌شود.'),
                        style: TextStyle(
                          fontSize: 13.0,
                          color: Colors.grey.shade500,
                          fontFamily: 'IranSans',
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 32.0),
                child: Card(
                  color: widgetsEnabled
                      ? Colors.green.shade700
                      : Colors.grey.shade500,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 0.0,
                  child: AbsorbPointer(
                    absorbing: !widgetsEnabled,
                    child: InkWell(
                        enableFeedback: widgetsEnabled,
                        borderRadius: BorderRadius.circular(20.0),
                        onTap: () {
                          if (ekhtesasiController.text.length == 0 ||
                              omumiController.text.length == 0 ||
                              khalesController.text.length == 0 ||
                              sleepController.text.length == 0 ||
                              schoolController.text.length == 0)
                            Fluttertoast.showToast(
                                msg: "همه‌ی اعداد را وارد کنید!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 15.0);
                          else if (!dna
                                  .validateNumber(ekhtesasiController.text) ||
                              !dna.validateNumber(omumiController.text) ||
                              !dna.validateNumber(khalesController.text) ||
                              !dna.validateNumber(sleepController.text) ||
                              !dna.validateNumber(schoolController.text) ||
                              double.parse(khalesController.text) > 24 ||
                              double.parse(sleepController.text) > 24 ||
                              double.parse(schoolController.text) > 24 ||
                              double.parse(khalesController.text) +
                                      double.parse(sleepController.text) +
                                      double.parse(schoolController.text) >
                                  24)
                            Fluttertoast.showToast(
                                msg: "اعداد واردشده صحیح نیستند!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 15.0);
                          else
                            addReport();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: widgetsEnabled
                              ? Text(
                                  editMode
                                      ? 'ویرایش اطلاعات $whichDay'
                                      : 'ارسال اطلاعات $whichDay',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'IranSansMed',
                                    fontSize: 15.0,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : Center(
                                  child: SizedBox(
                                      height: 25.0,
                                      width: 25.0,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3.0,
                                        color: Colors.white,
                                      )),
                                ),
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget successWidget() {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 84.0, 0.0, 0.0),
                child: Text(
                  'اطلاعات ارسال شد',
                  style: TextStyle(
                    fontSize: 25.0,
                    color: Colors.green.shade700,
                    fontFamily: 'IranSansMed',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Lottie.asset('assets/anim/sent.json'),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 84.0, 0.0, 0.0),
                child: Text(
                  'منتظر دریافت رتبه‌بندی باشید :)',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey.shade500,
                    fontFamily: 'IranSansMed',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
                child: Card(
                  color: Colors.green.shade700,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 0.0,
                  child: InkWell(
                      enableFeedback: widgetsEnabled,
                      borderRadius: BorderRadius.circular(20.0),
                      onTap: () {
                        SystemChannels.platform
                            .invokeMethod('SystemNavigator.pop');
                      },
                      child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'اتمام و خروج',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'IranSansMed',
                              fontSize: 15.0,
                            ),
                            textAlign: TextAlign.center,
                          ))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget adminModeWidget() {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                    child: Row(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 0.0),
                          child: Text(
                            'امیررضا عشوری',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontFamily: 'IranSansMed',
                            ),
                          ),
                        ),
                        Spacer(),
                        Visibility(
                          visible: leaderBoardMode,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                noUserRanksVisible = !noUserRanksVisible;
                              });
                            },
                            icon: Icon(
                              Icons.hide_source_outlined,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              historyMode = false;
                              leaderBoardMode = false;
                            });
                          },
                          icon: Icon(
                            Icons.restart_alt_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 1.0,
                  color: Colors.grey.shade300,
                ),
                (historyMode || leaderBoardMode)
                    ? Expanded(
                        child: historyMode
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16.0, 32.0, 16.0, 0.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          historyModeName,
                                          style: TextStyle(
                                            color: Colors.lightBlue.shade700,
                                            fontSize: 18.0,
                                            fontFamily: 'IranSansMed',
                                          ),
                                        ),
                                        Text(
                                          ' (میانگین تراز: ' +
                                              historyModeAverage
                                                  .round()
                                                  .toString() +
                                              ')',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18.0,
                                            fontFamily: 'IranSansMed',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0.0, 0.0, 0.0, 32.0),
                                    child: Text(
                                      historyModePaymentDate == 0
                                          ? 'امروز پرداخت کرده'
                                          : historyModePaymentDate.toString() +
                                              ' روز پیش پرداخت کرده',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 15.0,
                                        fontFamily: 'IranSansMed',
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          columns: [
                                            DataColumn(
                                              label: Text('روز'),
                                              numeric: false,
                                            ),
                                            DataColumn(
                                              label: Text('تاریخ'),
                                              numeric: false,
                                            ),
                                            DataColumn(
                                              label: Text('اختصاصی'),
                                              numeric: false,
                                            ),
                                            DataColumn(
                                              label: Text('عمومی'),
                                              numeric: false,
                                            ),
                                            DataColumn(
                                              label: Text('خالص'),
                                              numeric: false,
                                            ),
                                            DataColumn(
                                              label: Text('خواب'),
                                              numeric: false,
                                            ),
                                            DataColumn(
                                              label: Text('مدرسه و کلاس'),
                                              numeric: false,
                                            ),
                                            DataColumn(
                                              label: Text('آزاد'),
                                              numeric: false,
                                            ),
                                            DataColumn(
                                              label: Text('بازده'),
                                              numeric: false,
                                            ),
                                            DataColumn(
                                              label: Text('تراز'),
                                              numeric: false,
                                            ),
                                          ],
                                          rows: histories!
                                              .map(
                                                (history) => DataRow(
                                                  cells: [
                                                    DataCell(
                                                      Text(history.date.weekday
                                                          .toString()
                                                          .replaceAll(
                                                              '1', 'دوشنبه')
                                                          .replaceAll(
                                                              '2', 'سه‌شنبه')
                                                          .replaceAll(
                                                              '3', 'چهارشنبه')
                                                          .replaceAll(
                                                              '4', 'پنج‌شنبه')
                                                          .replaceAll(
                                                              '5', 'جمعه')
                                                          .replaceAll(
                                                              '6', 'شنبه')
                                                          .replaceAll(
                                                              '7', 'یک‌شنبه')),
                                                      onTap: () {
                                                        // write your code..
                                                      },
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        Jalali.fromDateTime(
                                                                    history
                                                                        .date)
                                                                .day
                                                                .toString() +
                                                            ' ' +
                                                            dna.persianMonth(
                                                                Jalali.fromDateTime(
                                                                        history
                                                                            .date)
                                                                    .month) +
                                                            ' ' +
                                                            Jalali.fromDateTime(
                                                                    history
                                                                        .date)
                                                                .year
                                                                .toString(),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(history.ekh
                                                          .toString()),
                                                    ),
                                                    DataCell(
                                                      Text(history.omu
                                                          .toString()),
                                                    ),
                                                    DataCell(
                                                      Text(history.khales
                                                          .toString()),
                                                    ),
                                                    DataCell(
                                                      Text(history.sleep
                                                          .toString()),
                                                    ),
                                                    DataCell(
                                                      Text(history.school
                                                          .toString()),
                                                    ),
                                                    DataCell(
                                                      Text((24 -
                                                              history.sleep -
                                                              history.school)
                                                          .toString()),
                                                    ),
                                                    DataCell(
                                                      Text(history.bazdeh
                                                          .toString()),
                                                    ),
                                                    DataCell(
                                                      Text(history.score
                                                          .toString()),
                                                    ),
                                                  ],
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16.0, 16.0, 16.0, 32.0),
                                    child: Card(
                                      color: Colors.green.shade700,
                                      margin: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      elevation: 0.0,
                                      child: InkWell(
                                          enableFeedback: widgetsEnabled,
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          onTap: () {
                                            setPaidToday();
                                          },
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Text(
                                                'ثبت پرداخت نقدی',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'IranSansMed',
                                                  fontSize: 15.0,
                                                ),
                                                textAlign: TextAlign.center,
                                              ))),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding:
                                    EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                                itemCount:
                                    allUsers == null ? 0 : allUsers!.length,
                                itemBuilder: (context, i) {
                                  return Visibility(
                                    visible: allUsers!.elementAt(i).id == 0
                                        ? noUserRanksVisible
                                        : true,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Visibility(
                                          visible: (i == 0 ||
                                                  allUsers!
                                                          .elementAt(i - 1)
                                                          .group !=
                                                      allUsers!
                                                          .elementAt(i)
                                                          .group)
                                              ? true
                                              : false,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0.0, 8.0, 0.0, 0.0),
                                                child: Text(
                                                  allUsers!
                                                      .elementAt(i)
                                                      .group
                                                      .substring(
                                                          0,
                                                          allUsers!
                                                              .elementAt(i)
                                                              .group
                                                              .indexOf('|')),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily: 'IranSansMed',
                                                    fontSize: 16.0,
                                                    color: Colors
                                                        .lightBlue.shade700,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0.0, 0.0, 0.0, 4.0),
                                                child: Text(
                                                  allUsers!
                                                      .elementAt(i)
                                                      .group
                                                      .substring(allUsers!
                                                              .elementAt(i)
                                                              .group
                                                              .indexOf('|') +
                                                          1),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 13.0,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        allUsers!.elementAt(i).id == 0
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        16.0, 4.0, 16.0, 4.0),
                                                child: Card(
                                                    color: Colors.grey.shade300,
                                                    margin: EdgeInsets.zero,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                    ),
                                                    elevation: 0.0,
                                                    child: Center(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          'دانش‌آموزی در این گروه وجود ندارد',
                                                          style: TextStyle(
                                                            fontSize: 13.0,
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                              )
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        16.0, 4.0, 16.0, 4.0),
                                                child: Card(
                                                  margin: EdgeInsets.zero,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ),
                                                  elevation: 0.0,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        0.0, 12.0, 12.0, 12.0),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          height: 32.0,
                                                          width: 32.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .lightBlue
                                                                .shade700,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              allUsers!
                                                                  .elementAt(i)
                                                                  .id
                                                                  .toString(),
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        0.0,
                                                                        0.0,
                                                                        8.0,
                                                                        0.0),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      allUsers!
                                                                          .elementAt(
                                                                              i)
                                                                          .name,
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'IranSansMed',
                                                                        fontSize:
                                                                            14.0,
                                                                      ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                    ),
                                                                    Text(
                                                                      'تراز: ' +
                                                                          (allUsers!.elementAt(i).score.round())
                                                                              .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade500,
                                                                        fontSize:
                                                                            12.0,
                                                                      ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 94.0,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      'اختصاصی: ' +
                                                                          (allUsers!.elementAt(i).ekh.round())
                                                                              .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade500,
                                                                        fontSize:
                                                                            12.0,
                                                                      ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                    ),
                                                                    Text(
                                                                      'عمومی: ' +
                                                                          (allUsers!.elementAt(i).omu.round())
                                                                              .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade500,
                                                                        fontSize:
                                                                            12.0,
                                                                      ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                    ),
                                                                    Text(
                                                                      'مطالعه: ' +
                                                                          (allUsers!.elementAt(i).khales)
                                                                              .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade500,
                                                                        fontSize:
                                                                            12.0,
                                                                      ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                    ),
                                                                    Text(
                                                                      'خواب: ' +
                                                                          (allUsers!.elementAt(i).sleep)
                                                                              .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade500,
                                                                        fontSize:
                                                                            12.0,
                                                                      ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                    ),
                                                                    Text(
                                                                      'کلاس: ' +
                                                                          (allUsers!.elementAt(i).school)
                                                                              .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade500,
                                                                        fontSize:
                                                                            12.0,
                                                                      ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                    ),
                                                                  ],
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
                                  );
                                },
                              ),
                      )
                    : Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16.0, 8.0, 16.0, 8.0),
                              child: Card(
                                color: Colors.lightBlue.shade700,
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                elevation: 0.0,
                                child: InkWell(
                                    enableFeedback: widgetsEnabled,
                                    borderRadius: BorderRadius.circular(20.0),
                                    onTap: () {
                                      getAll();
                                    },
                                    child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          'دریافت رتبه‌بندی دانش‌آموزان',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'IranSansMed',
                                            fontSize: 15.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ))),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16.0, 8.0, 16.0, 8.0),
                              child: Card(
                                color: Colors.lightGreen.shade700,
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                elevation: 0.0,
                                child: InkWell(
                                    enableFeedback: widgetsEnabled,
                                    borderRadius: BorderRadius.circular(20.0),
                                    onTap: () {
                                      AlertDialog alert = AlertDialog(
                                        title: Text('TextField in Dialog'),
                                        content: TextField(
                                          controller: adminPhoneController,
                                          decoration: InputDecoration(
                                              hintText: "User Phone Number"),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('CANCEL'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          TextButton(
                                            child: Text('OK'),
                                            onPressed: () {
                                              getUserHistory(
                                                  adminPhoneController.text);
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      );

                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return alert;
                                        },
                                      );
                                    },
                                    child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          'دریافت تاریخچه‌ی دانش‌آموز',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'IranSansMed',
                                            fontSize: 15.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ))),
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
    );
  }

  // DATABASE CONNECTIONS

  Future<void> signUp() async {
    try {
      setState(() {
        widgetsEnabled = false;
      });

      if (conn == null) conn = await MySqlConnection.connect(settings);

      await conn!.query(
          'INSERT INTO `users` (`name`, `phone`, `hash`, `avg_score`, `last_payment_date`) VALUES (?, ?, ?, ?, ?);',
          [
            double.parse(nameController.text),
            double.parse(phoneController.text),
            double.parse(hashController.text),
            0,
            DateTime.now().toUtc(),
          ]).whenComplete(() => {
            setState(() {
              nameController.clear();
              phoneController.clear();
              hashController.clear();
            }),
          });
    } catch (error) {
      Fluttertoast.showToast(
          msg: "مشکلی در اتصال به سرور رخ داده است!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 15.0);
      setState(() {
        widgetsEnabled = true;
      });
    }
  }

  Future<void> signIn() async {
    try {
      setState(() {
        widgetsEnabled = false;
      });

      if (conn == null) conn = await MySqlConnection.connect(settings);

      var results = await conn!.query(
          'SELECT hash, name, user_id, avg_score FROM users WHERE phone = ?',
          [login_phoneController.text]);
      if (results.length == 0) {
        Fluttertoast.showToast(
            msg: "شماره در دیتابیس موجود نیست!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 15.0);
        setState(() {
          widgetsEnabled = true;
        });
      } else if (results.first[0] == login_hashController.text) {
        Fluttertoast.showToast(
            msg: "ورود موفقیت‌آمیز بود!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green.shade700,
            textColor: Colors.white,
            fontSize: 15.0);
        setState(() {
          widgetsEnabled = true;
          prefs.setInt('user_id', results.first[2]);
          prefs.setInt('avg_score', results.first[3]);
          prefs.setString('name', results.first[1]);
        });
      } else {
        Fluttertoast.showToast(
            msg: "رمز عبور واردشده اشتباه است!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 15.0);
        setState(() {
          widgetsEnabled = true;
        });
      }
    } catch (error) {
      Fluttertoast.showToast(
          msg: "مشکلی در اتصال به سرور رخ داده است!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 15.0);
      setState(() {
        widgetsEnabled = true;
      });
    }
  }

  Future<void> loadIfExists() async {
    firstTime = false;

    try {
      print('loadIfExists');

      if (conn == null) conn = await MySqlConnection.connect(settings);

      DateTime date = DateTime.now().toUtc();

      if (DateTime.now().hour < 18)
        date = DateTime.now().toUtc().subtract(
              Duration(
                days: 1,
              ),
            );

      String year = date.year.toString();
      String month = date.month.toString();
      String day = date.day.toString();
      if (month.length == 1) month = '0' + month;
      if (day.length == 1) day = '0' + day;
      String dateString = year + '-' + month + '-' + day;

      var results = await conn!.query(
          'SELECT ekhtesasi, omumi, khales, sleep, school, bazdeh, score FROM reports WHERE user_id_fk = ? AND date = ?',
          [userId, dateString]);

      if (results.length > 0) {
        double khales = results.first[2];
        double sleep = results.first[3];
        double school = results.first[4];

        setState(() {
          editMode = true;
        });

        ekhtesasiController.text = results.first[0].toString();
        omumiController.text = results.first[1].toString();
        khalesController.text = khales == khales.truncate()
            ? khales.toInt().toString()
            : khales.toString();
        sleepController.text = sleep == sleep.truncate()
            ? sleep.toInt().toString()
            : sleep.toString();
        schoolController.text = school == school.truncate()
            ? school.toInt().toString()
            : school.toString();
      }
    } catch (error) {
      Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 15.0);
    }
  }

  Future<void> addReport() async {
    try {
      setState(() {
        widgetsEnabled = false;
      });

      print('addReport');

      if (conn == null) conn = await MySqlConnection.connect(settings);

      double bazdeh = ((double.parse(khalesController.text) * 100) /
          (24 -
              double.parse(sleepController.text) -
              double.parse(schoolController.text)));

      if (editMode) {
        DateTime date = DateTime.now().toUtc();

        if (DateTime.now().hour < 18)
          date = DateTime.now().toUtc().subtract(
                Duration(
                  days: 1,
                ),
              );

        String year = date.year.toString();
        String month = date.month.toString();
        String day = date.day.toString();
        if (month.length == 1) month = '0' + month;
        if (day.length == 1) day = '0' + day;
        String dateString = year + '-' + month + '-' + day;

        await conn!.query(
            'UPDATE reports SET ekhtesasi = ?, omumi = ?, khales = ?, sleep = ?, school = ?, bazdeh = ?, score = ? WHERE user_id_fk = ? AND date = ?',
            [
              int.parse(ekhtesasiController.text),
              int.parse(omumiController.text),
              double.parse(khalesController.text),
              double.parse(sleepController.text),
              double.parse(schoolController.text),
              bazdeh,
              dna.score(
                  double.parse(ekhtesasiController.text),
                  double.parse(omumiController.text),
                  double.parse(khalesController.text),
                  bazdeh),
              userId,
              dateString
            ]).whenComplete(() async => {
              await conn!.query(
                  'UPDATE users SET avg_score = (SELECT AVG(score) FROM reports WHERE users.user_id = reports.user_id_fk) WHERE user_id = ?;',
                  [
                    userId
                  ]).whenComplete(() => {
                    ekhtesasiController.clear(),
                    omumiController.clear(),
                    khalesController.clear(),
                    sleepController.clear(),
                    schoolController.clear(),
                    getNewAverage(),
                    setState(() {
                      justSent = true;
                    }),
                  })
            });
      } else {
        await conn!.query(
            'INSERT INTO reports (user_id_fk, date, ekhtesasi, omumi, khales, sleep, school, bazdeh, score) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);',
            [
              userId,
              DateTime.now().toUtc(),
              int.parse(ekhtesasiController.text),
              int.parse(omumiController.text),
              double.parse(khalesController.text),
              double.parse(sleepController.text),
              double.parse(schoolController.text),
              bazdeh,
              dna.score(
                  double.parse(ekhtesasiController.text),
                  double.parse(omumiController.text),
                  double.parse(khalesController.text),
                  bazdeh),
            ]).whenComplete(() async => {
              await conn!.query(
                  'UPDATE users SET avg_score = (SELECT AVG(score) FROM reports WHERE users.user_id = reports.user_id_fk) WHERE user_id = ?;',
                  [
                    userId
                  ]).whenComplete(() => {
                    ekhtesasiController.clear(),
                    omumiController.clear(),
                    khalesController.clear(),
                    sleepController.clear(),
                    schoolController.clear(),
                    getNewAverage(),
                    setState(() {
                      justSent = true;
                    }),
                  })
            });
      }
    } catch (error) {
      Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 15.0);
      setState(() {
        widgetsEnabled = true;
      });
    }
  }

  Future<void> getNewAverage() async {
    print('getNewAverage');

    try {
      if (conn == null) conn = await MySqlConnection.connect(settings);

      var results = await conn!
          .query('SELECT avg_score FROM users WHERE user_id = ?', [userId]);
      if (results.length != 0) {
        prefs.setInt('avg_score', results.first[0].toInt());
        setState(() {
          avgScore = results.first[0].toInt();
        });
      }
    } catch (error) {
      Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 15.0);
    }
  }

  Future<void> getAll() async {
    try {
      print('getAll');
      if (conn == null) conn = await MySqlConnection.connect(settings);

      DateTime date = DateTime.now().toUtc();

      if (DateTime.now().hour < 18)
        date = DateTime.now().toUtc().subtract(
              Duration(
                days: 1,
              ),
            );

      String year = date.year.toString();
      String month = date.month.toString();
      String day = date.day.toString();
      if (month.length == 1) month = '0' + month;
      if (day.length == 1) day = '0' + day;
      String dateString = year + '-' + month + '-' + day;

      var results = await conn!.query(
          'SELECT name, ekhtesasi, omumi, khales, sleep, school, score, avg_score FROM users JOIN reports ON users.user_id = reports.user_id_fk WHERE reports.date = ? ORDER BY score DESC',
          [dateString]);

      is1 = false;
      is2 = false;
      is3 = false;
      is4 = false;
      is5 = false;
      is6 = false;
      is7 = false;
      is8 = false;
      is9 = false;

      allUsers = List<Item>.generate(
        results.length,
        (index) => Item(
          index + 1,
          results.elementAt(index)[0],
          results.elementAt(index)[1],
          results.elementAt(index)[2],
          results.elementAt(index)[3],
          results.elementAt(index)[4],
          results.elementAt(index)[5],
          results.elementAt(index)[6],
          results.elementAt(index)[7],
          returnGroupName(results.elementAt(index)[6]),
        ),
      );

      if (!is1)
        allUsers!.add(Item(0, '', 0, 0, 0, 0, 0, 2500, 0,
            'انا لله و انا الیه راجعون|زیر 2500'));
      if (!is2)
        allUsers!
            .add(Item(0, '', 0, 0, 0, 0, 0, 5000, 0, 'الله اکبر|2500 تا 5000'));
      if (!is3)
        allUsers!
            .add(Item(0, '', 0, 0, 0, 0, 0, 5500, 0, 'بسم الله|5000 تا 5500'));
      if (!is4)
        allUsers!
            .add(Item(0, '', 0, 0, 0, 0, 0, 6000, 0, 'لب مرز|5500 تا 6000'));
      if (!is5)
        allUsers!
            .add(Item(0, '', 0, 0, 0, 0, 0, 6500, 0, 'آینده‌دار|6000 تا 6500'));
      if (!is6)
        allUsers!.add(Item(0, '', 0, 0, 0, 0, 0, 7000, 0, 'نخبه|6500 تا 7000'));
      if (!is7)
        allUsers!
            .add(Item(0, '', 0, 0, 0, 0, 0, 7500, 0, 'فرانخبه|7000 تا 7500'));
      if (!is8)
        allUsers!
            .add(Item(0, '', 0, 0, 0, 0, 0, 8000, 0, 'شاه‌تست|7500 تا 8000'));
      if (!is9)
        allUsers!.add(Item(0, '', 0, 0, 0, 0, 0, 9000, 0, 'آدار|بالای 8000'));

      allUsers!.sort(mySorter);

      setState(() {
        leaderBoardMode = true;
      });
    } catch (error) {
      Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 15.0);
    }
  }

  Future<void> getUserHistory(String phone) async {
    try {
      print('getUserHistory');

      if (conn == null) conn = await MySqlConnection.connect(settings);

      var resultsForHistory1 = await conn!.query(
          'SELECT date, ekhtesasi, omumi, khales, sleep, school, bazdeh, score FROM reports WHERE user_id_fk = (SELECT user_id FROM users WHERE phone = ?) ORDER BY date DESC',
          [phone]);
      if (resultsForHistory1.length > 0) {
        histories = List<HistoryItem>.generate(
          resultsForHistory1.length,
          (index) => HistoryItem(
            resultsForHistory1.elementAt(index)[0],
            resultsForHistory1.elementAt(index)[1],
            resultsForHistory1.elementAt(index)[2],
            resultsForHistory1.elementAt(index)[3],
            resultsForHistory1.elementAt(index)[4],
            resultsForHistory1.elementAt(index)[5],
            double.parse(resultsForHistory1.elementAt(index)[6].toString())
                .floor()
                .toDouble(),
            double.parse(resultsForHistory1.elementAt(index)[7].toString())
                .floor()
                .toDouble(),
          ),
        );
        var resultsForHistory2 = await conn!.query(
            'SELECT user_id, name, avg_score, DATEDIFF(CURDATE(), last_payment_date) FROM users WHERE phone = ?',
            [phone]);

        if (resultsForHistory2.length > 0) {
          setState(() {
            historyMode = true;
            historyModeUserId = resultsForHistory2.first[0];
            historyModeName = resultsForHistory2.first[1];
            historyModeAverage = resultsForHistory2.first[2];
            historyModePaymentDate = resultsForHistory2.first[3];
            historyModePhone = phone;
          });
        }
      }
    } catch (error) {
      Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 15.0);
    }
  }

  Future<void> setPaidToday() async {
    try {
      print('setPaidToday');

      if (conn == null) conn = await MySqlConnection.connect(settings);

      await conn!.query(
          'UPDATE users SET last_payment_date = ? WHERE user_id = ?;',
          [DateTime.now().toUtc(), historyModeUserId]);

      setState(() {
        historyModePaymentDate = 0;
      });
      Fluttertoast.showToast(
          msg: 'انجام شد',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green.shade700,
          textColor: Colors.white,
          fontSize: 15.0);
    } catch (error) {
      Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 15.0);
    }
  }

  // OTHER FUNCTIONS

  int mySorter(Item a, Item b) {
    if (a.score > b.score)
      return -1;
    else if (a.score < b.score)
      return 1;
    else {
      if (a.id < b.id)
        return -1;
      else
        return 1;
    }
  }

  String returnGroupName(double input) {
    String groupName = '';
    if (input <= 2500) {
      groupName = 'انا لله و انا الیه راجعون|زیر 2500';
      is1 = true;
    } else if (input > 2500 && input <= 5000) {
      groupName = 'الله اکبر|2500 تا 5000';
      is2 = true;
    } else if (input > 5000 && input <= 5500) {
      groupName = 'بسم الله|5000 تا 5500';
      is3 = true;
    } else if (input > 5500 && input <= 6000) {
      groupName = 'لب مرز|5500 تا 6000';
      is4 = true;
    } else if (input > 6000 && input <= 6500) {
      groupName = 'آینده‌دار|6000 تا 6500';
      is5 = true;
    } else if (input > 6500 && input <= 7000) {
      groupName = 'نخبه|6500 تا 7000';
      is6 = true;
    } else if (input > 7000 && input <= 7500) {
      groupName = 'فرانخبه|7000 تا 7500';
      is7 = true;
    } else if (input > 7500 && input <= 8000) {
      groupName = 'شاه‌تست|7500 تا 8000';
      is8 = true;
    } else {
      groupName = 'آدار|بالای 8000';
      is9 = true;
    }
    return groupName;
  }
}
