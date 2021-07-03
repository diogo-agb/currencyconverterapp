import 'package:currencyconverterapp/widgets/drop_down.dart';
import 'package:flutter/material.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:intl/intl.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'services/api_client.dart';
import 'services/ad_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BannerAd _ad;
  bool isLoaded;

  ApiClient client = ApiClient();

  Color mainColor = Colors.blueGrey[700];
  Color secundaryColor = Colors.blue;

  List<String> currencies;
  String from;
  String to;
  TextEditingController controller = TextEditingController();

  double rate;
  String result = "";

  @override
  void initState() {
    (() async {
      List<String> list = await client.getCurrencies();
      setState(() {
        currencies = list;
      });
    })();
    to = 'BRL';
    from = 'USD';

    _ad = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: AdListener(
        onAdLoaded: (_) {
          setState(() {
            isLoaded = true;
          });
        },
        onAdFailedToLoad: (_, error) {
          print("Ad failed to load with error: $error");
        },
      ),
    );
    _ad.load();

    super.initState();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  Widget checkForAd() {
    if (isLoaded == true) {
      return Container(
        child: AdWidget(
          ad: _ad,
        ),
        width: _ad.size.width.toDouble(),
        height: _ad.size.height.toDouble(),
        alignment: Alignment.center,
      );
    } else {
      return CircularProgressIndicator();
    }
  }

  void submit(String value) async {
    rate = await client.getRate(from, to);
    print('Value: ${value.replaceAll(",", "").replaceAll("\$", "")}');
    setState(() {
      var temp = (rate *
              double.parse(value != ""
                  ? value.replaceAll(",", "").replaceAll("\$", "")
                  : "0.00"))
          .toStringAsFixed(2);
      double resultDouble = double.parse(temp);
      final oCcy = NumberFormat("#,##0.00", "en_US");
      result = oCcy.format(resultDouble);
      print(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: mainColor,
      body: SafeArea(
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/img/back.jpg'),
              fit: BoxFit.fitHeight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 18.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 200,
                    child: Text(
                      'Conversor de moedas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextField(
                          controller: controller,
                          onSubmitted: (value) {
                            submit(value);
                          },
                          inputFormatters: [
                            CurrencyTextInputFormatter(
                              locale: 'en_US',
                              symbol: '\$',
                            ),
                          ],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "\$ 0.00",
                          ),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            customDropDown(
                              currencies,
                              from,
                              (val) {
                                setState(() {
                                  from = val;
                                });
                              },
                            ),
                            ElevatedButton(
                              onPressed: () {
                                String temp = from;
                                setState(() {
                                  from = to;
                                  to = temp;
                                });
                              },
                              child: Icon(Icons.swap_horiz),
                            ),
                            customDropDown(
                              currencies,
                              to,
                              (val) {
                                setState(() {
                                  to = val;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 50.0,
                        ),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Resultado",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '\$ $result',
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  fontSize: 36,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            submit(controller.text);
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          child: Text('Consultar'),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        checkForAd(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
