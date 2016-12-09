// GENERATED CODE - DO NOT MODIFY BY HAND

part of jaguar.example.silly;

// **************************************************************************
// Generator: RouteGroupGenerator
// Target: class ExampleApi
// **************************************************************************

abstract class _$JaguarExampleApi implements RequestHandler {
  static const List<RouteBase> routes = const <RouteBase>[
    const Get(path: '/ping')
  ];

  String ping(User model);

  Future<bool> handleRequest(HttpRequest request, {String prefix: ''}) async {
    prefix += '/api';
    PathParams pathParams = new PathParams();
    bool match = false;

//Handler for ping
    match =
        routes[0].match(request.uri.path, request.method, prefix, pathParams);
    if (match) {
      Response rRouteResponse = new Response(null);
      UserProvider iUserProvider = new WrapUserProvider(
        model: user,
      )
          .createInterceptor();
      User rUserProvider = iUserProvider.pre();
      WithParam iWithParam = new WrapWithParam(
        makeParams: const {#param: const MakeParamFromType(ParamUsesInjection)},
      ).createInterceptor();
      iWithParam.pre();
      rRouteResponse.statusCode = 200;
      rRouteResponse.value = ping(
        rUserProvider,
      );
      await rRouteResponse.writeResponse(request.response);
      return true;
    }

    return false;
  }
}
