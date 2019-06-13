import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'AddProduct.dart';
import 'ProductPodo.dart';

class DisplayProducts extends StatefulWidget {
  final List<ProductDetails> products;

  DisplayProducts({this.products});

  @override
  State<StatefulWidget> createState() => DisplayProductsState();
}

class DisplayProductsState extends State<DisplayProducts> with WidgetsBindingObserver{
  String newProduct;
  bool isLoading = false;

  Map toJson(String product) => {'product': product};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchProducts();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('State $state');
    if(state == AppLifecycleState.resumed) {
      _fetchProducts();
    }
  }

  _fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get('http://192.168.42.195:8000/');
    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
        widget.products.clear();
        final jsonResponse = json.decode(response.body);
        ProductDetailsList productDetailsList =
            ProductDetailsList.fromJson(jsonResponse);
        widget.products.addAll(productDetailsList.products);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _fetchProducts();
            },
            tooltip: 'Refresh',
          )
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: widget.products == null ? 0 : widget.products.length,
              itemBuilder: (context, i) {
                return Dismissible(
                  key: Key(widget.products[i].toString() + widget.products.length.toString()),
                  onDismissed: (direction) {
                    print(i);

                    dismissCard(i);

                    Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text('Dismissed'))
                    );
                  },
                  background: Container(
                    color: Colors.red,
                  ),
                  child: buildCard(widget.products[i]),
                );
              }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add) ,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProduct())
          );
        },
      )
    );
  }

  SizedBox buildCard(ProductDetails product) {
    return SizedBox(
      height: 128.0,
      child: Card(
        child: Row(
          children: <Widget>[
            Container(
              height: 128.0,
              width: 100.0,
              margin: const EdgeInsets.all(8.0),
              child: new Image.network(
                  product.imageUrl
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 8.0),
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 220.0,
                    child: Text(
                        product.name,
                        maxLines: 2,
                        style: TextStyle(fontSize: 16.0),
                        overflow: TextOverflow.ellipsis

                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 8.0)),
                  Text(
                    'Current price: ${product.currentPrice}',
                    style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 8.0)),
                  Text(
                    'All time low: ${product.allTimeLow}',
                    style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void dismissCard(int i) {
    setState(() {
      widget.products.removeAt(i);
      print(widget.products.length);
    });
  }
}
