import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routes/app_routes.dart';
import '../../../providers/store_providers.dart';


class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final user = ref.watch(authUserProvider);


    if (user == null) {

      return Scaffold(

        appBar: AppBar(
          title: const Text('حساب کاربری'),
        ),


        body: Center(

          child: Column(

            mainAxisSize:
                MainAxisSize.min,


            children: [

              const Icon(
                Icons.person_outline,
                size: 72,
                color: Colors.grey,
              ),


              const SizedBox(
                height: 12,
              ),


              const Text(
                'برای استفاده از امکانات حساب وارد شوید',
              ),


              const SizedBox(
                height: 14,
              ),


              FilledButton.icon(

                onPressed: () {

                  Navigator.pushNamed(
                    context,
                    AppRoutes.auth,
                  );

                },


                icon:
                    const Icon(
                  Icons.login,
                ),


                label:
                    const Text(
                  'ورود / ثبت‌نام',
                ),
              ),
            ],
          ),
        ),
      );
    }



    final avatarText =
        user.name != null &&
                user.name!.isNotEmpty

            ? user.name![0]

            : user.phone.isNotEmpty

                ? user.phone[0]

                : '?';



    return Scaffold(

      appBar: AppBar(
        title:
            const Text(
          'حساب کاربری',
        ),
      ),



      body: ListView(

        padding:
            const EdgeInsets.all(14),


        children: [


          Card(

            child:
                ListTile(

              leading:
                  CircleAvatar(
                child:
                    Text(
                  avatarText,
                ),
              ),


              title:
                  Text(

                user.name != null &&
                        user.name!.isNotEmpty

                    ? user.name!

                    : 'کاربر فروشگاه',
              ),


              subtitle:
                  Text(
                user.phone,
              ),
            ),
          ),



          const SizedBox(
            height: 10,
          ),



          Card(

            child:
                Column(

              children: [


                ListTile(

                  leading:
                      const Icon(
                    Icons.receipt_long_outlined,
                  ),


                  title:
                      const Text(
                    'سفارش‌های من',
                  ),


                  trailing:
                      const Icon(
                    Icons.chevron_left,
                  ),


                  onTap: () {

                    Navigator.pushNamed(
                      context,
                      AppRoutes.orders,
                    );

                  },
                ),



                ListTile(

                  leading:
                      const Icon(
                    Icons.location_on_outlined,
                  ),


                  title:
                      const Text(
                    'آدرس‌ها',
                  ),


                  trailing:
                      const Icon(
                    Icons.chevron_left,
                  ),


                  onTap: () {

                    Navigator.pushNamed(
                      context,
                      AppRoutes.addresses,
                    );

                  },
                ),



                ListTile(

                  leading:
                      const Icon(
                    Icons.favorite_border,
                  ),


                  title:
                      const Text(
                    'علاقه‌مندی‌ها',
                  ),


                  trailing:
                      const Icon(
                    Icons.chevron_left,
                  ),


                  onTap: () {

                    Navigator.pushNamed(
                      context,
                      AppRoutes.favorites,
                    );

                  },
                ),
              ],
            ),
          ),



          const SizedBox(
            height: 18,
          ),



          OutlinedButton.icon(

            onPressed: () async {

              try {

                await ref
                    .read(storeRepositoryProvider)
                    .logout();



                ref
                    .read(authUserProvider.notifier)
                    .setUser(null);



                if (context.mounted) {

                  Navigator.pushNamedAndRemoveUntil(

                    context,

                    AppRoutes.home,

                    (route) => false,

                  );
                }


              } catch (error) {


                if (context.mounted) {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(

                    SnackBar(

                      content:
                          Text(
                        error.toString(),
                      ),
                    ),
                  );
                }
              }
            },


            icon:
                const Icon(
              Icons.logout,
            ),


            label:
                const Text(
              'خروج از حساب',
            ),
          ),
        ],
      ),
    );
  }
}