import 'dart:async';
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dart_mysql/dart_mysql.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DNA.dart';
import 'Zarinpal.dart';
import 'history_item.dart';
import 'item.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String show = "تراکنش انجام نشده است";

  Zarinpal zarinpal = new Zarinpal();

  zarinPalRequest() {
    num price = 1000000;
    if (maxDays > daysPassed) {
      price *= daysPassed / maxDays;
      price = price.floor();
    }

    zarinpal.setPaymentRequest(
        description: "خرید نسخه کامل",
        amount: price,
        callBackURL: "retuern://zarinpalpayment",
        email: "0",
        mobile: "0",
        merchantID: "489c41b8-1891-4efc-9644-862b6b8ac2bd");

    zarinpal.makePostRequest().then((value) => setState(() {
          show = value;
        }));
  }

  // for reporting
  final omumiController = TextEditingController();
  final ekhtesasiController = TextEditingController();
  final khalesController = TextEditingController();
  final sleepController = TextEditingController();
  final schoolController = TextEditingController();

  // for sign in
  final loginPhoneController = TextEditingController();
  final loginHashController = TextEditingController();

  // for sign up
  final hashController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  var fadeInController = new FadeInController(autoStart: true);

  final adminPhoneController = TextEditingController();

  List<Item>? allUsers;
  List<HistoryItem>? histories;

  late SharedPreferences prefs;
  MySqlConnection? conn;

  int userId = 0;
  int userRank = 0;
  int avgScore = 0;
  int daysPassed = 0;
  String name = '';
  String historyModeName = '';
  String historyModePhone = '';
  double historyModeAverage = 0;
  int historyModeUserId = 0;
  bool historyModePermanent = false;
  bool signUpMode = true;

  bool widgetsEnabled = true;
  bool justSent = false;
  bool adminMode = false;
  bool historyMode = false;
  bool leaderBoardMode = false;
  bool editMode = false;
  bool noUserRanksVisible = true;
  bool firstTime = true;
  bool permanentUser = false;

  int maxDays = 30;
  bool is1 = false, is2 = false, is3 = false, is4 = false, is5 = false, is6 = false, is7 = false, is8 = false, is9 = false;

  var settings = new ConnectionSettings(
      host: '158.58.187.220',
      port: 3306,
      user: 'reportadmin',
      password: '3.1415926535Takht',
      timeout: Duration(seconds: 5),
      db: 'adarbase_reportdb');

  Future<int> getUserId() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('admin_is_in') ?? false)
      setState(() {
        adminMode = true;
      });
    userId = prefs.getInt('user_id') ?? 0;
    avgScore = prefs.getInt('avg_score') ?? 0;
    name = prefs.getString('name') ?? '';

    permanentUser = prefs.getBool('permanent_user') ?? false;
    if (permanentUser) maxDays = 365;

    if (name == '') name = 'پروفایل دانش‌آموز';
    return userId;
  }

  late final future = getUserId();

  DNA dna = new DNA();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (adminMode) {
          if (historyMode || leaderBoardMode)
            setState(() {
              historyMode = false;
              leaderBoardMode = false;
            });
          else
            return Future.value(true);
        }
        return Future.value(false);
      },
      child: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (adminMode)
            return adminModeWidget();
          else {
            if (snapshot.hasData) {
              if (userId != 0) {
                if (firstTime) loadIfExists();
                return profileWidget();
              } else
                return signInWidget();
            } else
              return Scaffold(
                backgroundColor: Colors.white,
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
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);

    int rnd = Random().nextInt(3);
      WidgetsBinding.instance!.addPostFrameCallback((_) => showGeneralDialog(
          context: context,
          barrierColor: Colors.white.withOpacity(0.97),
          barrierDismissible: false,
          barrierLabel: 'Dialog',
          transitionDuration: Duration(milliseconds: 400),
          pageBuilder: (context, __, ___) {
            return Dismissible(
                direction: DismissDirection.up,
                onDismissed: (_) {
                  Navigator.of(context).pop();
                },
                key: Key('key'),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: SafeArea(
                      child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Spacer(),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(128.0, 0.0, 128.0, 0.0),
                                  child: Image.asset('assets/imgs/logo1.png')
                                ),
                              ),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  'ارائه‌شده توسط آکادمی آدار',
                                  style: TextStyle(
                                    fontFamily: 'IranSansMed',
                                    fontSize: 15.0,
                                    color: Colors.blue.shade800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                                child: Divider(
                                    thickness: 1.0, height: 1.0, indent: 110.0, endIndent: 110.0, color: Colors.blue.shade800),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 16.0),
                                child: Text(
                                  'پشتیبانی کانون قلم‌چی نکا (مازندران)',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.grey.shade500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 4.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Card(
                                    elevation: 0.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    color: Colors.grey.shade100,
                                    margin: EdgeInsets.zero,
                                    child: Theme(
                                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                      child: ExpansionTile(
                                        tilePadding: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
                                        textColor: Colors.black,
                                        iconColor: Colors.black,
                                        leading: CircleAvatar(
                                          radius: 24.0,
                                          backgroundImage: AssetImage('assets/imgs/amirreza.png'),
                                        ),
                                        title: Text(
                                          'امیررضا عشوری',
                                          style: TextStyle(fontFamily: 'IranSansMed', fontSize: 14.0),
                                        ),
                                        subtitle: Text(
                                          'دانشجوی سال پنجم پزشکی',
                                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12.0),
                                        ),
                                        children: [
                                          Divider(
                                            height: 1.0,
                                            color: Colors.grey.shade400,
                                            indent: 16.0,
                                            endIndent: 16.0,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                                  child: Icon(
                                                    Icons.perm_identity_outlined,
                                                    size: 20.0,
                                                  ),
                                                ),
                                                Text(
                                                  'amirreza_ashoori',
                                                  style: TextStyle(fontSize: 13.0, fontFamily: 'IranSansMed'),
                                                ),
                                                Spacer(),
                                                Text(
                                                  '09051993399',
                                                  style: TextStyle(fontSize: 13.0, fontFamily: 'IranSansMed'),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                                  child: Icon(
                                                    Icons.phone_outlined,
                                                    size: 20.0,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Card(
                                    elevation: 0.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    color: Colors.grey.shade100,
                                    margin: EdgeInsets.zero,
                                    child: Theme(
                                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                      child: ExpansionTile(
                                        tilePadding: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
                                        textColor: Colors.black,
                                        iconColor: Colors.black,
                                        leading: CircleAvatar(
                                          radius: 24.0,
                                          backgroundImage: AssetImage('assets/imgs/saeed1.jpg'),
                                        ),
                                        title: Text(
                                          'سعید محمدی',
                                          style: TextStyle(fontFamily: 'IranSansMed', fontSize: 14.0),
                                        ),
                                        subtitle: Text(
                                          'دانشجوی سال پنجم پزشکی',
                                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12.0),
                                        ),
                                        children: [
                                          Divider(
                                            height: 1.0,
                                            color: Colors.grey.shade400,
                                            indent: 16.0,
                                            endIndent: 16.0,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                                  child: Icon(
                                                    Icons.perm_identity_outlined,
                                                    size: 20.0,
                                                  ),
                                                ),
                                                Text(
                                                  'saeedzeroone',
                                                  style: TextStyle(fontSize: 13.0, fontFamily: 'IranSansMed'),
                                                ),
                                                Spacer(),
                                                Text(
                                                  '09352189998',
                                                  style: TextStyle(fontSize: 13.0, fontFamily: 'IranSansMed'),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                                  child: Icon(
                                                    Icons.phone_outlined,
                                                    size: 20.0,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_up),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 16.0),
                          child: Text(
                            'هُلم بده بریم بالا!',
                            style: TextStyle(fontFamily: 'IranSansMed'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )),
                ));
          }));
  }

  void onResumed() {
    zarinpal.makePostVerify().then((value) => {
          if (value.toString().contains('تراکنش موفق'))
            {
              prefs.setBool('paid', true),
              updatePayment(),
              setState(() {
                show = value;
                daysPassed = 0;
              }),
            },
          print(value),
        });
  }

  @override
  void dispose() {
    try {
      if (conn != null) conn!.close();
    } finally {
      WidgetsBinding.instance!.removeObserver(this);
      super.dispose();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.resumed:
        setState(() {
          onResumed();
        });

        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  // WIDGETS FOR DIFFERENT MODES
  Widget signInWidget() {
    double height = MediaQuery.of(context).size.height;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
            child: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, height / 2 - 270, 0.0, height / 2 - 280),
                  child: Lottie.asset(
                    'assets/anim/hello.json',
                    animate: true,
                    repeat: true,
                  ),
                ),
                Text(
                  'این‌جا چیکار میشه کرد؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.keyboard_arrow_down_rounded),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 64.0, 16.0, 24.0),
                  child: Image.asset('assets/imgs/pic1.png'),
                ),
                Text(
                  'سوابق درس‌خوندنت رو ذخیره کن!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.indigo.shade900,
                    fontFamily: 'IranSansMed',
                    fontSize: 20.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0.0),
                  child: Text(
                    dna.justify(
                        'می‌خوای بدونی میزان مطالعه‌ت نسبت به روزای قبل بهتر شده یا بدتر؟ می‌خوای یه تاریخچه از ساعتای مطالعه‌ی هر روز داشته باشی؟ دلت می‌خواد بدونی ساعت خوابت کم‌تر شده یا بیش‌تر؟ این‌جا می‌تونی تموم این کارها رو به سادگی انجام بدی.'),
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Divider(
                    indent: 16.0,
                    endIndent: 16.0,
                    height: 1.0,
                    color: Colors.grey.shade300,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 24.0),
                  child: Image.asset('assets/imgs/pic2.png'),
                ),
                Text(
                  'بابت کاری که در روز می‌کنی تراز بگیر!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.indigo.shade900,
                    fontFamily: 'IranSansMed',
                    fontSize: 20.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0.0),
                  child: Text(
                    dna.justify(
                        'انتهای هر روز، اطلاعات خودت، از جمله تعداد تست‌های اختصاصی و عمومی، زمان مطالعه و کلاس‌ها و حتی زمان خوابت رو وارد کن تا در همون لحظه، تراز معادل با زحمات اون روزت رو دریافت کنی. این تراز هم‌ردیف تراز آزمون‌های معروف کشوره و برای مثال، در صورتی که عدد 6500 رو بگیری، احتمال این که توی آزمون هم همین بشه، بالا میره. همچنین، میانگین ترازهای خودتو هم می‌تونی مشاهده کنی.'),
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Divider(
                    indent: 16.0,
                    endIndent: 16.0,
                    height: 1.0,
                    color: Colors.grey.shade300,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 24.0),
                  child: Image.asset('assets/imgs/pic3.png'),
                ),
                Text(
                  'روزانه بین دانش‌آموزا رتبه‌بندی شو!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.indigo.shade900,
                    fontFamily: 'IranSansMed',
                    fontSize: 20.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0.0),
                  child: Text(
                    dna.justify(
                        'می‌خوای ببینی بقیه‌ی دانش‌آموزای آدار چطوری درس می‌خونن؟ هر روز ساعت 8 صبح، دانش‌آموزایی که اطلاعات روز قبلشون رو وارد کرده باشن رتبه‌بندی میشن و رتبه‌شون برای خودشون مشخص میشه.'),
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 32.0, 0.0, 32.0),
                  child: Divider(
                    indent: 16.0,
                    endIndent: 16.0,
                    height: 1.0,
                    color: Colors.grey.shade300,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                  child: Text(
                    'ثبت نام کن، یا اگه اکانت داری، وارد شو!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
                FadeIn(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
                    child: Card(
                      color: Colors.grey.shade50,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
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
                          hintText: "شماره‌ت رو این‌جا وارد کن",
                          border: InputBorder.none,
                          suffixIcon: Icon(
                            Icons.text_fields_outlined,
                            color: Colors.transparent,
                          ),
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                          ),
                        ),
                        textAlign: TextAlign.center,
                        controller: signUpMode ? phoneController : loginPhoneController,
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ),
                  ),
                ),
                FadeIn(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                    child: Card(
                      color: Colors.grey.shade50,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 0.0,
                      child: TextField(
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          LengthLimitingTextInputFormatter(10),
                        ],
                        keyboardType: TextInputType.number,
                        enabled: widgetsEnabled,
                        decoration: InputDecoration(
                          hintText: "رمز عبورت رو این‌جا بنویس",
                          suffixIcon: Icon(
                            Icons.text_fields_outlined,
                            color: Colors.transparent,
                          ),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                          ),
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14.0),
                        controller: signUpMode ? hashController : loginHashController,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: signUpMode,
                  child: FadeIn(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
                      child: Card(
                        color: Colors.grey.shade50,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 0.0,
                        child: TextField(
                          enabled: widgetsEnabled,
                          decoration: InputDecoration(
                            hintText: "اسمتو هم این‌جا وارد کن",
                            border: InputBorder.none,
                            suffixIcon: Icon(
                              Icons.person_outline,
                              color: Colors.transparent,
                            ),
                            prefixIcon: Icon(
                              Icons.person_outline,
                            ),
                          ),
                          textAlign: TextAlign.center,
                          controller: nameController,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                    ),
                  ),
                ),
                FadeIn(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 16.0),
                    child: Text(
                      dna.justify(signUpMode
                          ? 'اطلاعات بالا رو وارد کن و روی دکمه‌ی زیر کلیک کن تا توی آدار ثبت نام کنی. تنبلی نکن، منتظرتیم.'
                          : 'برای ورود به اپلیکیشن، اطلاعاتت رو وارد کن. اگر رمز عبورت رو یادت رفته، می‌تونی اونو از مشاورت بگیری.'),
                      style: TextStyle(
                        fontSize: 13.0,
                        color: Colors.grey.shade500,
                        fontFamily: 'IranSans',
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
                FadeIn(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 32.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                            child: Card(
                              color: widgetsEnabled ? Colors.green.shade400 : Colors.grey.shade500,
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 0.0,
                              child: AbsorbPointer(
                                absorbing: !widgetsEnabled,
                                child: InkWell(
                                    enableFeedback: widgetsEnabled,
                                    borderRadius: BorderRadius.circular(20.0),
                                    onTap: () {
                                      if (signUpMode) {
                                        if (phoneController.text.length != 11)
                                          EasyLoading.showToast('شماره‌ای که وارد کردی کوتاهه');
                                        else if (phoneController.text.length == 0 ||
                                            hashController.text.length == 0 ||
                                            nameController.text.replaceAll(' ', '').length == 0)
                                          EasyLoading.showToast('اطلاعات بالا رو وارد کن');
                                        else if (hashController.text.length < 3)
                                          EasyLoading.showToast('رمز عبورت خیلی کوتاهه');
                                        else if (!dna.isOnlyPersian(nameController.text))
                                          EasyLoading.showToast('اسمتو به فارسی وارد کن');
                                        else
                                          signUp();
                                      } else {
                                        if (loginPhoneController.text.length != 11)
                                          EasyLoading.showToast('شماره‌ای که وارد کردی کوتاهه');
                                        else if (loginPhoneController.text.length == 0 || loginHashController.text.length == 0)
                                          EasyLoading.showToast('شماره و رمز عبورتو وارد کن');
                                        else if (loginPhoneController.text == '09611001079' &&
                                            loginHashController.text == '3399') {
                                          setState(() {
                                            adminMode = true;
                                          });
                                          prefs.setBool('admin_is_in', true);
                                          setState(() {});
                                        } else
                                          signIn();
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: widgetsEnabled
                                          ? Text(
                                              signUpMode ? 'ثبت کن نامم رو!' : 'بزن بریم!',
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
                        ),
                        Card(
                          color: widgetsEnabled ? Colors.blueAccent : Colors.grey.shade500,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 0.0,
                          child: AbsorbPointer(
                            absorbing: !widgetsEnabled,
                            child: InkWell(
                                enableFeedback: widgetsEnabled,
                                borderRadius: BorderRadius.circular(20.0),
                                onTap: () {
                                  setState(() {
                                    if (signUpMode)
                                      signUpMode = false;
                                    else
                                      signUpMode = true;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: widgetsEnabled
                                      ? Text(
                                          signUpMode ? 'اکانت دارم بابا!' : 'اکانت ندارم هنوز!',
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
                      ],
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

  Widget profileWidget() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
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
                          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 0.0),
                          child: AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                name,
                                textStyle: TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: 'IranSansMed',
                                ),
                                speed: const Duration(milliseconds: 50),
                              ),
                            ],
                            totalRepeatCount: 1,
                          )),
                      Spacer(),
                      IconButton(
                        onPressed: () {
                          EasyLoading.showToast('یک و یک و یک...');
                          loadIfExists();
                        },
                        icon: Icon(
                          Icons.restart_alt_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FadeIn(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4.0,
                    child: InkWell(
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      enableFeedback: daysPassed > 20,
                      onTap: () {
                        if (daysPassed > 20) zarinPalRequest();
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          gradient: LinearGradient(
                            colors: [
                              daysPassed > maxDays ? Colors.redAccent : Colors.blueAccent,
                              daysPassed > maxDays ? Colors.redAccent.shade700 : Colors.blueAccent.shade700,
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                              child: daysPassed > maxDays
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'آخرین رتبه: 00',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.white70,
                                            fontFamily: 'IranSansMed',
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          'میانگین تراز: 0000',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontFamily: 'IranSansMed',
                                            color: Colors.white70,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    )
                                  : avgScore == 0
                                      ? Text(
                                          'تراز و رتبه در این محل قرار می‌گیرند',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.white,
                                            fontFamily: 'IranSansMed',
                                          ),
                                          textAlign: TextAlign.center,
                                        )
                                      : (userRank == 0
                                          ? Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'آخرین رتبه: 00',
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    color: Colors.white,
                                                    fontFamily: 'IranSansMed',
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  'میانگین تراز: ' + avgScore.toString(),
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontFamily: 'IranSansMed',
                                                    color: Colors.white,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            )
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'آخرین رتبه: ' + userRank.toString(),
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    color: Colors.white,
                                                    fontFamily: 'IranSansMed',
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  'میانگین تراز: ' + avgScore.toString(),
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontFamily: 'IranSansMed',
                                                    color: Colors.white,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            )),
                            ),
                            Visibility(
                                visible: permanentUser ? (daysPassed > 355) : (daysPassed > 20),
                                child: Divider(height: 1.0, indent: 16.0, endIndent: 16.0, color: Colors.white70)),
                            Visibility(
                              visible: permanentUser ? (daysPassed > 355) : (daysPassed > 20),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                                      child: IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.payment,
                                          color: Colors.white,
                                        ),
                                        splashRadius: 20.0,
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        daysPassed <= 30
                                            ? dna.justify((30 - daysPassed).toString() +
                                                ' روز دیگر حساب کاربری شما غیرفعال می‌شود. در این صورت، بازده، تراز و رتبه‌ای دریافت نخواهید کرد. برای فعال‌سازی مجدد، لطفاً اشتراک آدار را خریداری کنید. (با توجه به آن که هنوز مقداری از اشتراک فعلی باقی مانده است، در صورت پرداخت، هزینه‌ی آن کاهش می‌یابد.)')
                                            : dna.justify(
                                                'حساب کاربری شما غیرفعال شده است. از حالا، بازده، تراز و رتبه‌ای دریافت نخواهید کرد. برای فعال‌سازی مجدد، لطفاً اشتراک آدار را خریداری کنید.'),
                                        style: TextStyle(
                                          fontSize: 13.0,
                                          fontFamily: 'IranSansMed',
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.justify,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              histories != null
                  ? Expanded(
                      child: FadeIn(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: daysPassed > maxDays ? Colors.red.shade50 : Color(0xFFF4FBFF),
                                border: Border.all(width: 1.0, color: Colors.grey.shade300),
                                borderRadius: BorderRadius.all(Radius.circular(12.0))),
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(12.0)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          headingRowHeight: 48.0,
                                          dataRowColor: MaterialStateColor.resolveWith(
                                              (states) => daysPassed > maxDays ? Colors.red.shade50 : Color(0xFFF4FBFF)),
                                          headingRowColor: MaterialStateColor.resolveWith(
                                              (states) => daysPassed > maxDays ? Colors.red.shade100 : Colors.lightBlue.shade50),
                                          headingTextStyle: TextStyle(
                                            fontFamily: 'IranSansMed',
                                            color: daysPassed > maxDays ? Colors.red.shade800 : Colors.blue.shade800,
                                          ),
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
                                            ),
                                            DataColumn(
                                              label: Text('عمومی'),
                                            ),
                                            DataColumn(
                                              label: Text('خالص'),
                                            ),
                                            DataColumn(
                                              label: Text('خواب'),
                                            ),
                                            DataColumn(
                                              label: Text('کلاس'),
                                            ),
                                            DataColumn(
                                              label: Text('آزاد'),
                                            ),
                                            DataColumn(
                                              label: Text('بازده'),
                                            ),
                                            DataColumn(
                                              label: Text('تراز'),
                                            ),
                                          ],
                                          rows: histories!
                                              .map(
                                                (history) => DataRow(
                                                  cells: [
                                                    DataCell(
                                                      Text(history.date.weekday
                                                          .toString()
                                                          .replaceAll('1', 'دوشنبه')
                                                          .replaceAll('2', 'سه‌شنبه')
                                                          .replaceAll('3', 'چهارشنبه')
                                                          .replaceAll('4', 'پنج‌شنبه')
                                                          .replaceAll('5', 'جمعه')
                                                          .replaceAll('6', 'شنبه')
                                                          .replaceAll('7', 'یک‌شنبه')),
                                                      onTap: () {
                                                        // write your code..
                                                      },
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        Jalali.fromDateTime(history.date).day.toString() +
                                                            ' ' +
                                                            dna.persianMonth(Jalali.fromDateTime(history.date).month) +
                                                            ' ' +
                                                            Jalali.fromDateTime(history.date).year.toString(),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(history.ekh.toString()),
                                                    ),
                                                    DataCell(
                                                      Text(history.omu.toString()),
                                                    ),
                                                    DataCell(
                                                      Text(dna.removeTrailingZeros(history.khales).toString()),
                                                    ),
                                                    DataCell(
                                                      Text(dna.removeTrailingZeros(history.sleep).toString()),
                                                    ),
                                                    DataCell(
                                                      Text(dna.removeTrailingZeros(history.school).toString()),
                                                    ),
                                                    DataCell(
                                                      Text(daysPassed <= 30
                                                          ? dna
                                                              .removeTrailingZeros((24 - history.sleep - history.school))
                                                              .toString()
                                                          : '---'),
                                                    ),
                                                    DataCell(
                                                      Text(daysPassed <= 30
                                                          ? dna.removeTrailingZeros(history.bazdeh).toString()
                                                          : '---'),
                                                    ),
                                                    DataCell(
                                                      Text(daysPassed <= 30
                                                          ? dna.removeTrailingZeros(history.score).toString()
                                                          : '---'),
                                                    ),
                                                  ],
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Divider(height: 1.0, color: Colors.grey.shade400),
                                  Card(
                                    color: widgetsEnabled
                                        ? (daysPassed > maxDays ? Colors.red.shade50 : Color(0xFFF4FBFF))
                                        : Colors.grey.shade500,
                                    margin: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                    elevation: 0.0,
                                    child: AbsorbPointer(
                                      absorbing: !widgetsEnabled,
                                      child: InkWell(
                                          enableFeedback: widgetsEnabled,
                                          borderRadius: BorderRadius.circular(0.0),
                                          onTap: () {
                                            Alert(
                                                context: context,
                                                style: AlertStyle(
                                                  overlayColor: Colors.black.withOpacity(0.6),
                                                  buttonAreaPadding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                                                  alertElevation: 0.0,
                                                  backgroundColor: Colors.white,
                                                  animationType: AnimationType.fromRight,
                                                  isCloseButton: false,
                                                  descStyle: TextStyle(fontWeight: FontWeight.bold),
                                                  descTextAlign: TextAlign.start,
                                                  animationDuration: Duration(milliseconds: 250),
                                                  alertBorder: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12.0),
                                                  ),
                                                  alertAlignment: Alignment.center,
                                                ),
                                                content: Directionality(
                                                  textDirection: TextDirection.rtl,
                                                  child: Container(
                                                    width: MediaQuery.of(context).size.width * .9,
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                                      children: <Widget>[
                                                        Padding(
                                                          padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                'گزارش امروزو وارد کن :)',
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  // color: Colors.blueAccent,
                                                                  fontFamily: 'IranSansMed',
                                                                  fontSize: 16.0,
                                                                ),
                                                              ),
                                                              Icon(
                                                                Icons.report_outlined,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.fromLTRB(4.0, 16.0, 4.0, 0.0),
                                                          child: Card(
                                                            margin: EdgeInsets.zero,
                                                            color: Colors.grey.shade100,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12.0),
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
                                                                labelText: "تعداد تست‌های اختصاصی",
                                                                labelStyle: TextStyle(color: Colors.grey.shade600),
                                                                border: InputBorder.none,
                                                                suffixIcon: Icon(
                                                                  Icons.text_fields_outlined,
                                                                  color: Colors.transparent,
                                                                ),
                                                                prefixIcon: Directionality(
                                                                  textDirection: TextDirection.ltr,
                                                                  child: Icon(
                                                                    Icons.help_outline,
                                                                    color: daysPassed > maxDays
                                                                        ? Colors.red.shade800
                                                                        : Colors.blue.shade800,
                                                                  ),
                                                                ),
                                                              ),
                                                              textAlign: TextAlign.center,
                                                              controller: ekhtesasiController,
                                                              style: TextStyle(fontSize: 14.0),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 12.0),
                                                          child: Card(
                                                            color: Colors.grey.shade100,
                                                            margin: EdgeInsets.zero,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12.0),
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
                                                                labelText: "تعداد تست‌های عمومی",
                                                                labelStyle: TextStyle(color: Colors.grey.shade600),
                                                                suffixIcon: Icon(
                                                                  Icons.text_fields_outlined,
                                                                  color: Colors.transparent,
                                                                ),
                                                                border: InputBorder.none,
                                                                prefixIcon: Directionality(
                                                                  textDirection: TextDirection.ltr,
                                                                  child: Icon(
                                                                    Icons.help_outline,
                                                                    color: daysPassed > maxDays
                                                                        ? Colors.red.shade800
                                                                        : Colors.blue.shade800,
                                                                  ),
                                                                ),
                                                              ),
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(fontSize: 14.0),
                                                              controller: omumiController,
                                                            ),
                                                          ),
                                                        ),
                                                        Divider(indent: 8.0, endIndent: 8.0, color: Colors.grey.shade300),
                                                        Padding(
                                                          padding: const EdgeInsets.fromLTRB(4.0, 12.0, 4.0, 0.0),
                                                          child: Card(
                                                            margin: EdgeInsets.zero,
                                                            color: Colors.grey.shade100,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12.0),
                                                            ),
                                                            elevation: 0.0,
                                                            child: TextField(
                                                              enabled: widgetsEnabled,
                                                              inputFormatters: <TextInputFormatter>[
                                                                FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                                                              ],
                                                              keyboardType: TextInputType.number,
                                                              decoration: InputDecoration(
                                                                labelText: "زمان خالص مطالعه (ساعت)",
                                                                labelStyle: TextStyle(color: Colors.grey.shade600),
                                                                border: InputBorder.none,
                                                                suffixIcon: Icon(
                                                                  Icons.text_fields_outlined,
                                                                  color: Colors.transparent,
                                                                ),
                                                                prefixIcon: Icon(
                                                                  Icons.book_outlined,
                                                                  color: daysPassed > maxDays
                                                                      ? Colors.red.shade800
                                                                      : Colors.blue.shade800,
                                                                ),
                                                              ),
                                                              textAlign: TextAlign.center,
                                                              controller: khalesController,
                                                              style: TextStyle(fontSize: 14.0),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 0.0),
                                                          child: Card(
                                                            margin: EdgeInsets.zero,
                                                            color: Colors.grey.shade100,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12.0),
                                                            ),
                                                            elevation: 0.0,
                                                            child: TextField(
                                                              enabled: widgetsEnabled,
                                                              inputFormatters: <TextInputFormatter>[
                                                                FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                                                              ],
                                                              keyboardType: TextInputType.number,
                                                              decoration: InputDecoration(
                                                                labelText: "زمان خواب (ساعت)",
                                                                labelStyle: TextStyle(color: Colors.grey.shade600),
                                                                border: InputBorder.none,
                                                                suffixIcon: Icon(
                                                                  Icons.text_fields_outlined,
                                                                  color: Colors.transparent,
                                                                ),
                                                                prefixIcon: Icon(
                                                                  Icons.bedroom_child_outlined,
                                                                  color: daysPassed > maxDays
                                                                      ? Colors.red.shade800
                                                                      : Colors.blue.shade800,
                                                                ),
                                                              ),
                                                              textAlign: TextAlign.center,
                                                              controller: sleepController,
                                                              style: TextStyle(fontSize: 14.0),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 0.0),
                                                          child: Card(
                                                            margin: EdgeInsets.zero,
                                                            color: Colors.grey.shade100,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12.0),
                                                            ),
                                                            elevation: 0.0,
                                                            child: TextField(
                                                              enabled: widgetsEnabled,
                                                              inputFormatters: <TextInputFormatter>[
                                                                FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                                                              ],
                                                              keyboardType: TextInputType.number,
                                                              decoration: InputDecoration(
                                                                labelText: "زمان مدرسه و کلاس (ساعت)",
                                                                labelStyle: TextStyle(color: Colors.grey.shade600),
                                                                suffixIcon: Icon(
                                                                  Icons.text_fields_outlined,
                                                                  color: Colors.transparent,
                                                                ),
                                                                border: InputBorder.none,
                                                                prefixIcon: Icon(
                                                                  Icons.school_outlined,
                                                                  color: daysPassed > maxDays
                                                                      ? Colors.red.shade800
                                                                      : Colors.blue.shade800,
                                                                ),
                                                              ),
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(fontSize: 14.0),
                                                              controller: schoolController,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                buttons: [
                                                  DialogButton(
                                                    height: 50.0,
                                                    radius: BorderRadius.circular(12.0),
                                                    child: Text(
                                                      editMode ? 'ویرایش اطلاعات' : "ارسال اطلاعات",
                                                      style: TextStyle(
                                                          color: Colors.white, fontFamily: 'IranSansMed', fontSize: 15.0),
                                                    ),
                                                    onPressed: () => {
                                                      if (ekhtesasiController.text.length == 0 ||
                                                          omumiController.text.length == 0 ||
                                                          khalesController.text.length == 0 ||
                                                          sleepController.text.length == 0 ||
                                                          schoolController.text.length == 0)
                                                        EasyLoading.showToast('همه‌چی رو وارد کن')
                                                      else if (!dna.validateNumber(ekhtesasiController.text) ||
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
                                                        EasyLoading.showToast('عددایی که وارد کردی اشتباهن')
                                                      else
                                                        addReport()
                                                    },
                                                    color: daysPassed > maxDays ? Colors.redAccent : Colors.blueAccent,
                                                  ),
                                                ]).show();
                                            loadIfExists();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: widgetsEnabled
                                                ? (editMode
                                                    ? Icon(Icons.edit,
                                                        color: daysPassed > maxDays ? Colors.red.shade800 : Colors.blue.shade800)
                                                    : Icon(Icons.add_box,
                                                        color: daysPassed > maxDays ? Colors.red.shade800 : Colors.blue.shade800))
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
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 60.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
                              child: Text(
                                'داریم سعی می‌کنیم اطلاعاتت رو پیدا کنیم',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16.0, color: Colors.blueAccent.shade700, fontFamily: 'IranSansMed'),
                              ),
                            ),
                            SizedBox(height: 100, child: Lottie.asset('assets/anim/waiting.json')),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 8.0),
                              child: Text(
                                'اگه چیزی پیدا نشه...',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                              child: Text(
                                'یا اینترنتت قطعه و مشکل داره •-•\nیا فیلترشکن روشن کردی *-*\nیا قسمت نیست ^-^',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ],
                        ),
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
          backgroundColor: Colors.white,
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
                          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 0.0),
                          child: Text(
                            historyMode ? historyModeName : (leaderBoardMode ? 'نفرات برتر دیروز' : 'امیررضا عشوری'),
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
                (historyMode || leaderBoardMode)
                    ? Expanded(
                        child: historyMode
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  FadeIn(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
                                      child: Card(
                                        margin: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),
                                        elevation: 4.0,
                                        child: InkWell(
                                          customBorder: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                          onTap: () {},
                                          child: Ink(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.blueAccent,
                                                  Colors.blueAccent.shade700,
                                                ],
                                                begin: Alignment.topRight,
                                                end: Alignment.bottomLeft,
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        'رتبه‌ی دیروز: ' + userRank.toString(),
                                                        style: TextStyle(
                                                          fontSize: 18.0,
                                                          color: Colors.white,
                                                          fontFamily: 'IranSansMed',
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                      Text(
                                                        'میانگین تراز: ' + historyModeAverage.round().toString(),
                                                        style: TextStyle(
                                                          fontSize: 18.0,
                                                          fontFamily: 'IranSansMed',
                                                          color: Colors.white,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  histories != null
                                      ? Expanded(
                                          child: FadeIn(
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Color(0xFFF4FBFF),
                                                    border: Border.all(width: 1.0, color: Colors.grey.shade300),
                                                    borderRadius: BorderRadius.all(Radius.circular(12.0))),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: [
                                                      Expanded(
                                                        child: SingleChildScrollView(
                                                          scrollDirection: Axis.vertical,
                                                          child: SingleChildScrollView(
                                                            scrollDirection: Axis.horizontal,
                                                            child: DataTable(
                                                              headingRowHeight: 48.0,
                                                              dataRowColor:
                                                                  MaterialStateColor.resolveWith((states) => Color(0xFFF4FBFF)),
                                                              headingRowColor: MaterialStateColor.resolveWith(
                                                                  (states) => Colors.lightBlue.shade50),
                                                              headingTextStyle: TextStyle(
                                                                fontFamily: 'IranSansMed',
                                                                color: Colors.blue.shade800,
                                                              ),
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
                                                                ),
                                                                DataColumn(
                                                                  label: Text('عمومی'),
                                                                ),
                                                                DataColumn(
                                                                  label: Text('خالص'),
                                                                ),
                                                                DataColumn(
                                                                  label: Text('خواب'),
                                                                ),
                                                                DataColumn(
                                                                  label: Text('کلاس'),
                                                                ),
                                                                DataColumn(
                                                                  label: Text('آزاد'),
                                                                ),
                                                                DataColumn(
                                                                  label: Text('بازده'),
                                                                ),
                                                                DataColumn(
                                                                  label: Text('تراز'),
                                                                ),
                                                              ],
                                                              rows: histories!
                                                                  .map(
                                                                    (history) => DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                          Text(history.date.weekday
                                                                              .toString()
                                                                              .replaceAll('1', 'دوشنبه')
                                                                              .replaceAll('2', 'سه‌شنبه')
                                                                              .replaceAll('3', 'چهارشنبه')
                                                                              .replaceAll('4', 'پنج‌شنبه')
                                                                              .replaceAll('5', 'جمعه')
                                                                              .replaceAll('6', 'شنبه')
                                                                              .replaceAll('7', 'یک‌شنبه')),
                                                                          onTap: () {
                                                                            // write your code..
                                                                          },
                                                                        ),
                                                                        DataCell(
                                                                          Text(
                                                                            Jalali.fromDateTime(history.date).day.toString() +
                                                                                ' ' +
                                                                                dna.persianMonth(
                                                                                    Jalali.fromDateTime(history.date).month) +
                                                                                ' ' +
                                                                                Jalali.fromDateTime(history.date).year.toString(),
                                                                          ),
                                                                        ),
                                                                        DataCell(
                                                                          Text(history.ekh.toString()),
                                                                        ),
                                                                        DataCell(
                                                                          Text(history.omu.toString()),
                                                                        ),
                                                                        DataCell(
                                                                          Text(
                                                                              dna.removeTrailingZeros(history.khales).toString()),
                                                                        ),
                                                                        DataCell(
                                                                          Text(dna.removeTrailingZeros(history.sleep).toString()),
                                                                        ),
                                                                        DataCell(
                                                                          Text(
                                                                              dna.removeTrailingZeros(history.school).toString()),
                                                                        ),
                                                                        DataCell(
                                                                          Text(dna
                                                                              .removeTrailingZeros(
                                                                                  (24 - history.sleep - history.school))
                                                                              .toString()),
                                                                        ),
                                                                        DataCell(
                                                                          Text(
                                                                              dna.removeTrailingZeros(history.bazdeh).toString()),
                                                                        ),
                                                                        DataCell(
                                                                          Text(dna.removeTrailingZeros(history.score).toString()),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                  .toList(),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Divider(height: 1.0, color: Colors.grey.shade400),
                                                      Card(
                                                        color: widgetsEnabled ? Color(0xFFF4FBFF) : Colors.grey.shade500,
                                                        margin: EdgeInsets.zero,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(0.0),
                                                        ),
                                                        elevation: 0.0,
                                                        child: AbsorbPointer(
                                                          absorbing: !widgetsEnabled,
                                                          child: InkWell(
                                                            enableFeedback: widgetsEnabled,
                                                            borderRadius: BorderRadius.circular(0.0),
                                                            onTap: () {
                                                              historyModePermanent
                                                                  ? convertToMonthly(historyModeUserId)
                                                                  : convertToPermanent(historyModeUserId);
                                                            },
                                                            child: Center(
                                                              child: Padding(
                                                                  padding: const EdgeInsets.all(12.0),
                                                                  child: historyModePermanent
                                                                      ? Text(
                                                                          'تبدیل اشتراک به ماهانه',
                                                                          style: TextStyle(
                                                                              fontSize: 14.0, color: Colors.blue.shade800),
                                                                        )
                                                                      : Text('تبدیل اشتراک به سالانه',
                                                                          style: TextStyle(
                                                                              fontSize: 14.0, color: Colors.blue.shade800))),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 60.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
                                                  child: Text(
                                                    'داریم سعی می‌کنیم اطلاعات رو پیدا کنیم',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        color: Colors.blueAccent.shade700,
                                                        fontFamily: 'IranSansMed'),
                                                  ),
                                                ),
                                                SizedBox(height: 100, child: Lottie.asset('assets/anim/waiting.json')),
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 8.0),
                                                  child: Text(
                                                    'اگه چیزی پیدا نشه...',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 14.0,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                                                  child: Text(
                                                    'یا اینترنت قطعه و مشکل داره •-•\nیا فیلترشکن روشنه *-*\nیا قسمت نیست ^-^',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.grey.shade500,
                                                      fontSize: 14.0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                ],
                              )
                            : ListView.builder(
                                padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                                itemCount: allUsers == null ? 0 : allUsers!.length,
                                itemBuilder: (context, i) {
                                  return Visibility(
                                    visible: allUsers!.elementAt(i).id == 0 ? noUserRanksVisible : true,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Visibility(
                                          visible: (i == 0 || allUsers!.elementAt(i - 1).group != allUsers!.elementAt(i).group)
                                              ? true
                                              : false,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                                                child: Text(
                                                  allUsers!
                                                      .elementAt(i)
                                                      .group
                                                      .substring(0, allUsers!.elementAt(i).group.indexOf('|')),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily: 'IranSansMed',
                                                    fontSize: 16.0,
                                                    color: Colors.lightBlue.shade700,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 4.0),
                                                child: Text(
                                                  allUsers!
                                                      .elementAt(i)
                                                      .group
                                                      .substring(allUsers!.elementAt(i).group.indexOf('|') + 1),
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
                                                padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
                                                child: Card(
                                                    color: Colors.grey.shade50,
                                                    margin: EdgeInsets.zero,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20.0),
                                                    ),
                                                    elevation: 0.0,
                                                    child: Center(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text(
                                                          'دانش‌آموزی توی این گروه نداریم',
                                                          style: TextStyle(
                                                            fontSize: 13.0,
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
                                                child: Card(
                                                  color: Colors.grey.shade100,
                                                  margin: EdgeInsets.zero,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20.0),
                                                  ),
                                                  elevation: 0.0,
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(0.0, 12.0, 12.0, 12.0),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          height: 32.0,
                                                          width: 32.0,
                                                          decoration: BoxDecoration(
                                                            color: Colors.lightBlue.shade700,
                                                            shape: BoxShape.circle,
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              allUsers!.elementAt(i).id.toString(),
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                                                                child: Text(
                                                                  allUsers!.elementAt(i).name,
                                                                  style: TextStyle(
                                                                    fontFamily: 'IranSansMed',
                                                                    fontSize: 14.0,
                                                                  ),
                                                                  textAlign: TextAlign.right,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                                                                child: Text(
                                                                  'تراز: ' + allUsers!.elementAt(i).score.toInt().toString(),
                                                                  style: TextStyle(
                                                                    fontFamily: 'IranSansMed',
                                                                    fontSize: 14.0,
                                                                    color: Colors.lightBlue.shade700,
                                                                  ),
                                                                  textAlign: TextAlign.right,
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
                              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                              child: Card(
                                color: Colors.blueAccent,
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                elevation: 0.0,
                                child: InkWell(
                                    enableFeedback: widgetsEnabled,
                                    borderRadius: BorderRadius.circular(20.0),
                                    onTap: () {
                                      AlertDialog alert = AlertDialog(
                                        content: TextField(
                                          keyboardType: TextInputType.number,
                                          controller: adminPhoneController,
                                          decoration: InputDecoration(hintText: "Phone Number"),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('CANCEL'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          TextButton(
                                            child: Text('GO'),
                                            onPressed: () {
                                              getUserHistory(adminPhoneController.text);
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
                                          'دریافت تاریخچه‌ی دانش‌آموزان',
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
                              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                              child: Card(
                                color: Colors.lightGreen.shade400,
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
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
                              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                              child: Card(
                                color: Colors.redAccent.shade400,
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                elevation: 0.0,
                                child: InkWell(
                                    enableFeedback: widgetsEnabled,
                                    borderRadius: BorderRadius.circular(20.0),
                                    onTap: () {
                                      getCount();
                                    },
                                    child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          'دریافت تعداد دانش‌آموزان',
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
      EasyLoading.show(status: 'داریم اسمتو ثبت می‌کنیم');

      setState(() {
        widgetsEnabled = false;
      });

      conn = await MySqlConnection.connect(settings);

      var resultsToCheckForPhone = await conn!.query('SELECT * FROM users WHERE phone = ?', [phoneController.text]);

      if (resultsToCheckForPhone.length == 0) {
        var results;
        await conn!.query(
            'INSERT INTO `users` (`name`, `phone`, `hash`, `avg_score`, `last_payment_date`, `user_mode`, `last_rank`) VALUES (?, ?, ?, ?, CURRENT_DATE(), ?, ?);',
            [
              nameController.text,
              phoneController.text,
              hashController.text,
              0,
              0,
              0
            ]).whenComplete(() async => {
              results = await conn!.query(
                  'SELECT hash, name, user_id, avg_score, last_rank, DATEDIFF(CURRENT_DATE(), last_payment_date), user_mode FROM users WHERE phone = ?',
                  [phoneController.text]),
              if (results.length > 0)
                setState(() {
                  widgetsEnabled = true;
                  userId = results.first[2];

                  if (results.first[4] == null)
                    userRank = 0;
                  else
                    userRank = results.first[4];

                  if (results.first[3] == null)
                    avgScore = 0;
                  else
                    avgScore = (results.first[3] as double).toInt();

                  daysPassed = int.parse(results.first[5].toString());

                  permanentUser = int.parse(results.first[5].toString()) == 1;

                  name = results.first[1];
                  prefs.setInt('user_id', results.first[2]);
                  prefs.setInt('avg_score', (results.first[3] as double).toInt());
                  prefs.setString('name', results.first[1]);
                  prefs.setBool('permanent_user', permanentUser);
                  prefs.setInt('last_rank', results.first[4]);
                  nameController.clear();
                  phoneController.clear();
                  hashController.clear();
                }),
            });
      } else {
        EasyLoading.showToast(
          'قبلاً هم با این شماره ثبت‌نام شده',
        );
        setState(() {
          widgetsEnabled = true;
        });
      }
    } catch (error) {
      EasyLoading.showToast(
        'اوپس، نتونستیم به اینترنت وصل شیم',
      );
      setState(() {
        widgetsEnabled = true;
      });
    } finally {
      EasyLoading.dismiss();
      conn!.close();
    }
  }

  Future<void> signIn() async {
    try {
      EasyLoading.show(status: 'در حال بررسی اطلاعات');

      setState(() {
        widgetsEnabled = false;
      });

      conn = await MySqlConnection.connect(settings);

      var results = await conn!.query(
          'SELECT hash, name, user_id, avg_score, last_rank, DATEDIFF(CURRENT_DATE(), last_payment_date), user_mode FROM users WHERE phone = ?',
          [loginPhoneController.text]);
      if (results.length == 0) {
        EasyLoading.showToast(
          'شماره‌ت تو سایتمون نیست. ثبت نام کردی؟',
        );
        setState(() {
          widgetsEnabled = true;
        });
      } else if (results.first[0] == loginHashController.text) {
        setState(() {
          widgetsEnabled = true;
          userId = results.first[2];

          if (results.first[4] == null)
            userRank = 0;
          else
            userRank = results.first[4];

          if (results.first[3] == null)
            avgScore = 0;
          else
            avgScore = (results.first[3] as double).toInt();

          daysPassed = int.parse(results.first[5].toString());

          permanentUser = int.parse(results.first[5].toString()) == 1;

          name = results.first[1];
          prefs.setInt('user_id', results.first[2]);
          prefs.setInt('avg_score', (results.first[3] as double).toInt());
          prefs.setString('name', results.first[1]);
          prefs.setBool('permanent_user', permanentUser);
          prefs.setInt('last_rank', results.first[4]);
        });
      } else {
        EasyLoading.showToast(
          'رمز عبورت اشتباهه',
        );

        setState(() {
          widgetsEnabled = true;
        });
      }
    } catch (error) {
      EasyLoading.showToast(
        'اوپس، نتونستیم به اینترنت وصل شیم',
      );

      setState(() {
        widgetsEnabled = true;
      });
    } finally {
      conn!.close();
      EasyLoading.dismiss();
    }
  }

  Future<void> loadIfExists() async {
    firstTime = false;

    if (prefs.getBool('paid') ?? false) updatePayment();

    try {
      print('loadIfExists');

      conn = await MySqlConnection.connect(settings);

      DateTime date = DateTime.now();

      if (DateTime.now().hour < 8)
        date = DateTime.now().subtract(
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

      setState(() {
        editMode = false;
      });

      var resultsForDays = await conn!
          .query('SELECT DATEDIFF(CURRENT_DATE(), last_payment_date), user_mode FROM users WHERE user_id = ?', [userId]);
      if (resultsForDays.length > 0) {
        setState(() {
          permanentUser = int.parse(resultsForDays.first[1].toString()) == 1;
          daysPassed = int.parse(resultsForDays.first[0].toString());
        });
      }

      var results = await conn!.query(
          'SELECT ekhtesasi, omumi, khales, sleep, school FROM reports WHERE user_id_fk = ? AND date = ?;', [userId, dateString]);
      if (results.length > 0) {
        double khales = results.first[2];
        double sleep = results.first[3];
        double school = results.first[4];

        setState(() {
          editMode = true;
        });

        ekhtesasiController.text = results.first[0].toString();
        omumiController.text = results.first[1].toString();
        khalesController.text = khales == khales.truncate() ? khales.toInt().toString() : khales.toString();
        sleepController.text = sleep == sleep.truncate() ? sleep.toInt().toString() : sleep.toString();
        schoolController.text = school == school.truncate() ? school.toInt().toString() : school.toString();
      }

      var results2 = await conn!.query('SELECT last_rank FROM users WHERE user_id = ?;', [userId]);

      var resultsForHistory1 = await conn!.query(
          'SELECT date, ekhtesasi, omumi, khales, sleep, school, bazdeh, score FROM reports WHERE user_id_fk = ? ORDER BY date DESC',
          [userId]);

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
            double.parse(resultsForHistory1.elementAt(index)[6].toString()).floor().toDouble(),
            double.parse(resultsForHistory1.elementAt(index)[7].toString()).floor().toDouble(),
          ),
        );
      } else {
        histories = List<HistoryItem>.generate(
          resultsForHistory1.length,
          (index) => HistoryItem(
            DateTime.now(),
            -1,
            -1,
            -1,
            -1,
            -1,
            -1,
            -1,
          ),
        );
      }

      if (results2.length > 0) {
        setState(() {
          userRank = results2.first[0];
        });
        // fadeInController.fadeIn();
      }
    } catch (error) {
      EasyLoading.showToast('اوپس، نتونستیم به اینترنت وصل شیم');
    } finally {
      conn!.close();
      EasyLoading.dismiss();
    }
  }

  Future<void> addReport() async {
    try {
      EasyLoading.show(status: 'در حال ارسال اطلاعات');

      setState(() {
        widgetsEnabled = false;
      });

      print('addReport');

      conn = await MySqlConnection.connect(settings);

      double bazdeh = ((double.parse(khalesController.text) * 100) /
          (24 - double.parse(sleepController.text) - double.parse(schoolController.text)));

      if (editMode) {
        DateTime date = DateTime.now();

        if (DateTime.now().hour < 8)
          date = DateTime.now().subtract(
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
              dna.score(double.parse(ekhtesasiController.text), double.parse(omumiController.text),
                  double.parse(khalesController.text), bazdeh),
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
                      widgetsEnabled = true;
                    }),
                    showAlert(),
                  })
            });
      } else {
        DateTime date = DateTime.now();

        if (DateTime.now().hour < 8)
          date = DateTime.now().subtract(
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
            'INSERT INTO reports (user_id_fk, date, ekhtesasi, omumi, khales, sleep, school, bazdeh, score) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);',
            [
              userId,
              dateString,
              int.parse(ekhtesasiController.text),
              int.parse(omumiController.text),
              double.parse(khalesController.text),
              double.parse(sleepController.text),
              double.parse(schoolController.text),
              bazdeh,
              dna.score(double.parse(ekhtesasiController.text), double.parse(omumiController.text),
                  double.parse(khalesController.text), bazdeh),
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
                      widgetsEnabled = true;
                    }),
                    showAlert(),
                  })
            });
      }
    } catch (error) {
      setState(() {
        widgetsEnabled = true;
      });
    } finally {
      conn!.close();
      EasyLoading.dismiss();
    }
  }

  Future<void> getNewAverage() async {
    EasyLoading.show(status: 'در حال محاسبه‌ی میانگین تراز');

    print('getNewAverage');

    try {
      conn = await MySqlConnection.connect(settings);

      var results = await conn!.query('SELECT avg_score FROM users WHERE user_id = ?', [userId]);
      if (results.length != 0) {
        prefs.setInt('avg_score', results.first[0].toInt());
        setState(() {
          avgScore = results.first[0].toInt();
        });
      }

      loadIfExists();
    } finally {
      conn!.close();
      EasyLoading.dismiss();
    }
  }

  Future<void> getAll() async {
    try {
      EasyLoading.show(status: 'در حال دریافت لیست');

      print('getAll');
      conn = await MySqlConnection.connect(settings);

      DateTime date = DateTime.now();

      if (DateTime.now().hour < 8)
        date = DateTime.now().subtract(
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

      if (!is1) allUsers!.add(Item(0, '', 0, 0, 0, 0, 0, 2500, 0, 'غایب|زیر 2500'));
      if (!is2) allUsers!.add(Item(0, '', 0, 0, 0, 0, 0, 5000, 0, 'الله اکبر|2500 تا 5000'));
      if (!is3) allUsers!.add(Item(0, '', 0, 0, 0, 0, 0, 5500, 0, 'بسم الله|5000 تا 5500'));
      if (!is4) allUsers!.add(Item(0, '', 0, 0, 0, 0, 0, 6000, 0, 'لب مرز|5500 تا 6000'));
      if (!is5) allUsers!.add(Item(0, '', 0, 0, 0, 0, 0, 6500, 0, 'آینده‌دار|6000 تا 6500'));
      if (!is6) allUsers!.add(Item(0, '', 0, 0, 0, 0, 0, 7000, 0, 'دانا|6500 تا 7000'));
      if (!is7) allUsers!.add(Item(0, '', 0, 0, 0, 0, 0, 7500, 0, 'نخبه|7000 تا 7500'));
      if (!is8) allUsers!.add(Item(0, '', 0, 0, 0, 0, 0, 8000, 0, 'فرانخبه|7500 تا 8000'));
      if (!is9) allUsers!.add(Item(0, '', 0, 0, 0, 0, 0, 9000, 0, 'آدار|بالای 8000'));

      allUsers!.sort(mySorter);

      setState(() {
        leaderBoardMode = true;
      });
    } catch (error) {
      EasyLoading.show(status: error.toString());
    } finally {
      conn!.close();
      EasyLoading.dismiss();
    }
  }

  Future<void> getUserHistory(String phone) async {
    try {
      EasyLoading.show(status: 'در حال دریافت تاریخچه');

      print('getUserHistory');

      conn = await MySqlConnection.connect(settings);

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
            double.parse(resultsForHistory1.elementAt(index)[6].toString()).floor().toDouble(),
            double.parse(resultsForHistory1.elementAt(index)[7].toString()).floor().toDouble(),
          ),
        );
      } else {
        histories = List<HistoryItem>.generate(
          resultsForHistory1.length,
          (index) => HistoryItem(
            DateTime.now(),
            -1,
            -1,
            -1,
            -1,
            -1,
            -1,
            -1,
          ),
        );
      }
      var resultsForHistory2 =
          await conn!.query('SELECT user_id, name, avg_score, user_mode FROM users WHERE phone = ?', [phone]);

      if (resultsForHistory2.length > 0) {
        setState(() {
          historyMode = true;
          historyModeUserId = resultsForHistory2.first[0];
          historyModeName = resultsForHistory2.first[1];
          historyModeAverage = resultsForHistory2.first[2];
          historyModePermanent = int.parse(resultsForHistory2.first[3].toString()) == 1;
          historyModePhone = phone;
        });
      }
    } finally {
      conn!.close();
      EasyLoading.dismiss();
    }
  }

  Future<void> updatePayment() async {
    try {
      EasyLoading.show(status: 'در حال ذخیره آخرین پرداخت');
      conn = await MySqlConnection.connect(settings);

      await conn!.query('UPDATE users SET last_payment_date = CURRENT_DATE() WHERE user_id = ?', [userId]).whenComplete(() => {
            setState(() {
              daysPassed = 0;
            }),
            prefs.setBool('paid', false),
          });
    } catch (error) {
      EasyLoading.showToast(
        'اوپس، نتونستیم به اینترنت وصل شیم',
      );
    } finally {
      conn!.close();
      EasyLoading.dismiss();
    }
  }

  Future<void> convertToMonthly(int id) async {
    try {
      EasyLoading.show(status: 'در حال انجام');
      conn = await MySqlConnection.connect(settings);

      await conn!.query('UPDATE users SET user_mode = 0 WHERE user_id = ?', [id]).whenComplete(() => {
            EasyLoading.showToast(
              'حله',
            ),
            setState(() {
              historyModePermanent = false;
            }),
          });
    } catch (error) {
      EasyLoading.showToast(
        'اوپس، نتونستیم به اینترنت وصل شیم',
      );
    } finally {
      conn!.close();
      EasyLoading.dismiss();
    }
  }

  Future<void> convertToPermanent(int id) async {
    try {
      EasyLoading.show(status: 'در حال انجام');
      conn = await MySqlConnection.connect(settings);

      await conn!.query('UPDATE users SET user_mode = 1 WHERE user_id = ?', [id]).whenComplete(() => {
            EasyLoading.showToast(
              'حله',
            ),
            setState(() {
              historyModePermanent = true;
            }),
          });
    } catch (error) {
      EasyLoading.showToast(
        'اوپس، نتونستیم به اینترنت وصل شیم',
      );
    } finally {
      conn!.close();
      EasyLoading.dismiss();
    }
  }

  Future<void> getCount() async {
    try {
      EasyLoading.show(status: 'در حال انجام');
      conn = await MySqlConnection.connect(settings);

      Results result;

       result = await conn!.query('SELECT COUNT(*) FROM users');

      EasyLoading.showToast(
        result.first[0].toString(),
      );
    } catch (error) {
      EasyLoading.showToast(
        'اوپس، نتونستیم به اینترنت وصل شیم',
      );
    } finally {
      conn!.close();
      EasyLoading.dismiss();
    }
  }

  void showAlert() {
    Navigator.of(context).pop();
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
      groupName = 'غایب|زیر 2500';
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
      groupName = 'دانا|6500 تا 7000';
      is6 = true;
    } else if (input > 7000 && input <= 7500) {
      groupName = 'نخبه|7000 تا 7500';
      is7 = true;
    } else if (input > 7500 && input <= 8000) {
      groupName = 'فرانخبه|7500 تا 8000';
      is8 = true;
    } else {
      groupName = 'آدار|بالای 8000';
      is9 = true;
    }
    return groupName;
  }
}
