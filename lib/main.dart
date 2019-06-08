import 'package:flutter/material.dart';

import 'DisplayProducts.dart';

void main() {
  runApp(MaterialApp(
    title: 'Webscraper',
    home: HomePage(),
  ));
}

class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: DisplayProducts(products: new List<ProductDetails>()),
//      floatingActionButton: FloatingActionButton(
//        child: Icon(Icons.add),
//        tooltip: 'Add product',
//        onPressed: null,
//      ),
    );
  }
}
