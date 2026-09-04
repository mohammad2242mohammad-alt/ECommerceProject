import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/store_providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';


class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});


  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}



class _AuthScreenState extends ConsumerState<AuthScreen> {

  final _formKey = GlobalKey<FormState>();

  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  bool _register = false;
  bool _busy = false;



  @override
  void dispose() {

    _phone.dispose();
    _password.dispose();
    _confirmation.dispose();

    super.dispose();
  }



  Future<void> _submit() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }


    setState(() {
      _busy = true;
    });



    try {

      final repo = ref.read(storeRepositoryProvider);


      final session = _register

          ? await repo.register(
              _phone.text.trim(),
              _password.text,
              _confirmation.text,
            )

          : await repo.login(
              _phone.text.trim(),
              _password.text,
            );



      ref
          .read(authUserProvider.notifier)
          .setUser(session.user);



      if (mounted) {

        Navigator.pop(context);


        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(

            content: Text(

              _register

                  ? 'ثبت‌نام با موفقیت انجام شد'

                  : 'ورود موفق بود',

            ),
          ),
        );
      }



    } catch (error) {


      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(

            content:
                Text(error.toString()),

          ),
        );
      }



    } finally {


      if (mounted) {

        setState(() {
          _busy = false;
        });
      }
    }
  }




  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(

        title: Text(

          _register
              ? 'ثبت‌نام'
              : 'ورود به حساب',

        ),
      ),



      body: Center(

        child: SingleChildScrollView(

          padding:
              const EdgeInsets.all(24),



          child: ConstrainedBox(

            constraints:
                const BoxConstraints(
              maxWidth: 430,
            ),



            child: Form(

              key:
                  _formKey,



              child: Column(

                children: [



                  Icon(

                    Icons.storefront,

                    size:
                        64,

                    color:
                        Theme.of(context)
                            .colorScheme
                            .primary,

                  ),



                  const SizedBox(
                    height: 15,
                  ),



                  Text(

                    _register

                        ? 'حساب کاربری بسازید'

                        : 'به فروشگاه برگردید',



                    style:
                        Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                  ),



                  const SizedBox(
                    height: 28,
                  ),



                  AppTextField(

                    controller:
                        _phone,

                    labelText:
                        'شماره موبایل',

                    prefixIcon:
                        Icons.phone_outlined,

                    keyboardType:
                        TextInputType.phone,


                    validator: (value) {

                      if (value == null ||
                          value.trim().length < 10) {

                        return 'شماره موبایل را درست وارد کنید';
                      }

                      return null;
                    },
                  ),



                  const SizedBox(
                    height: 12,
                  ),



                  AppTextField(

                    controller:
                        _password,

                    labelText:
                        'رمز عبور',

                    prefixIcon:
                        Icons.lock_outline,

                    obscureText:
                        true,


                    validator: (value) {

                      if (value == null ||
                          value.length < 6) {

                        return 'رمز عبور حداقل ۶ حرف باشد';
                      }

                      return null;
                    },
                  ),



                  if (_register) ...[


                    const SizedBox(
                      height: 12,
                    ),



                    AppTextField(

                      controller:
                          _confirmation,

                      labelText:
                          'تکرار رمز عبور',

                      prefixIcon:
                          Icons.lock_reset_outlined,


                      obscureText:
                          true,



                      validator: (value) {

                        if (value == null ||
                            value.isEmpty) {

                          return 'تکرار رمز عبور را وارد کنید';
                        }


                        if (value != _password.text) {

                          return 'تکرار رمز عبور یکسان نیست';
                        }


                        return null;
                      },
                    ),
                  ],



                  const SizedBox(
                    height: 22,
                  ),



                  AppButton(

                    label:

                        _register

                            ? 'ثبت‌نام'

                            : 'ورود',


                    icon:

                        _register

                            ? Icons.person_add_alt_1

                            : Icons.login,


                    isLoading:
                        _busy,


                    onPressed:
                        _submit,
                  ),



                  const SizedBox(
                    height: 10,
                  ),



                  TextButton(

                    onPressed:

                        _busy

                            ? null

                            : () {

                                setState(() {

                                  _register =
                                      !_register;

                                });
                              },


                    child:

                        Text(

                          _register

                              ? 'قبلاً حساب دارم؛ ورود'

                              : 'حساب ندارم؛ ثبت‌نام',

                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}