import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class CardsPage extends StatefulWidget {
  CardsPage({Key? key}) : super(key: key);

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  Future<List> getCards() async {
    const token = "sk_test_51JUm5GEV8wtBYZgiCVBEDRysgy1U3GngTMKppIOxr4uCRIdDi0VFt9demarPgNJF4kVjKaMLphvIkaRB6QFhG8RT00zwNrUs4N";
    final url = Uri.parse("https://api.stripe.com/v1/customers/cus_K94gx7IB6UcJLB/sources");
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 30));

      // Error or Server issue
      if (response.statusCode != 200) {
        return ["error"];
      }
      var extractdata = json.decode(response.body);

      List data = extractdata["data"];

      return data;
    } on TimeoutException catch (_) {
      return ["timeout"];
    } on SocketException catch (_) {
      log("Internet issue");
      return ["internet"];
    }
  }

  Future<void> refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var _random = math.Random();
    var _getCards = getCards().then((value) => value);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              Text(
                "Credit Card List",
                style: GoogleFonts.lato(fontSize: 25),
              ),
              const SizedBox(
                height: 20,
              ),
              FutureBuilder(
                  future: _getCards,
                  builder: (context, AsyncSnapshot<List> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.data!.isEmpty) {
                      log("Empty");
                      return const Center(
                        child: Text("No Credit Card Available."),
                      );
                    }
                    if (snapshot.data![0] == "error") {
                      log("Error");
                      return const Center(
                        child: Text("Error Appears"),
                      );
                    } else if (snapshot.data![0] == "timeout") {
                      log("Timeout");
                      return const Center(
                        child: Text("Connection Timeout"),
                      );
                    } else if (snapshot.data![0] == "internet") {
                      log("Internet issue");
                      return const Center(
                        child: Text("Internet Issue"),
                      );
                    }
                    return Expanded(
                      child: RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: refresh,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          itemCount: snapshot.data!.length,
                          // itemCount: 3,
                          itemBuilder: (context, index) {
                            final Map card = snapshot.data![index];
                            return SizedBox(
                              height: 200,
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                elevation: 4,
                                // color: Colors.lightBlue,
                                // Random Color for each card
                                color: Colors.primaries[_random.nextInt(Colors.primaries.length)][_random.nextInt(9) * 100],
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      SvgPicture.asset(
                                        card["brand"] == "MasterCard" ? "Images/mastercard.svg" : "Images/visa.svg",
                                        width: 60,
                                      ),
                                      const Spacer(),
                                      Text(
                                        "****    ****     ****     ${snapshot.data![index]["last4"]}",
                                        style: GoogleFonts.poppins(fontSize: 20),
                                      ),
                                      const Spacer(),
                                      Text(
                                        "VALID THRU",
                                        style: GoogleFonts.lato(fontSize: 10, color: Colors.grey[850]),
                                      ),
                                      Text(
                                        "${card["exp_month"]}/${card["exp_year"].toString().substring(2)}",
                                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
