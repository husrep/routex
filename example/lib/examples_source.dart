import 'dart:async';

import 'package:flutter/material.dart';
import 'package:routex/routex.dart';
import 'package:rxdart/rxdart.dart';

import 'basic_example.dart';
import 'controllers/examples_controller.dart';

class ExamplesSource {
  final Observable<List<BasicExample>> samplesSource;

  ExamplesSource._(this.samplesSource);

  static ExamplesSource newInstance() {
    Router router = Router.router();

    //some initial bindings
    router
      .route("/echo")
      .handler((context) => context.response().end("Routex hello!!!"));

    //organize code into controllers
    ExamplesController examplesController = ExamplesController();
    examplesController.bindRouter(router);

    //testing routes -> executing request and passing all results to list.
    Observable<BasicExample> echoRequestExample = router
      .handle(BaseRequest<String>("/echo"))
      .asStream()
      .map((response) => BasicExample.withResponse(response))
      .onErrorResume((error) => Observable.just(BasicExample.withError(error)));

    Observable<BasicExample> asyncAndSyncHandlersSample = router
      .handle(BaseRequest<String>(
      "/app/examples/async-sync", params: {"additional_info": "!!!"}))
      .asStream()
      .map((response) => BasicExample.withResponse(response))
      .onErrorResume((error) => Observable.just(BasicExample.withError(error)));

    Observable<BasicExample> widgetBuilderRequest = router
      .handle(
      BaseRequest<WidgetBuilder>("/app/examples/request-for-widget-builder"))
      .asStream()
      .map((response) => BasicExample.withResponse(response))
      .onErrorResume((error) => Observable.just(BasicExample.withError(error)));


    Observable<BasicExample> widgetRequest = router
      .handle(BaseRequest<WidgetBuilder>("/app/examples/request-for-widget"))
      .asStream()
      .map((response) => BasicExample.withResponse(response))
      .onErrorResume((error) => Observable.just(BasicExample.withError(error)));

    Observable<BasicExample> irresponsibleRequestExample = router
      .handle(BaseRequest<String>("/app/examples/irresponsible"))
      .asStream()
      .timeout(Duration(milliseconds: 100))
      .map((response) => BasicExample.withResponse(response))
      .onErrorResume((error) =>
      Observable.just(error is TimeoutException
        ? Example.irresponsibleRequest(error)
        : BasicExample.withError(error)));

    Observable<BasicExample> errorFailingRequestExample = router
      .handle(BaseRequest<String>("/app/examples/failing-context"))
      .asStream()
      .map((response) => BasicExample.withResponse(response))
      .onErrorResume((error) => Observable.just(BasicExample.withError(error)));

    Observable<BasicExample> simpleFutureRequestExample = router
      .handle(BaseRequest<String>("/app/examples/simple-future"))
      .asStream()
      .map((response) => BasicExample.withResponse(response))
      .onErrorResume((error) => Observable.just(BasicExample.withError(error)));

    Observable<BasicExample> puttingMoreData = router
      .handle(BaseRequest<String>("/app/examples/putting-build_context-and-more-data", params: {
      "message": "RoutingContext has these two structures to put data, Map<String, dynamic> data(), Map<String, dynamic> params(), and get(), getParam() methods, use params for external world and data()-> get for handlers internally."
    }))
      .asStream()
      .map((response) => BasicExample.withResponse(response))
      .onErrorResume((error) => Observable.just(BasicExample.withError(error)));

    return ExamplesSource._(Observable.zipList([
      echoRequestExample,
      asyncAndSyncHandlersSample,
      widgetBuilderRequest,
      widgetRequest,
      irresponsibleRequestExample,
      errorFailingRequestExample,
      simpleFutureRequestExample,
      puttingMoreData
    ]));
    //
  }

  Observable<List<BasicExample>> call() => samplesSource;
}
