class VerifyZarinpal {

  late num _amount;
  late String _authority;
  late String _merchantID;

  num getAmountVerification() {
    return _amount;
  }

  void setAmountVerification(num amount) {
    this._amount = amount;
  }

  String getAuthorityVerification() {
    return _authority;
  }

  void setAuthorityVerification(String authority) {
    this._authority = authority;
  }

  String getMerchantIDVerification() {
    return _merchantID;
  }

  void setMerchantIDVerification(String merchantID) {
    this._merchantID = merchantID;
  }
}