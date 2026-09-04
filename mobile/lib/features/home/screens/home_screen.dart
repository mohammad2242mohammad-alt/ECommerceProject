import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routes/app_routes.dart';
import '../../../providers/store_providers.dart';
import '../../../shared/widgets/store_widgets.dart';
import '../../products/widgets/product_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('فروشگاه اینترنتی'),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.favorites),
            icon: const Icon(Icons.favorite_border),
          ),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.cart),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, AppRoutes.products);
          }

          if (index == 2) {
            Navigator.pushNamed(context, AppRoutes.cart);
          }

          if (index == 3) {
            Navigator.pushNamed(context, AppRoutes.orders);
          }

          if (index == 4) {
            Navigator.pushNamed(context, AppRoutes.profile);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'خانه',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            label: 'محصولات',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'سبد',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'سفارش‌ها',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'حساب',
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(homeProvider);
        },

        child: home.when(

          loading: () =>
              const Center(child: CircularProgressIndicator()),


          error: (error, _) {
            return ListView(
              children: [
                SizedBox(
                  height: 500,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        FilledButton(
                          onPressed: () {
                            ref.invalidate(homeProvider);
                          },
                          child: const Text(
                            'تلاش مجدد',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },


          data: (data) {

            return ListView(
              padding:
                  const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    30,
                  ),

              children: [

                TextField(
                  textInputAction:
                      TextInputAction.search,

                  onSubmitted: (value) {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.products,
                      arguments: {
                        'search': value,
                      },
                    );
                  },

                  decoration:
                      const InputDecoration(
                    hintText:
                        'جستجو در محصولات',

                    prefixIcon:
                        Icon(Icons.search),
                  ),
                ),


                const SizedBox(height: 18),



                if (data.banners.isNotEmpty)

                  SizedBox(
                    height: 165,

                    child: PageView.builder(

                      itemCount:
                          data.banners.length,

                      itemBuilder:
                          (context, index) {

                        final banner =
                            data.banners[index];


                        return Card(
                          clipBehavior:
                              Clip.antiAlias,

                          child: Stack(

                            fit:
                                StackFit.expand,

                            children: [

                              NetworkImageBox(
                                url:
                                    banner.image,

                                radius:
                                    0,
                              ),


                              Container(

                                decoration:
                                    const BoxDecoration(

                                  gradient:
                                      LinearGradient(

                                    colors: [
                                      Colors.transparent,
                                      Colors.black54,
                                    ],

                                    begin:
                                        Alignment.topCenter,

                                    end:
                                        Alignment.bottomCenter,
                                  ),
                                ),
                              ),


                              Positioned(
                                right:
                                    18,

                                bottom:
                                    16,

                                child:
                                    Text(

                                  banner.title,

                                  style:
                                      const TextStyle(

                                    color:
                                        Colors.white,

                                    fontSize:
                                        20,

                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),



                const SizedBox(height: 22),


                SectionTitle(
                  title:
                      'دسته‌بندی‌ها',

                  onSeeAll: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.categories,
                    );
                  },
                ),


                const SizedBox(height: 10),



                if (data.categories.isEmpty)

                  const EmptyState(
                    message:
                        'دسته‌بندی‌ای ثبت نشده',
                  )

                else

                  SizedBox(

                    height:
                        115,

                    child:
                        ListView.separated(

                      scrollDirection:
                          Axis.horizontal,

                      itemCount:
                          data.categories.length,

                      separatorBuilder:
                          (_, index) =>
                              const SizedBox(
                                width: 10,
                              ),


                      itemBuilder:
                          (context, index) {

                        final category =
                            data.categories[index];


                        return InkWell(

                          onTap: () {

                            Navigator.pushNamed(

                              context,

                              AppRoutes.products,

                              arguments: {

                                'category_id':
                                    category.id,

                                'title':
                                    category.name,
                              },
                            );
                          },


                          child: SizedBox(

                            width:
                                90,

                            child:
                                Column(

                              children: [

                                NetworkImageBox(

                                  url:
                                      category.image,

                                  height:
                                      72,

                                  width:
                                      72,

                                  fit:
                                      BoxFit.contain,

                                  radius:
                                      36,
                                ),


                                const SizedBox(
                                  height: 7,
                                ),


                                Text(

                                  category.name,

                                  maxLines:
                                      1,

                                  overflow:
                                      TextOverflow.ellipsis,

                                  textAlign:
                                      TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),



                const SizedBox(height: 22),



                SectionTitle(

                  title:
                      'جدیدترین محصولات',

                  onSeeAll: () {

                    Navigator.pushNamed(
                      context,
                      AppRoutes.products,
                    );
                  },
                ),



                const SizedBox(height: 10),



                if (data.products.isEmpty)

                  const EmptyState(
                    message:
                        'محصولی برای نمایش وجود ندارد',
                  )

                else

                  LayoutBuilder(

                    builder:
                        (context, constraints) {


                      final count =
                          constraints.maxWidth >= 1000
                              ? 5
                              : constraints.maxWidth >= 750
                                  ? 4
                                  : constraints.maxWidth >= 520
                                      ? 3
                                      : 2;


                      return GridView.builder(

                        shrinkWrap:
                            true,

                        physics:
                            const NeverScrollableScrollPhysics(),

                        itemCount:
                            data.products.length,


                        gridDelegate:

                            SliverGridDelegateWithFixedCrossAxisCount(

                          crossAxisCount:
                              count,

                          childAspectRatio:
                              .62,

                          crossAxisSpacing:
                              10,

                          mainAxisSpacing:
                              10,
                        ),


                        itemBuilder:
                            (context, index) {

                          final product =
                              data.products[index];


                          return ProductCard(

                            product:
                                product,


                            onTap: () {

                              Navigator.pushNamed(

                                context,

                                AppRoutes.productDetail,

                                arguments:
                                    product.id,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}