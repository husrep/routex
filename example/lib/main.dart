import 'package:flutter/material.dart';
import 'package:routex/routex.dart';

import 'apps/tips_app.dart';
import 'controllers/countries_controller.dart';
import 'controllers/examples_controller.dart';
import 'controllers/test_controller.dart';
import 'di/app_component.dart';
import 'handlers/app_component_handler.dart';
import 'handlers/auth_handler.dart';
import 'handlers/user_component_handler.dart';
import 'model/user.dart';
import 'theme/theme.dart';
import 'widgets/login_screen.dart';
import 'widgets/main_screen.dart';

void main() => runApp(AppWidget());
//void main() => runApp(TipsApp());

void bindRouter(Router router) {
  //RoutexNavigator by default applies handlers for 404 and 500 error codes. (That behaviour is controlled by applyDefaultHandlers parameter)
  //Whatever we throws or error,exceptions that happened will have at the end error code 500.
  //But numbers have special meaning. If we throw(number) or do context.fail(number) global handlers like this can be applied.
  //Codes 500 and 404 tells you that it is not desired flow, and you should always resolve errors in failureHandlers, look error handling documentation and example app on how it is done.
  router.errorHandler(401, (context) => context.response().end((_) => RoutexNavigatorErrorScreen(ResponseStatusException(401))));

  router.route("/*").handler(AppComponentHandler()); //basic app dependencies, available on app level

  router
    .route("/app/*") //each route that starts with /app/ requires authenthicated user, and user component for di
    .handler(AuthHandler(redirectTo: "/public/login")) //redirects to /public/login if user isn't presented.
    .handler((context) => context.put("sync_handler_between_two_asyncs", "Hello ${context.get<User>(User.key).name} :)").next())
    .handler(UserComponentHandler()); //creates user component

  router.route("/public/login").handler((context) =>
    context.response().end((_) => LoginScreen(context.get<AppComponent>(AppComponent.key).setUser)));

  router
    .route("/app/main")
  //.handler((context) => throw "Exceptions are propagated to failureHandlers or left to global error handlers.")
    .handler(mainScreen)
    .failureHandler((context) => context.response().end((_) =>
      Text("if some exception happens you can" +
          " continue contex with any number of failure handlers, you can show error screen or simply omit failureHandlers and propagate error to global error handlers.")));

  var testController = TestController();
  testController.bindRouter(router);

  var countriesController = CountriesController();
  countriesController.bindRouter(router);

  var examplesController = ExamplesController();
  examplesController.bindRouter(router);

  //Controller is just convinient way to group related routes and handlers, it doesn't have any other purpose
  //    abstract class Controller {
  //    void bindRouter(Router router);
  //    }
}

//equivalent of .handler((context) => context.response().end((_) => MainScreen()))
WidgetBuilder mainScreen(RoutingContext context) => (_) => MainScreen();

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //To support hot reload in development, use RoutexNavigator.newInstance() to ensure new instance on each reload
    //otherwise just use RoutexNavigator.shared and instance will be automatically created.
    bindRouter(RoutexNavigator.newInstance().router);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.instance,
      home: RoutexNavigator.shared.get("/app/main")(context),
    );
  }
}
