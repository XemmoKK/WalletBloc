import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp
  ]);
  await SystemChrome.setEnabledSystemUIOverlays([]);
  
  runApp(MyApp())
}

class MyApp extends StatelessWidget {
  final GlobalKey<MyWalletState> homeKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var app = MaterialApp(
      title: 'Fin Wallet',
      theme: AppTheme.appTheme,
      home: SplashView(),
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,
      showSemanticsDebugger: false,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            switch (settings.name) {
              case routes.AddTransaction:
                return AddTransaction();
                break;
              case routes.AddAccount:
                return AddAccount();
                break;
              case routes.ListAccounts:
                return ListAccounts("Accounts");
                break;
              case routes.Selectategory:
                return CategoryList("Select Category", returnValue: true,);
              case routes.CreateCategory:
                return CreateCategory();
              case routes.UserProfile:
                return UserDetail();
              case routes.Login:
                return Login();
              case routes.ValidationProcessing:
                return RequestValidation(isProcessing: true);
              case routes.MyHome:
                return MyWalletHome(key: homeKey);
              case routes.Register:
                return Register();
              case routes.HomeProfile:
                return HomeProfile();
              case routes.ListBudgets:
                return ListBudgets();
              case routes.AboutUs:
                return Aboutus();
              case routes.SplashView:
                return SplashView();
              default:
                Widget paramRoute = _getParamRoute(settings.name);

                if (paramRoute == null) {
                  return PlainScaffold(
                    appBar: MyWalletAppBar(
                      title: "Coming Soon",
                    ),
                    body: Center(
                      child: Text(
                        "Unknown page ${settings.name}",
                        style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue),
                      ),
                    ),
                  );
                }

                return paramRoute;
                break;
            }
          }
        );
      },
    );

    WidgetsBinding.instance.addObserver(LifecycleEventHandler(app, homeKey));

    return app;
  }

  Widget _getParamRoute(String name) {
    if (name.startsWith("${routes.AddTransaction}")) {
      List<String> ids = name.split("/");

      int transactionId;
      try {
        transactionId = int.parse(ids[1]);
        return AddTransaction(transactionId: transactionId);
      } catch(e) {
        print("No transaction ID $name");
      }

      int categoryId;
      try {
        categoryId = int.parse(ids[2]);
        return AddTransaction(categoryId: categoryId);
      } catch(e) {
        print("No category ID $name");
      }
    }
    
    if (name.startsWith(routes.TransactionListAccount)) {
      do {
        List<String> splits = name.split(":");

        if (splits.length != 2) break;

        String title = splits[1];
        String detail = splits[0];

        String accountId = detail.replaceFirst("${routes.TransactionListAccount}/", "");

        if (accountId == null || accountId.isEmpty) break;

        try {
          int id = int.parse(accountId);
          return TransactionList(title, accountId: accountId);
        } catch(e) {}
      } while (false);
    }

    if (name.startsWith(routes.TransactionListCategory)) {
      do {
        List<String> splits = name.split(":");

        if (splits.length != 2) break;

        String title = splits[1];
        String detail = splits[0];

        String categoryId = detail.replaceFirst("${routes.TransactionListCategory}/", "");

        if (categoryId == null || categoryId.isEmpty) break;

        try {
          int id = int.parse(categoryId);
          return TransactionList(title, categoryId: id,);
        } catch(e) {}
      } while (false);
    }

    if (name.startsWith(routes.TransactionListDate)) {
      do {
        List<String> splits = name.split(":");

        if (splits.length != 2) break;

        String title = splits[1];
        String detail = splits[0];

        String date = detail.replaceFirst("${routes.TransactionListDate}/", "");

        if (date == null || date.isEmpty) break;

        try {
          int millisecondsSinceEpoch = int.parse(date);

          DateTime day = DateTime.fromMicrosecondsSinceEpoch(millisecondsSinceEpoch);

          return TransactionList(title, day: day);
        } catch(e) {}
      } while (false);
    }
    
    if (name.startsWith(routes.AddBudget)) {
      do {
        List<String> splits = name.split(":");

        if (splits.length != 2) break;

        String date = splits[1];
        String title = splits[0];

        if (date == null || date.isEmpty) break;

        try {
          int millisecondsSinceEpoch = int.parse(date);

          DateTime day = DateTime.fromMicrosecondsSinceEpoch(millisecondsSinceEpoch);

          return BudgetDetail(
            "Budget",
            categoryId: int.parse(title.replaceFirst("${routes.AddBudget}/", "")),
            month: day,
          );
        }
      }
    }
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  LifecycleEventHandler(this.app, this.homeKey);

  final MaterialApp app;
  final GlobalKey<MyWalletState> homeKey;

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.suspending:
        if (homeKey.currentContext != null) {
          homeKey.currentState.onPaused();
        }
        break;
      case AppLifecycleState.resumed:
        if (homeKey.currentContext != null) {
          homeKey.currentState.onResume();
        }
        break;
    }
  }
}
