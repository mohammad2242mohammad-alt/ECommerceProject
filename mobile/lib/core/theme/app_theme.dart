import 'package:flutter/material.dart';



class AppTheme {

  AppTheme._();



  static ThemeData lightTheme = ThemeData(

    useMaterial3: true,


    colorScheme: ColorScheme.fromSeed(

      seedColor:
          const Color(0xFFE6123D),

      brightness:
          Brightness.light,

    ),



    scaffoldBackgroundColor:
        const Color(0xFFF5F5F5),





    appBarTheme:
        const AppBarTheme(

      centerTitle:
          true,


      elevation:
          0,


      scrolledUnderElevation:
          0,


      backgroundColor:
          Colors.white,


      surfaceTintColor:
          Colors.transparent,


      foregroundColor:
          Color(0xFF212121),

    ),





    cardTheme:
        CardThemeData(

      color:
          Colors.white,


      elevation:
          1,


      shadowColor:
          Colors.black12,


      surfaceTintColor:
          Colors.transparent,


      shape:
          RoundedRectangleBorder(

        borderRadius:
            BorderRadius.circular(14),

      ),

    ),





    filledButtonTheme:
        FilledButtonThemeData(

      style:
          FilledButton.styleFrom(

        backgroundColor:
            const Color(0xFFE6123D),


        foregroundColor:
            Colors.white,


        elevation:
            0,


        padding:
            const EdgeInsets.symmetric(

          horizontal:
              22,

          vertical:
              14,

        ),



        shape:
            RoundedRectangleBorder(

          borderRadius:
              BorderRadius.circular(10),

        ),

      ),

    ),






    outlinedButtonTheme:
        OutlinedButtonThemeData(

      style:
          OutlinedButton.styleFrom(

        foregroundColor:
            const Color(0xFFE6123D),


        side:
            const BorderSide(

          color:
              Color(0xFFE6123D),

        ),


        shape:
            RoundedRectangleBorder(

          borderRadius:
              BorderRadius.circular(10),

        ),

      ),

    ),






    inputDecorationTheme:
        InputDecorationTheme(

      filled:
          true,


      fillColor:
          Colors.white,


      contentPadding:
          const EdgeInsets.symmetric(

        horizontal:
            16,

        vertical:
            15,

      ),




      border:
          OutlineInputBorder(

        borderRadius:
            BorderRadius.circular(12),


        borderSide:
            const BorderSide(

          color:
              Color(0xFFE0E0E0),

        ),

      ),





      enabledBorder:
          OutlineInputBorder(

        borderRadius:
            BorderRadius.circular(12),


        borderSide:
            const BorderSide(

          color:
              Color(0xFFE0E0E0),

        ),

      ),





      focusedBorder:
          OutlineInputBorder(

        borderRadius:
            BorderRadius.circular(12),


        borderSide:
            const BorderSide(

          color:
              Color(0xFFE6123D),

          width:
              1.5,

        ),

      ),

    ),





    navigationBarTheme:
        NavigationBarThemeData(

      backgroundColor:
          Colors.white,


      indicatorColor:
          const Color(0xFFFFE4EA),


      labelTextStyle:
          WidgetStateProperty.all(

        const TextStyle(

          fontSize:
              12,

          fontWeight:
              FontWeight.w600,

        ),

      ),

    ),






    dividerTheme:
        const DividerThemeData(

      color:
          Color(0xFFEAEAEA),

      thickness:
          1,

    ),






    textTheme:
        const TextTheme(



      headlineSmall:
          TextStyle(

        fontSize:
            24,

        fontWeight:
            FontWeight.w800,

        color:
            Color(0xFF212121),

      ),





      titleLarge:
          TextStyle(

        fontSize:
            18,

        fontWeight:
            FontWeight.w700,

        color:
            Color(0xFF212121),

      ),





      bodyLarge:
          TextStyle(

        color:
            Color(0xFF212121),

      ),





      bodyMedium:
          TextStyle(

        color:
            Color(0xFF757575),

      ),

    ),





    iconTheme:
        const IconThemeData(

      color:
          Color(0xFF424242),

    ),

  );

}