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
      Response<String> rRouteResponse0 = new Response(null);
      UserProvider iUserProvider;
      WithParam iWithParam;
      try {
        iUserProvider = new WrapUserProvider(
          model: user,
        )
            .createInterceptor();
        User rUserProvider = iUserProvider.pre();
        iWithParam = new WrapWithParam(
          makeParams: const {
            #param: const MakeParamFromType(ParamUsesInjection),
            #setting: const MakeParamFromSettings('host',
                defaultValue: 'novalue', filter: SettingsFilter.Yaml)
          },
          param: new ParamUsesInjection(rUserProvider),
          setting: Settings.getString("host",
              defaultValue: "novalue", settingsFilter: SettingsFilter.Yaml),
        )
            .createInterceptor();
        iWithParam.pre();
        rRouteResponse0.statusCode = 200;
        rRouteResponse0.value = ping(
          rUserProvider,
        );
        await rRouteResponse0.writeResponse(request.response);
      } catch (e) {
        await iWithParam?.onException();
        await iUserProvider?.onException();
        rethrow;
      }
      return true;
    }

    return false;
  }
}
