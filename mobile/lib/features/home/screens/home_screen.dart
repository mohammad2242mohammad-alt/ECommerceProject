import 'package:flutter/material.dart';

import '../widgets/home_app_bar.dart';
import '../widgets/search_box.dart';
import '../widgets/category_section.dart';
import '../widgets/banner_section.dart';
import '../widgets/product_section.dart';


class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(

        child: SingleChildScrollView(

          child: Column(

            children: const [

              HomeAppBar(),

              SizedBox(height: 12),

              SearchBox(),

              SizedBox(height: 20),

              CategorySection(),

              SizedBox(height: 20),

              BannerSection(),

              SizedBox(height: 20),

              ProductSection(),

            ],

          ),

        ),

      ),

    );

  }

}