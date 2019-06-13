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
  final String imageUrl;

  const ProductDetails({this.productUrl, this.allTimeLow, this.name, this.currentPrice, this.imageUrl});

  factory ProductDetails.fromJson(Map<String, dynamic> parsedJson) {
    return ProductDetails(
        name: parsedJson['product_name'],
        productUrl: parsedJson['product_json'],
        currentPrice: parsedJson['product_price'],
        allTimeLow: parsedJson['all_time_low'],
        imageUrl: parsedJson['image_url']
    );
  }
}