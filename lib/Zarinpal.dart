import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Request.dart';
import 'Verify.dart';

class Zarinpal {
  final headers = {'Content-Type': 'application/json'};
  var responseBody;
  VerifyZarinpal _verify = new VerifyZarinpal();
  RequestZarinpal _request = new RequestZarinpal();

  void setPaymentRequest(
      {required String merchantID,
      required num amount,
      required String mobile,
      required String email,
      required String description,
      required String callBackURL}) {
    _request.setEmail(email);
    _request.setMerchantID(merchantID);
    _request.setCallbackURL(callBackURL);
    _request.setMobile(mobile);
    _request.setDescription(description);
    _request.setAmount(amount);
  }

  void setPaymentVerify({required String merchantID, required num amount, required String authority}) {
    _verify.setAmountVerification(amount);
    _verify.setAuthorityVerification(authority);
    _verify.setMerchantIDVerification(merchantID);
  }

  Map<String, dynamic> toMapRequest() {
    return {
      "merchant_id": _request.getMerchantID(),
      "amount": _request.getAmount(),
      "callback_url": _request.getCallBackURL(),
      "description": _request.getDescription(),
      "metadata": {"mobile": _request.getMobile(), "email": _request.getEmail()}
    };
  }

  Map<String, dynamic> toMapVerifiy() {
    return {
      "merchant_id": _verify.getMerchantIDVerification(),
      "amount": _verify.getAmountVerification(),
      "authority": _verify.getAuthorityVerification(),
    };
  }

  Future<String> makePostRequest() async {
    String requestResult = '';
    var body = this.toMapRequest();
    String requestUrl = RequestZarinpal.PAYMENT_REQUEST_URL;
    String gateWayUrl;
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');

    Response response = await post(
      Uri.parse(requestUrl),
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    ).timeout(const Duration(seconds: 10), onTimeout: () {
      throw TimeoutException('The connection has timed out, Please try again!');
    });

    responseBody = response.body;
    var parsedJson = json.decode(responseBody);
    var data = parsedJson['data'];
    var error = parsedJson['errors'];
    if (error.toString() != "[]") {
      var errorcode = parsedJson['errors']['code'];
      print("$body   va  $requestUrl va $parsedJson");
      requestResult = "   شما ارور زیر را دریافت کرده اید \n$error";
    } else if (data.toString() != "[]") {
      var authority = parsedJson['data']['authority'];
      requestResult = "اتوریتی شما با موفقیت ساخته شد و به درگاه متصل می شود";
      _request.setAuthority(authority);
      print(parsedJson);

      String gateWay = RequestZarinpal.PAYMENT_GATEWAY_URL;
      gateWayUrl = "$gateWay$authority";

      if (await canLaunch(gateWayUrl)) {
        await launch(
          gateWayUrl,
          forceSafariVC: false,
          forceWebView: false,
          headers: headers,
        );
      } else {
        throw 'Could not launch $requestUrl';
      }

      print(requestResult);

    }
    return requestResult;
  }

  Future<String> makePostVerify() async {
    _verify.setAmountVerification(_request.getAmount());
    _verify.setMerchantIDVerification(_request.getMerchantID());
    _verify.setAuthorityVerification(_request.getAuthority());
    var parsedJson;
    var responseBodyVerify;
    String verifyResult = '';
    String authoityVerify = _verify.getAuthorityVerification();

    if (authoityVerify == null) {
      print("authority is null");
      verifyResult = "null";
    } else {
      final verifyUrl = RequestZarinpal.VERIFICATION_PAYMENT_URL;
      var body = this.toMapVerifiy();
      String jsonBody = json.encode(body);
      final encoding = Encoding.getByName('utf-8');

      Response response = await post(
        Uri.parse(verifyUrl),
        headers: headers,
        body: jsonBody,
        encoding: encoding,
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('The connection has timed out, Please try again!');
      });

      int statusCode = response.statusCode;
      responseBodyVerify = response.body;
      var parsedJson = json.decode(responseBodyVerify);
      print(responseBodyVerify);

      var data = parsedJson['data'];
      var error = parsedJson['errors'];
      if (data == '') {
        print("data is null");
      }

      if (error.toString() != "[]") {
        var errorcode = parsedJson['errors']['code'];
        verifyResult = " ترکنش ناموفق با کد ارور $errorcode";
        print("error is $errorcode");
      } else if (data.toString() != "[]") {
        var dataCode = parsedJson['data']['code'];

        var refId = parsedJson['data']['ref_id'];

        verifyResult = " تراکنش موفق با$dataCode  و $refId  شناسه تراکنش : ";
      }
    }
    return verifyResult.toString();
  }
}
