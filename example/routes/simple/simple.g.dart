// GENERATED CODE - DO NOT MODIFY BY HAND

part of jaguar.example.routes.simple;

// **************************************************************************
// Generator: RouteGroupGenerator
// Target: class SubGroup
// **************************************************************************

abstract class _$JaguarSubGroup implements RequestHandler {
  static const List<RouteBase> routes = const <RouteBase>[
    const Route(path: '/ping'),
    const Post(path: '/:id'),
    const Put(path: '/:id')
  ];

  String normal();

  void postRoute(int id);

  void voidRoute(String id);

  Future<bool> handleRequest(HttpRequest request, {String prefix: ''}) async {
    prefix += '/api';
    PathParams pathParams = new PathParams();
    bool match = false;

//Handler for normal
    match =
        routes[0].match(request.uri.path, request.method, prefix, pathParams);
    if (match) {
      Response rRouteResponse = new Response(null);
      rRouteResponse.statusCode = 200;
      rRouteResponse.value = normal();
      await rRouteResponse.writeResponse(request.response);
      return true;
    }

//Handler for postRoute
    match =
        routes[1].match(request.uri.path, request.method, prefix, pathParams);
    if (match) {
      Response rRouteResponse = new Response(null);
      postRoute(
        stringToInt(pathParams.getField('id')),
      );
      await rRouteResponse.writeResponse(request.response);
      return true;
    }

//Handler for voidRoute
    match =
        routes[2].match(request.uri.path, request.method, prefix, pathParams);
    if (match) {
      Response rRouteResponse = new Response(null);
      voidRoute(
        (pathParams.getField('id')),
      );
      await rRouteResponse.writeResponse(request.response);
      return true;
    }

    return false;
  }
}

// **************************************************************************
// Generator: RouteGroupGenerator
// Target: class MotherGroup
// **************************************************************************

abstract class _$JaguarMotherGroup implements RequestHandler {
  static const List<RouteBase> routes = const <RouteBase>[
    const Route(path: '/ping')
  ];

  SubGroup get subGroup;

  String ping();

  Future<bool> handleRequest(HttpRequest request, {String prefix: ''}) async {
    prefix += '/api';
    PathParams pathParams = new PathParams();
    bool match = false;

//Handler for ping
    match =
        routes[0].match(request.uri.path, request.method, prefix, pathParams);
    if (match) {
      Response rRouteResponse = new Response(null);
      rRouteResponse.statusCode = 200;
      rRouteResponse.value = ping();
      await rRouteResponse.writeResponse(request.response);
      return true;
    }

    if (await subGroup.handleRequest(request, prefix: prefix + '/sub')) {
      return true;
    }

    return false;
  }
}
