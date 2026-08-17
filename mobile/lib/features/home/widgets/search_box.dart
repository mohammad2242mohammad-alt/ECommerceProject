import 'package:flutter/material.dart';

/// جعبه جستجوی محصولات.
class SearchBox extends StatelessWidget {

  const SearchBox({super.key});


  @override
  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.all(16),

      child: TextField(

        decoration: InputDecoration(

          hintText: 'جستجوی محصول',

          prefixIcon: const Icon(
            Icons.search,
          ),


          border: OutlineInputBorder(

            borderRadius: BorderRadius.circular(12),

          ),

        ),

      ),

    );

  }

}