library jaguar_generator.writer;

import 'package:jaguar_generator/models/models.dart';

import 'package:jaguar/src/annotations/import.dart' as ant;

part 'route_call.dart';
part 'exception.dart';
part 'interceptor_create.dart';
part 'interceptor_pre.dart';
part 'interceptor_post.dart';

class Writer {
  Upper _u;

  Writer(this._u);

  List<Route> get _r => _u.routes;

  List<Group> get _g => _u.groups;

  String generate() {
    StringBuffer sb = new StringBuffer();
    sb.writeln("abstract class ${_u.name} implements RequestHandler {");

    sb.writeln(_writeRouteList());

    sb.writeln(_writeGroupDecl());

    sb.writeln(_writeMethodPrototypes());

    sb.writeln(_writeReqHandler());

    sb.writeln('}');

    return sb.toString();
  }

  String _writeRouteList() {
    StringBuffer sb = new StringBuffer();

    sb.writeln("static const List<RouteBase> routes = const <RouteBase>[");
    String routeList = _r.map((Route route) => route.instantiation).join(',');
    sb.write(routeList);
    sb.writeln("];");

    return sb.toString();
  }

  String _writeGroupDecl() {
    StringBuffer sb = new StringBuffer();

    _g.forEach((Group group) {
      sb.writeln('${group.type} get ${group.name};');
    });

    return sb.toString();
  }

  String _writeMethodPrototypes() {
    StringBuffer sb = new StringBuffer();

    _u.methods.values.forEach((Method method) {
      sb.writeln(method.prototype);
    });

    return sb.toString();
  }

  String _writeReqHandler() {
    StringBuffer sb = new StringBuffer();
    sb.writeln(kHandleReq);
    if (_u.prefix.isNotEmpty) {
      sb.write("prefix += '${_u.prefix}';");
    }

    if (_r.isNotEmpty) {
      sb.writeln(kPathParamDeclare);
      sb.writeln("bool match = false;");
    }

    if (_u.usesQueryParam) {
      sb.writeln(kQueryParamDeclare);
    }

    sb.writeln();

    for (int i = 0; i < _r.length; i++) {
      sb.writeln(_writeHandlerForRoute(_r[i], i));
    }

    _u.groups.forEach((Group group) {
      sb.write("if (await ${group.name}.handleRequest(request,prefix: prefix");
      if (group.path.isNotEmpty) {
        sb.write(" + '${group.path}'");
      }
      sb.write(")) {");
      sb.writeln("return true;");
      sb.writeln("}");
      sb.writeln();
    });

    sb.writeln("return false;");
    sb.writeln("}");
    sb.writeln();
    return sb.toString();
  }

  String _writeHandlerForRoute(final Route route, final int i) {
    StringBuffer sb = new StringBuffer();
    sb.writeln('//Handler for ${route.method.name}');
    sb.writeln(
        "match = routes[$i].match(request.uri.path, request.method, prefix, pathParams);");
    sb.writeln("if (match) {");

    if (!route.isWebsocket) {
      sb.writeln(
          "Response<${route.method.jaguarResponseType}> rRouteResponse0 = new Response(null);");
    }

    if (route.exceptions.length != 0) {
      sb.writeln("try {");
    }

    for (Interceptor interceptor in route.interceptors) {
      sb.writeln('${interceptor.name} ${interceptor.genInstanceName};');
    }

    sb.writeln("try {");

    for (Interceptor interceptor in route.interceptors) {
      InterceptorPreWriter writer =
          new InterceptorPreWriter(route, interceptor);
      sb.write(writer.generate());
    }

    {
      RouteCallWriter writer = new RouteCallWriter(route);
      sb.write(writer.generate());
    }

    for (Interceptor interceptor in route.interceptors.reversed) {
      InterceptorPostWriter writer =
          new InterceptorPostWriter(route, interceptor);
      sb.write(writer.generate());
    }

    if (!route.isWebsocket) {
      sb.writeln(
          'await rRouteResponse${route.respIndex}.writeResponse(request.response);');
    }

    sb.writeln('} catch(e) {');
    for (Interceptor interceptor in route.interceptors.reversed) {
      sb.writeln('await ${interceptor.genInstanceName}.onException();');
    }
    sb.writeln('rethrow;');
    sb.writeln('}');

    if (route.exceptions.length != 0) {
      sb.write('} ');

      RouteExceptionWriter exceptWriter = new RouteExceptionWriter(route);
      sb.write(exceptWriter.generate());
    }

    sb.writeln("return true;");
    sb.writeln("}");
    sb.writeln("");

    return sb.toString();
  }
}

const String kHandleReq =
    "Future<bool> handleRequest(HttpRequest request, {String prefix: ''}) async {";

const String kPathParamDeclare = "PathParams pathParams = new PathParams();";

const String kQueryParamDeclare =
    "QueryParams queryParams = new QueryParams(request.uri.queryParameters);";
