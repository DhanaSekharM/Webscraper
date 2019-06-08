import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;



class ProductDetailsList {
  final List<ProductDetails> products;

  ProductDetailsList({this.products});

  factory ProductDetailsList.fromJson(List<dynamic> parsedJson) {
    List<ProductDetails> products = new List<ProductDetails>();
    products = parsedJson.map((i) => ProductDetails.fromJson(i)).toList();
    return ProductDetailsList(
      products: products
    );
  }


}

class ProductDetails {
  final String name;
  final String productUrl;
  final String currentPrice;
  final String allTimeLow;

  const ProductDetails({this.productUrl, this.allTimeLow, this.name, this.currentPrice});

  factory ProductDetails.fromJson(Map<String, dynamic> parsedJson) {
    return ProductDetails(
      name: parsedJson['product_name'],
      productUrl: parsedJson['product_json'],
      currentPrice: parsedJson['product_price'],
      allTimeLow: parsedJson['all_time_low']
    );
  }
}

Future<Post> fetchPost() async {
  final response =
      await http.get('https://jsonplaceholder.typicode.com/posts/1');

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    return Post.fromJson(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  Post({this.userId, this.id, this.title, this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}

class ProductItem extends StatelessWidget {
  final ProductDetails product;

  const ProductItem({this.product});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128.0,
      child: Card(
        child: Row(
          children: <Widget>[
            Container(
              height: 128.0,
              width: 100.0,
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(color: Colors.red),
            ),
            Container(
              margin: const EdgeInsets.only(top: 8.0),
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                      Text(
                    product.name,
                    style: TextStyle(fontSize: 16.0),
                    overflow: TextOverflow.clip,
                  ),
                  const Padding(padding: EdgeInsets.only(top: 4.0)),
                  Text(
                    product.currentPrice,
                    style: TextStyle(fontSize: 10.0),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 4.0)),
                  Text(
                    'Rating',
                    style: TextStyle(fontSize: 10.0),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DisplayProducts extends StatefulWidget {
  final List<ProductDetails> products;

  DisplayProducts({this.products});

  @override
  State<StatefulWidget> createState() => DisplayProductsState();
}

class DisplayProductsState extends State<DisplayProducts> {
  String newProduct;
  bool isLoading = false;

  Map toJson(String product) => {'product': product};


  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  _fetchData(String newProduct) async {
    setState(() {
      isLoading = true;
    });
    String body = jsonEncode({
      'product': newProduct,
    });
    final response = await http.post('http://192.168.42.195:8000/', body: body);
    if (response.statusCode == 200) {
      print(body);
      setState(() {
        isLoading = false;
        print(json.decode(response.body));
        Map<String, dynamic> data =
            json.decode(response.body.toString()) as Map<String, dynamic>;
        widget.products.add(ProductDetails(
            name: data['product_name'],
            currentPrice: (data['price']).toString()));
      });
    }
  }

  _fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    final response  = await http.get('http://192.168.42.195:8000/');
    if(response.statusCode == 200) {
      setState(() {
        isLoading = false;
        widget.products.clear();
        final jsonResponse = json.decode(response.body);
        ProductDetailsList productDetailsList = ProductDetailsList.fromJson(jsonResponse);
        widget.products.addAll(productDetailsList.products);
      });

    }
  }

  _handleFabAddItemClick(ProductDetails newProduct) {
    setState(() {
      if (widget.products == null) {
        widget.products[0] = newProduct;
        return;
      }
      widget.products.add(newProduct);
    });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.products.length);
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: widget.products == null ? 0 : widget.products.length,
              itemBuilder: (context, i) {
                return ProductItem(
                  product: widget.products[i],
                );
              }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: 'Add product',
        onPressed: () {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    title: Text('Enter product name or url'),
                    content: TextField(
                      onSubmitted: (String input) {
                        newProduct = input;
                      },
                    ),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () {
                          _fetchData(newProduct);
//                          _handleFabAddItemClick(ProductDetails(
//                              name: newProduct, currentPrice: 'price'));
                          Navigator.of(context).pop();
                        },
                        child: Text('Add'),
                      )
                    ],
                  ));
        },
      ),
    );
  }
}
