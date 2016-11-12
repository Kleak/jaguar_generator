library jaguar.generator.writer;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:analyzer/src/generated/utilities_dart.dart';

import 'package:jaguar_generator/parser/import.dart';
import 'package:source_gen_help/import.dart';

part 'pre_dual_inter.dart';
part 'post_dual_inter.dart';
part 'route_call.dart';
part 'route_exceptions.dart';
part 'default_response.dart';
part 'interceptor_class_instantiator.dart';

class Writer {
  final String className;
  final bool forGroupRoute;
  final String prefix;

  StringBuffer sb = new StringBuffer();

  final List<RouteInfo> routes = new List<RouteInfo>();

  final List<GroupInfo> groups = new List<GroupInfo>();

  Writer(this.className, {this.prefix: '', this.forGroupRoute: false});

  void addAllRoutes(List<RouteInfo> newRoutes) {
    routes.addAll(newRoutes);
  }

  void addGroups(List<GroupInfo> groupList) => groups.addAll(groupList);

  void generateClass() {
    sb.writeln(
        "abstract class _\$Jaguar$className implements RequestHandler {");

    _writeRouteList();
    sb.writeln('');

    _writeGroupDecl();
    sb.writeln('');

    _writeRoutePrototype();
    sb.writeln('');

    _writeRequestHandler();

    sb.writeln("}");
  }

  void _writeRouteList() {
    sb.writeln("static const List<RouteBase> routes = const <RouteBase>[");
    String routeList = routes
        .map((RouteInfo route) => route.instantiationString)
        .toList()
        .join(',');
    sb.write(routeList);
    sb.writeln("];");
  }

  void _writeRoutePrototype() {
    routes
        .where((RouteInfo route) => route.groupNames.length == 0)
        .forEach((RouteInfo route) {
      sb.writeln(route.prototype);
      sb.writeln('');
    });
  }

  void _writeGroupDecl() {
    groups.forEach((GroupInfo group) {
      sb.writeln('${group.type} get ${group.name};');
    });
  }

  void _writeRequestHandler() {
    sb.writeln(
        "Future<bool> handleRequest(HttpRequest request, {String prefix: ''}) async {");
    if (prefix.isNotEmpty) {
      sb.write("prefix += '$prefix';");
    }
    if (routes.isNotEmpty) {
      sb.writeln("PathParams pathParams = new PathParams();");
      sb.writeln("bool match = false;");
    }
    if (routes.any((RouteInfo route) => route.shouldKeepQueryParam)) {
      sb.writeln(
          "QueryParams queryParams = new QueryParams(request.uri.queryParameters);");
    }
    sb.writeln("");

    for (int i = 0; i < routes.length; i++) {
      sb.writeln(
          "match = routes[$i].match(request.uri.path, request.method, prefix, pathParams);");
      sb.writeln("if (match) {");

      if (!routes[i].isWebSocket) {
        sb.writeln("Response rRouteResponse = new Response(null);");
      }

      if (routes[i].exceptions.length != 0) {
        sb.writeln("try {");
      }

      _writePreInterceptors(routes[i]);

      _writeRouteCall(routes[i]);

      _writePostInterceptors(routes[i]);

      if (routes[i].exceptions.length != 0) {
        sb.write('} ');

        RouteExceptionWriter exceptWriter = new RouteExceptionWriter(routes[i]);
        sb.write(exceptWriter.generate());
      }

      if (!routes[i].isWebSocket) {
        sb.writeln('await rRouteResponse.writeResponse(request.response);');
      }

      sb.writeln("return true;");
      sb.writeln("}");
      sb.writeln("");
    }

    groups.forEach((GroupInfo groupeInfo) {
      sb.write("if (await ${groupeInfo.name}.handleRequest(request");
      if (groupeInfo.group.path.isNotEmpty) {
        sb.write(",prefix: prefix + '${groupeInfo.group.path}'");
      }
      sb.write(")) {");
      sb.writeln("return true;");
      sb.writeln("}");
      sb.writeln("");
    });

    sb.writeln("return false;");
    sb.writeln("}");
    sb.writeln("");
  }

  void _writeRouteCall(RouteInfo route) {
    RouteCallWriter callWriter = new RouteCallWriter(route);
    sb.write(callWriter.generate());
  }

  void _writePreInterceptors(RouteInfo route) {
    route.interceptors.forEach((InterceptorInfo info) {
      if (info is InterceptorClassInfo) {
        _writePreInterceptorClass(route, info);
      } else if (info is InterceptorFuncInfo) {
        if (!info.isPost) {
          _writePreInterceptorFunc(info);
        }
      }
    });
  }

  void _writePreInterceptorClass(RouteInfo route, InterceptorClassInfo info) {
    InterceptorClassDecl declWriter = new InterceptorClassDecl(route, info);

    sb.write(declWriter.code);

    InterceptorFuncDef pre = info.dual.pre;

    if (pre is! InterceptorFuncDef) {
      return;
    }

    InterceptorClassPreWriter preWriter =
        new InterceptorClassPreWriter(route, info);
    sb.write(preWriter.generate());
  }

  void _writePreInterceptorFunc(InterceptorFuncInfo info) {
    if (info.isPost) {
      return;
    }

    //TODO
  }

  void _writePostInterceptors(RouteInfo route) {
    route.interceptors.reversed.forEach((InterceptorInfo info) {
      if (info is InterceptorClassInfo) {
        _writePostInterceptorClass(route, info);
      } else if (info is InterceptorFuncInfo) {
        if (info.isPost) {
          _writePostInterceptorFunc(info);
        }
      }
    });
  }

  void _writePostInterceptorClass(RouteInfo route, InterceptorClassInfo info) {
    if (info.dual.post is! InterceptorFuncDef) {
      return;
    }

    InterceptorClassPostWriter writer =
        new InterceptorClassPostWriter(route, info);
    sb.write(writer.generate());
  }

  void _writePostInterceptorFunc(InterceptorFuncInfo info) {
    //TODO
  }

  String toString() {
    generateClass();
    return sb.toString();
  }
}

String _getStringTo(ParameterElementWrap param) {
  if (!param.type.isBuiltin) {
    throw new Exception("Can only convert builtin types!");
  }

  String ret = "stringTo";

  if (param.type.isInt) {
    ret += "Int";
  } else if (param.type.isDouble) {
    ret += "Double";
  } else if (param.type.isNum) {
    ret += "Num";
  } else if (param.type.isBool) {
    ret += "Bool";
  } else if (param.type.isString) {
    ret = "";
  } else {
    throw new Exception("Can only convert builtin types!");
  }

  return ret;
}
