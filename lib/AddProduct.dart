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

  final _textController = TextEditingController();
  Widget clearIcon = Container();

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      if (_textController.text.length > 0) {
        setState(() {
          clearIcon = Icon(Icons.clear);
        });
      }
      if (_textController.text.length == 0) {
        setState(() {
          clearIcon = Container();
        });
      }
    });
  }

  _fetchData() async {
    setState(() {
      fetchingData = true;
      hasMadeARequest = true;
    });

    String jsonBody = json.encode({
      'product': productUrl,
    });

    final response = await http.post(url, body: jsonBody);
    if (response.statusCode == 200) {
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
          buildTextField(),
          buildContentUi(),
        ],
      ),
    );
  }

  TextField buildTextField() {
    return TextField(
      autofocus: true,
      textInputAction: TextInputAction.search,
      controller: _textController,
      onSubmitted: (String value) {
        productUrl = _textController.text;
        _fetchData();
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.all(4.0),
        hintText: 'Enter product url',
        hintStyle: TextStyle(),
        suffixIcon: IconButton(
            icon: clearIcon,
            onPressed: () {
              _textController.clear();
            }),
      ),
    );
  }

  Widget buildContentUi() {
    if (fetchingData && hasMadeARequest) {
      return Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!fetchingData) {

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(12.0),
            height: 200.0,
            child: Center(
              child: new Image.network(
                product.imageUrl.replaceFirst('128/128', '400/400'),
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          Container(
              margin: const EdgeInsets.only(left: 8.0, top: 4.0, right: 4.0, bottom: 4.0),
              child: Text(
                product.name,
                style: TextStyle(fontSize: 18.0),
              )),
          Container(
              margin: const EdgeInsets.only(top: 12.0, left: 8.0),
              child: Text(
                'Current price: ${product.currentPrice}',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ))
        ],
      );
    }

    return Container();
  }
}
