import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:print_app/pages/print_page.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> data = [
    {"title": "Samsung Fridge", "price": 15000, "quantity": 10},
    {"title": "Mixer Grinder", "price": 2000, "quantity": 4},
    {"title": "LG Tv", "price": 30000, "quantity": 5},
    {"title": "Voltas Ac", "price": 40000, "quantity": 10},
  ];

  final currencyFormatter = NumberFormat("\$###,###.00", "en_US");
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int _total = 0;
    _total = data.map((e) => e['price'] * e['quantity']).reduce(
          (value, element) => value + element,
        );
    return Scaffold(
      appBar: AppBar(
        title: Text("Print App"),
        backgroundColor: Colors.blue.shade300,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
            physics:
                AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            itemCount: data.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PrintPage(
                              title: data[index]['title'].toString(),
                              price: data[index]['price'],
                              quantity: data[index]['quantity'])));
                },
                child: Card(
                  elevation: 3, // Add shadow to the card
                  margin: EdgeInsets.symmetric(
                      vertical: 8, horizontal: 16), // Add margin for spacing
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.all(16), // Add padding within the ListTile
                    title: Text(
                      data[index]['title'].toString(),
                      style: TextStyle(
                        fontSize: 18, // Increase font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${currencyFormatter.format(data[index]['price'])} * ${data[index]['quantity']}",
                          style: TextStyle(
                            fontSize: 16, // Customize font size
                          ),
                        ),
                        Text(
                          currencyFormatter.format(
                              data[index]["price"] * data[index]["quantity"]),
                          style: TextStyle(
                            fontSize: 16, // Customize font size
                            fontWeight: FontWeight.bold,
                            color:
                                Colors.green, // Make the total price text green
                          ),
                        ),
                      ],
                    ),
                    // trailing:
                  ),
                ),
              );
            },
          )),
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.grey[300],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Select an Item to print ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                Icon(
                  Icons.arrow_circle_up,
                  color: Colors.blue,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
