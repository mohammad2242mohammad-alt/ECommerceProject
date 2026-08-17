import '../models/product_model.dart';


/// سرویس محصولات
///
/// فعلاً اطلاعات تستی برمی‌گرداند.
/// بعداً این بخش به Laravel API وصل می‌شود.
class ProductService {


  Future<List<ProductModel>> getProducts() async {


    return [


      ProductModel(

        id: 1,

        name: 'Samsung Galaxy A55',

        description: 'گوشی موبایل سامسونگ با کیفیت بالا',

        price: 18000000,

        image: 'assets/images/a55.png',

      ),



      ProductModel(

        id: 2,

        name: 'ASUS VivoBook',

        description: 'لپ تاپ مناسب کار و دانشگاه',

        price: 32000000,

        image: 'assets/images/laptop.png',

      ),



      ProductModel(

        id: 3,

        name: 'Wireless Headphone',

        description: 'هدفون بی سیم با کیفیت صدا عالی',

        price: 2500000,

        image: 'assets/images/headphone.png',

      ),


    ];


  }


}