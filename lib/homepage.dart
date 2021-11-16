import 'package:dart_mysql/dart_mysql.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jalali_calendar/jalali_calendar.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DNA.dart';
import 'item.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final omumiController = TextEditingController();
  final ekhtesasiController = TextEditingController();
  final khalesController = TextEditingController();
  final nakhalesController = TextEditingController();
  final ssnController = TextEditingController();
  final passController = TextEditingController();

  List<Item>? allUsers;
  List<Item> validatedUsers = List<Item>.empty();

  late SharedPreferences prefs;
  MySqlConnection? conn;

  String ssn = '';
  String name = '';
  String date = '';

  bool loginWidgetsEnabled = true;
  bool justSent = false;
  bool adminMode = false;
  bool noUserRanksVisible = true;

  bool is1 = false,
      is2 = false,
      is3 = false,
      is4 = false,
      is5 = false,
      is6 = false,
      is7 = false,
      is8 = false,
      is9 = false;

  Future<String> getSSN() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      ssn = prefs.getString('ssn') ?? '';
      name = prefs.getString('name') ?? '';
      if (name != '')
        name = name + '، دمت گرم!';
      else
        name = 'دمت گرم!';
    });
    return ssn;
  }

  DNA dna = new DNA();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.grey.shade100,
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
      future: getSSN(),
      builder: (context, snapshot) {
        if (adminMode)
          return adminModeWidget();
        else if (justSent)
          return successWidget();
        else {
          if (snapshot.hasData) {
            if (ssn != '') {
              PersianDate persianDate = PersianDate();
              date = persianDate.weekdayname.toString() +
                  ' ' +
                  persianDate.day.toString() +
                  ' ' +
                  persianDate.monthname.toString() +
                  ' ' +
                  persianDate.year.toString();
              return sendNumbersWidget();
            } else
              return loginWidget();
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

  Widget loginWidget() {
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
                    enabled: loginWidgetsEnabled,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      LengthLimitingTextInputFormatter(10),
                    ],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "کد ملی",
                      border: InputBorder.none,
                      suffixIcon: Icon(
                        Icons.text_fields_outlined,
                        color: Colors.white,
                      ),
                      prefixIcon: Icon(
                        Icons.password_outlined,
                      ),
                    ),
                    textAlign: TextAlign.center,
                    controller: ssnController,
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
                    enabled: loginWidgetsEnabled,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      LengthLimitingTextInputFormatter(4),
                    ],
                    keyboardType: TextInputType.number,
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
                    controller: passController,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 0.0),
                child: Text(
                  '\u202E' +
                      dna.createAnagram(
                          'برای ورود به نرم‌افزار، کد ملی و رمز عبور خود را وارد کنید. اگر رمز عبوری ندارید، می‌توانید آن را از مشاور خود دریافت کنید.'),
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
                  color: loginWidgetsEnabled
                      ? Colors.green.shade700
                      : Colors.grey.shade500,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 0.0,
                  child: AbsorbPointer(
                    absorbing: !loginWidgetsEnabled,
                    child: InkWell(
                        enableFeedback: loginWidgetsEnabled,
                        borderRadius: BorderRadius.circular(20.0),
                        onTap: () {
                          if (ssnController.text.length != 10)
                            Fluttertoast.showToast(
                                msg: "کد ملی واردشده کوتاه است!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 15.0);
                          else if (ssnController.text.length == 0 ||
                              passController.text.length == 0)
                            Fluttertoast.showToast(
                                msg: "کد ملی و رمز عبور را وارد کنید!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 15.0);
                          else if (ssnController.text == '9611001079' &&
                              passController.text == '1034') {
                            setState(() {
                              adminMode = true;
                            });
                            setState(() {});
                          } else
                            connectToDatabase();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: loginWidgetsEnabled
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

  Widget sendNumbersWidget() {
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 32.0),
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
                          enabled: loginWidgetsEnabled,
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
                              Icons.timer,
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
                          enabled: loginWidgetsEnabled,
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
                              Icons.timer,
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
                                'مجموع زمان‌هایی از امروز را که در آن دروس اختصاصی و عمومی مطالعه کردید را به ترتیب در کادرهای بالا وارد کنید.'),
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
                          enabled: loginWidgetsEnabled,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9\.]')),
                          ],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "زمان خالص امروز",
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
                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                      child: Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 0.0,
                        child: TextField(
                          enabled: loginWidgetsEnabled,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9\.]')),
                          ],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "زمان آزاد امروز",
                            suffixIcon: Icon(
                              Icons.text_fields_outlined,
                              color: Colors.white,
                            ),
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.gamepad_outlined,
                            ),
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14.0),
                          controller: nakhalesController,
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
                  color: loginWidgetsEnabled
                      ? Colors.green.shade700
                      : Colors.grey.shade500,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 0.0,
                  child: AbsorbPointer(
                    absorbing: !loginWidgetsEnabled,
                    child: InkWell(
                        enableFeedback: loginWidgetsEnabled,
                        borderRadius: BorderRadius.circular(20.0),
                        onTap: () {
                          if (ekhtesasiController.text.length == 0 ||
                              omumiController.text.length == 0 ||
                              khalesController.text.length == 0 ||
                              nakhalesController.text.length == 0)
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
                              !dna.validateNumber(nakhalesController.text) ||
                              double.parse(nakhalesController.text) <= 0 ||
                              double.parse(khalesController.text) > 24 ||
                              double.parse(nakhalesController.text) > 24 ||
                              double.parse(khalesController.text) >
                                  double.parse(nakhalesController.text))
                            Fluttertoast.showToast(
                                msg: "اعداد واردشده صحیح نیستند!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 15.0);
                          else
                            uploadValues();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: loginWidgetsEnabled
                              ? Text(
                                  'ارسال اطلاعات به مشاور',
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
                      enableFeedback: loginWidgetsEnabled,
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          getAll();
                        },
                        icon: Icon(Icons.download_outlined),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            noUserRanksVisible = !noUserRanksVisible;
                          });
                        },
                        icon: Icon(Icons.hide_image_outlined),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: ListView.builder(
                        itemCount: allUsers == null ? 0 : allUsers!.length,
                        itemBuilder: (context, i) {
                          return Visibility(
                            visible: allUsers!.elementAt(i).id == 0
                                ? noUserRanksVisible
                                : true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Visibility(
                                  visible: (i == 0 ||
                                          allUsers!.elementAt(i - 1).group !=
                                              allUsers!.elementAt(i).group)
                                      ? true
                                      : false,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
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
                                            color: Colors.lightBlue.shade700,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
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
                                        padding: const EdgeInsets.fromLTRB(
                                            16.0, 4.0, 16.0, 4.0),
                                        child: Card(
                                            color: Colors.grey.shade300,
                                            margin: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                            elevation: 0.0,
                                            child: Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
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
                                        padding: const EdgeInsets.fromLTRB(
                                            16.0, 4.0, 16.0, 4.0),
                                        child: Card(
                                          margin: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          elevation: 0.0,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0.0, 12.0, 12.0, 12.0),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 32.0,
                                                  width: 32.0,
                                                  decoration: BoxDecoration(
                                                    color: Colors
                                                        .lightBlue.shade700,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      allUsers!
                                                          .elementAt(i)
                                                          .id
                                                          .toString(),
                                                      style: TextStyle(
                                                        color: Colors.white,
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
                                                                  .elementAt(i)
                                                                  .name,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'IranSansMed',
                                                                fontSize: 14.0,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                            ),
                                                            Text(
                                                              'تراز: ' +
                                                                  (allUsers!
                                                                          .elementAt(
                                                                              i)
                                                                          .score
                                                                          .round())
                                                                      .toString(),
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade500,
                                                                fontSize: 12.0,
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
                                                                  (allUsers!
                                                                          .elementAt(
                                                                              i)
                                                                          .ekh
                                                                          .round())
                                                                      .toString(),
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade500,
                                                                fontSize: 12.0,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                            ),
                                                            Text(
                                                              'عمومی: ' +
                                                                  (allUsers!
                                                                          .elementAt(
                                                                              i)
                                                                          .omu
                                                                          .round())
                                                                      .toString(),
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade500,
                                                                fontSize: 12.0,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                            ),
                                                            Text(
                                                              'زمان خالص: ' +
                                                                  (allUsers!
                                                                          .elementAt(
                                                                              i)
                                                                          .khales
                                                                          .round())
                                                                      .toString(),
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade500,
                                                                fontSize: 12.0,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                            ),
                                                            Text(
                                                              'زمان آزاد: ' +
                                                                  (allUsers!
                                                                          .elementAt(
                                                                              i)
                                                                          .nakhales
                                                                          .round())
                                                                      .toString(),
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade500,
                                                                fontSize: 12.0,
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
                        }))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> connectToDatabase() async {
    try {
      setState(() {
        loginWidgetsEnabled = false;
      });
      var settings = new ConnectionSettings(
          host: '158.58.187.220',
          port: 3306,
          user: 'reportadmin',
          password: '3.1415926535Takht',
          timeout: Duration(seconds: 5),
          db: 'adarbase_reportdb');
      conn = await MySqlConnection.connect(settings);
      var results = await conn!.query(
          'SELECT pass, username FROM users WHERE ssn = ?',
          [ssnController.text]);
      if (results.length == 0) {
        Fluttertoast.showToast(
            msg: "کد ملی در دیتابیس موجود نیست!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 15.0);
        setState(() {
          loginWidgetsEnabled = true;
        });
      } else if (results.first[0] == passController.text) {
        Fluttertoast.showToast(
            msg: "ورود موفقیت‌آمیز بود!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green.shade700,
            textColor: Colors.white,
            fontSize: 15.0);
        setState(() {
          loginWidgetsEnabled = true;
          prefs.setString('ssn', ssnController.text);
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
          loginWidgetsEnabled = true;
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
        loginWidgetsEnabled = true;
      });
    }
  }

  Future<void> uploadValues() async {
    try {
      setState(() {
        loginWidgetsEnabled = false;
      });
      var settings = new ConnectionSettings(
          host: '158.58.187.220',
          port: 3306,
          user: 'reportadmin',
          password: '3.1415926535Takht',
          timeout: Duration(seconds: 5),
          db: 'adarbase_reportdb');
      if (conn == null) conn = await MySqlConnection.connect(settings);

      await conn!.query(
          'UPDATE users SET ekhtesasi = ?, omumi = ?, khales = ?, nakhales = ?, bazdeh = ?, score = ? WHERE ssn = ?',
          [
            double.parse(ekhtesasiController.text),
            double.parse(omumiController.text),
            double.parse(khalesController.text),
            double.parse(nakhalesController.text),
            ((double.parse(khalesController.text) * 100) /
                double.parse(nakhalesController.text)),
            dna.score(
                double.parse(ekhtesasiController.text),
                double.parse(omumiController.text),
                ((double.parse(khalesController.text) * 100) /
                    double.parse(nakhalesController.text))),
            ssn
          ]).whenComplete(() => {
            setState(() {
              justSent = true;
              ekhtesasiController.clear();
              omumiController.clear();
              khalesController.clear();
              nakhalesController.clear();
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
        loginWidgetsEnabled = true;
      });
    }
  }

  Future<void> getAll() async {
    try {
      var settings = new ConnectionSettings(
          host: '158.58.187.220',
          port: 3306,
          user: 'reportadmin',
          password: '3.1415926535Takht',
          timeout: Duration(seconds: 5),
          db: 'adarbase_reportdb');
      if (conn == null) conn = await MySqlConnection.connect(settings);
      var results = await conn!.query(
          'SELECT username, ekhtesasi, omumi, khales, nakhales, score, validated FROM users ORDER BY score DESC');

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
          returnGroupName(results.elementAt(index)[5]),
        ),
      );

      if (!is1)
        allUsers!.add(Item(
            0, '', 0, 0, 0, 0, 2500, 0, 'انا لله و انا الیه راجعون|زیر 2500'));
      if (!is2)
        allUsers!
            .add(Item(0, '', 0, 0, 0, 0, 5000, 0, 'الله اکبر|2500 تا 5000'));
      if (!is3)
        allUsers!
            .add(Item(0, '', 0, 0, 0, 0, 5500, 0, 'بسم الله|5000 تا 5500'));
      if (!is4)
        allUsers!.add(Item(0, '', 0, 0, 0, 0, 6000, 0, 'لب مرز|5500 تا 6000'));
      if (!is5)
        allUsers!
            .add(Item(0, '', 0, 0, 0, 0, 6500, 0, 'آینده‌دار|6000 تا 6500'));
      if (!is6)
        allUsers!.add(Item(0, '', 0, 0, 0, 0, 7000, 0, 'نخبه|6500 تا 7000'));
      if (!is7)
        allUsers!.add(Item(0, '', 0, 0, 0, 0, 7500, 0, 'فرانخبه|7000 تا 7500'));
      if (!is8)
        allUsers!.add(Item(0, '', 0, 0, 0, 0, 8000, 0, 'شاه‌تست|7500 تا 8000'));
      if (!is9)
        allUsers!.add(Item(0, '', 0, 0, 0, 0, 9000, 0, 'آدار|بالای 8000'));

      allUsers!.sort(mySorter);
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
