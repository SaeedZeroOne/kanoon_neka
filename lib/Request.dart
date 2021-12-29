import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';



class RequestZarinpal {

  static final String PAYMENT_GATEWAY_URL =
      'https://www.zarinpal.com/pg/StartPay/';
  static final String PAYMENT_REQUEST_URL =
      'https://api.zarinpal.com/pg/v4/payment/request.json';
  static final String VERIFICATION_PAYMENT_URL =
      'https://api.zarinpal.com/pg/v4/payment/verify.json';

  late String merchantID;
  late num amount;
  String mobile = "";
  String email = "";
  late String description;
  late String callBackURL;
  late String authority;
  bool isSandBox = false;
  bool isZarinGateEnable = false;

  late String _authoritySandBox;

  setAuthoritySandBox(String authoritySandBox) => this._authoritySandBox = authoritySandBox;

  String getAuthoritySandBox() {
    return _authoritySandBox;
  }
  ///////////////////////////////////////////////////////////////////////
  setIsZarinGateEnable(bool zarinGateEnable) =>
      isZarinGateEnable = zarinGateEnable;

  setMerchantID(String merchantID) => this.merchantID = merchantID;

  setIsSandBox(bool isSandBox) => this.isSandBox = isSandBox;

  setCallbackURL(String callBackURL) => this.callBackURL = callBackURL;

  setAmount(num amount) => this.amount = amount;

  setDescription(String description) => this.description = description;

  setMobile(String mobile) => this.mobile = mobile;

  setEmail(String email) => this.email = email;

  String getCallBackURL() {
    return callBackURL;
  }

  void setAuthority(String authority) {
    this.authority = authority;
  }

  num getAmount() {
    return amount;
  }

  String getDescription() {
    return description;
  }

  String getMobile() {
    return mobile;
  }

  String getMerchantID() {
    return merchantID;
  }

  String getEmail() {
    return email;
  }

  String getAuthority() {
    return authority;
  }









}