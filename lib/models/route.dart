part of jaguar_generator.models;

abstract class PathParam {
  String get writeVal;
}

class PathParamNull implements PathParam {
  const PathParamNull();

  String get writeVal => 'null';
}

class PathParamKeyed implements PathParam {
  final String key;

  final String modifierFunc;

  const PathParamKeyed(this.key, this.modifierFunc);

  String get writeVal => "$modifierFunc(pathParams.getField('$key'))";
}

class QueryParam {
  final String key;

  final String modifierFunc;

  final dynamic defaultVal;

  const QueryParam(this.key, this.modifierFunc, this.defaultVal);

  String get writeVal {
    String ret = "$key: $modifierFunc(queryParams.getField('$key'))";

    if (defaultVal != null) {
      ret += '??';
      if (defaultVal is String) {
        ret += "'$defaultVal'";
      } else {
        ret += "$defaultVal";
      }
    }

    return ret;
  }
}

class RouteMethod {
  String name;

  String returnType;

  bool returnsVoid;

  bool returnsResponse;

  String jaguarResponseType;

  bool isAsync;

  List<Input> inputs;

  List<PathParam> pathParams;

  List<QueryParam> queryParams;
}

class Route {
  String instantiation;

  String prototype;

  ant.RouteBase value;

  bool isWebsocket;

  bool needsHttpRequest;

  List<Interceptor> interceptors = <Interceptor>[];

  RouteMethod method;

  List<ExceptionHandler> exceptions = <ExceptionHandler>[];

  int respIndex;
}

class Group {
  String path;

  String type;

  String name;
}
