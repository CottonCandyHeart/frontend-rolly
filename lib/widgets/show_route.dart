import 'package:flutter/material.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/route.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:frontend_rolly/widgets/route_map_widget.dart';
import 'package:provider/provider.dart';


class ShowRoute extends StatelessWidget {
  final VoidCallback onBack;
  final TrainingRoute route;

  const ShowRoute({required this.onBack, required this.route});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppLanguage>(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) onBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.text,
            onPressed: () {
              onBack();
              Navigator.pop(context);
            },
          ),
          title: Text(lang.t('yourRoute'), style: TextStyle(color: AppColors.text)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Column( 
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                      child: Column(
                        children: [

                          // MAPA
                          SizedBox(
                            height: 300,
                            child: RouteMap(route: route),
                          ),
                          const SizedBox(height: 24),

                          // WARTOŚCI
                          Row(children: [
                            Text(lang.t('routeName'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                            Spacer(),
                            Text(route.name, style: TextStyle(color: AppColors.text)),
                          ],),
                          const SizedBox(height: 8),
                          Row(children: [
                            Text(lang.t('distance'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                            Spacer(),
                            Text(route.distance.toString(), style: TextStyle(color: AppColors.text)),
                          ],),
                          const SizedBox(height: 8),
                          Row(children: [
                            Text(lang.t('duration'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                            Spacer(),
                            Text('${(route.estimatedTime ~/ 3600 )} h ${(route.estimatedTime % 3600) ~/ 60} min', style: TextStyle(color: AppColors.text)),
                          ],),
                          const SizedBox(height: 8),
                          Row(children: [
                            Text(lang.t('dateAndTime'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                            Spacer(),
                            Text('${route.date.day}.${route.date.month}.${route.date.year} ${route.date.hour}:${route.date.minute}', style: TextStyle(color: AppColors.text)),
                          ],),
                          const SizedBox(height: 8),
                          Row(children: [
                            Text(lang.t('caloriesBurned'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                            Spacer(),
                            Text(route.caloriesBurned.toString(), style: TextStyle(color: AppColors.text)),
                          ],),
                        ],
                      )
                    ),
                  ),
                ]
                )
              )
          )
        )
        )
      )
    );
  }
}