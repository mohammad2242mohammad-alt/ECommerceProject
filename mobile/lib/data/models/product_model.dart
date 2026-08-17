// مدل محصول فروشگاه
//
// این کلاس ساختار اطلاعات یک محصول را مشخص می‌کند.
// بعداً اطلاعات از Laravel API دریافت می‌شود.

class ProductModel {


  // شناسه محصول
  final int id;


  // نام محصول
  final String name;


  // توضیحات محصول
  final String description;


  // قیمت محصول
  final int price;


  // تصویر محصول
  final String image;



  // سازنده مدل محصول
  const ProductModel({

    required this.id,

    required this.name,

    required this.description,

    required this.price,

    required this.image,

  });



  // تبدیل JSON دریافتی از API به مدل Flutter
  factory ProductModel.fromJson(Map<String, dynamic> json) {


    return ProductModel(

      id: json['id'],

      name: json['name'],

      description: json['description'],

      price: json['price'],

      image: json['image'],

    );

  }


}