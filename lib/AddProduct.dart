import 'dart:convert';

import 'package:flutter/material.dart';

import 'ProductPodo.dart';
import 'package:http/http.dart' as http;

class AddProduct extends StatefulWidget {
  @override
  AddProductState createState() {
    return AddProductState();
  }
}

class AddProductState extends State<AddProduct> {
  ProductDetails product;
  bool fetchingData = true;
  bool hasMadeARequest = false;
  final String url = 'http://192.168.42.195:8000/';
  String productUrl;

  final mTextController = TextEditingController();

  _fetchData() async {
    setState(() {
      fetchingData = true;
      hasMadeARequest = true;
    });

    String jsonBody = json.encode({
      'product': productUrl,
    });

    final response = await http.post(url, body: jsonBody);
    if(response.statusCode == 200) {
      setState(() {
        fetchingData = false;
        product = ProductDetails.fromJson(json.decode(response.body));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add product'),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: mTextController,
            decoration: InputDecoration(
              hintText: 'Enter product url',
              suffixIcon:
                  IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        productUrl = mTextController.text;
                        _fetchData();
                      }
                  ),
            ),
          ),
          buildContentUi(),
        ],
      ),
    );
  }

  Widget buildContentUi() {
    if (fetchingData && hasMadeARequest) {
      return Container(
        child: Center(
        child: CircularProgressIndicator(),
      ));
    }

    if (!fetchingData) {
      return Column(
        children: <Widget>[
          Container(
            height: 250.0,
            decoration: BoxDecoration(
              color: Colors.red,
            ),
          ),
          Container(
              margin: const EdgeInsets.all(4.0),
              child: Text(
                product.name,
                style: TextStyle(fontSize: 18.0),
              )),
          Container(
            margin: const EdgeInsets.all(4.0),
            child: Text(
              product.currentPrice,
              style: TextStyle(fontSize: 12.0),
            )
          )
        ],
      );
    }

    return Container(

    );
  }
}
