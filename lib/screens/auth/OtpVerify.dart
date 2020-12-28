import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatApp/models/appUser/appUser.dart';

class OtpVerify extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerify> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Profile _profile = AppUser.profile;

  bool _isSend = false;
  bool _isProcessing = false;

  String _countryCode;
  String _verificationId;
  int _resendToken;

  final TextEditingController _phone = TextEditingController();
  final TextEditingController _code = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _onTapSend() async {
    final String phone = _phone.text;
    if (phone.isEmpty) return;
    _setProcessing(true);
    final PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) {
      _setProcessing(true);
      _auth.signInWithCredential(phoneAuthCredential).then((u) async {
        await _profile.init(ccode: _countryCode, phone: phone);
        _setProcessing(false);
        Navigator.pushNamedAndRemoveUntil(
            context, '/profile', (route) => false);
      }).catchError((e) {
        _setError(e.code);
        _setProcessing(false);
      });
    };

    final PhoneCodeSent codeSent = (String verificationId, int resendToken) {
      _verificationId = verificationId;
      _resendToken = resendToken;
      _setProcessing(false);
      setState(() => _isSend = true);
    };

    PhoneVerificationFailed phoneVerificationFailed =
        (FirebaseAuthException e) {
      _setError(e.code);
      _setProcessing(false);
    };

    PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout =
        (String verificationId) {};

    await _auth.verifyPhoneNumber(
        phoneNumber: _countryCode + _phone.text,
        //phoneNumber: '+16505556789',
        verificationCompleted: verificationCompleted,
        verificationFailed: phoneVerificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: autoRetrievalTimeout);
  }

  void _onTapVerify() async {
    final String phone = _phone.text;
    final String code = _code.text;
    if (code.length != 6) return;
    _setProcessing(true);
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: _verificationId, smsCode: code);
    _auth.signInWithCredential(phoneAuthCredential).then((u) async {
      await _profile.init(ccode: _countryCode, phone: phone);
      _setProcessing(false);
      Navigator.pushNamedAndRemoveUntil(context, '/profile', (route) => false);
    }).catchError((e) {
      _setError(e.code);
      _setProcessing(false);
    });

    // _addUser(await _auth.signInWithCredential(phoneAuthCredential));
  }

  void _onTapResend() {
    _setProcessing(false);
    setState(() => _isSend = false);
  }

  void _setProcessing(bool v) {
    setState(() => _isProcessing = v);
  }

  void _setError(String error) {
    final snackBar = SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text(
        error.replaceAll('-', '\t'),
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(seconds: 20),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    Widget _sendOtp = ListView(
      children: [
        SizedBox(
            // height: size.height * .15,
            ),
        SizedBox(
          height: size.height * .25,
          child: Image.asset('assets/images/otp.png'),
        ),
        Container(
          padding: EdgeInsets.only(top: size.height * .1),
          child: Text('OTP Verifiaction',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline1),
        ),
        Container(
          padding: EdgeInsets.only(top: size.height * .02),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyText1,
              text: 'We will send',
              children: [
                TextSpan(
                    text: '\tOne Time Password',
                    children: [
                      TextSpan(
                          text: '\non this number.',
                          style: Theme.of(context).textTheme.bodyText1)
                    ],
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black))
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
              top: size.height * .05, bottom: size.height * .01),
          child: Text(
            'Enter Mobile Number',
            style: Theme.of(context).textTheme.bodyText1,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
            padding: EdgeInsets.symmetric(horizontal: size.width * .1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                    flex: 1,
                    child: CountryCodePicker(
                      padding: EdgeInsets.only(right: 10),
                      //padding: EdgeInsets.only(top: size.height * .035),
                      initialSelection: 'US',
                      flagWidth: 40,
                      textStyle: TextStyle(fontSize: 20),
                      onInit: (v) => _countryCode = v.dialCode,
                      onChanged: (v) => _countryCode = v.dialCode,
                    )),
                Flexible(
                    flex: 2,
                    child: TextField(
                      keyboardType: TextInputType.phone,
                      cursorColor: Colors.green,
                      style: TextStyle(fontSize: 20),
                      controller: _phone,
                      decoration: InputDecoration(

                          //hoverColor: Colors.grey,
                          ),
                    ))
              ],
            )),
        Container(
            padding: EdgeInsets.symmetric(
                vertical: size.height * .1, horizontal: size.width * .3),
            child: _isProcessing
                ? Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.green)))
                : RaisedButton(
                    onPressed: _onTapSend,
                    child: Text(
                      'Send',
                      style: Theme.of(context).textTheme.button,
                    ),
                  ))
      ],
    );

    Widget _verifyOtp = ListView(
      children: [
        // Align(
        //   alignment: Alignment.topLeft,
        //   child: IconButton(
        //     onPressed: () => setState(() => _isSend = false),
        //     icon: Icon(Icons.arrow_back, size: 35),
        //   ),
        // ),
        SizedBox(
            // height: size.height * .15,
            ),
        SizedBox(
          height: size.height * .25,
          child: Image.asset('assets/images/otp.png'),
        ),
        Container(
          padding: EdgeInsets.only(top: size.height * .1),
          child: Text('OTP Verifiaction',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline1),
        ),
        Container(
          padding: EdgeInsets.only(
              top: size.height * .04, bottom: size.height * .02),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyText1,
              text: 'Enter OTP send to',
              children: [
                TextSpan(
                    text: '\t$_countryCode\t${_phone.text}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black))
              ],
            ),
          ),
        ),
        Container(
            padding: EdgeInsets.symmetric(horizontal: size.width * .2),
            child: PinInputTextField(
                controller: _code,
                pinLength: 6,
                decoration: UnderlineDecoration(
                  colorBuilder:
                      PinListenColorBuilder(Colors.green, Colors.grey),
                ))),
        Container(
          padding: EdgeInsets.only(top: size.height * .05),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: "Didn't recive the OTP?",
                style: Theme.of(context).textTheme.bodyText1,
                children: [
                  TextSpan(
                      text: '\tResend',
                      recognizer: TapGestureRecognizer()..onTap = _onTapResend,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold))
                ]),
          ),
        ),
        Container(
            padding: EdgeInsets.symmetric(
                vertical: size.height * .05, horizontal: size.width * .3),
            child: _isProcessing
                ? Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.green)))
                : RaisedButton(
                    onPressed: _onTapVerify,
                    child: Text(
                      'Verify',
                      style: Theme.of(context).textTheme.button,
                    ),
                  ))
      ],
    );
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedSwitcher(
          duration: Duration(seconds: 1),
          child: _isSend ? _verifyOtp : _sendOtp,
        ),
      ),
    );
  }
}
