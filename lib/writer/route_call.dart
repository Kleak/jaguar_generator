part of jaguar_generator.writer;

class RouteCallWriter extends Object with GenInputs {
  final Route route;

  RouteCallWriter(this.route);

  RouteMethod get _m => route.method;

  ant.RouteBase get _v => route.value;

  List<Input> get _inputs => _m.inputs;

  List<PathParam> get _pathParams => _m.pathParams;

  List<QueryParam> get _queryParam => _m.queryParams;

  String get _lhs {
    StringBuffer sb = new StringBuffer();

    if (!route.isWebsocket) {
      if (!_m.returnsVoid) {
        if (_m.returnsResponse) {
          sb.write("rRouteResponse = ");
        } else {
          if (_v.statusCode is int) {
            sb.writeln("rRouteResponse.statusCode = ${_v.statusCode};");
          }
          if (_v.headers is Map<String, String>) {
            _v.headers.forEach((String key, String value) {
              sb.writeln("rRouteResponse.headers['$key'] = '$value';");
            });
          }
          sb.write("rRouteResponse.value = ");
        }
      }
    }

    return sb.toString();
  }

  String generate() {
    StringBuffer sb = new StringBuffer();

    if (route.isWebsocket) {
      sb.write("WebSocket ws = await WebSocketTransformer.upgrade(request);");
    }

    sb.write(_lhs);

    if (!_m.returnsVoid) {
      if (_m.isAsync) {
        sb.write("await ");
      }
    }

    sb.write(_m.name + "(");

    if (route.needsHttpRequest) {
      sb.write("request, ");
    }

    if (route.isWebsocket) {
      sb.write("ws, ");
    }

    sb.write(_genInputs);

    sb.write(_genPathParams);

    sb.write(_genQueryParams);

    sb.writeln(");");

    return sb.toString();
  }

  String get _genPathParams {
    if (_pathParams.length == 0) {
      return '';
    }

    StringBuffer sb = new StringBuffer();

    final String str = _pathParams.map((par) => par.writeVal).join(", ");
    sb.write(str);
    sb.write(',');

    return sb.toString();
  }

  String get _genQueryParams {
    if (_queryParam.length == 0) {
      return '';
    }

    StringBuffer sb = new StringBuffer();

    for (QueryParam param in _queryParam) {
      sb.write(param.writeVal);
      sb.write(',');
    }

    return sb.toString();
  }
}

abstract class GenInputs {
  List<Input> get _inputs;

  String get _genInputs {
    if (_inputs.length == 0) {
      return '';
    }

    StringBuffer sb = new StringBuffer();

    final String params = _inputs.map((inp) => inp.writeVal).join(", ");
    sb.write(params);
    sb.write(',');

    return sb.toString();
  }
}
