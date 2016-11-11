part of jaguar.generator.writer;

class RouteCallWriter {
  final RouteInfo route;

  RouteCallWriter(this.route);

  String generate() {
    StringBuffer sb = new StringBuffer();

    if (route.isWebSocket) {
      sb.write("WebSocket ws = await WebSocketTransformer.upgrade(request);");
    }

    if (!route.isWebSocket) {
      if (!route.returnsVoid) {
        sb.write("rRouteResponse = ");
      }
    }

    if (!route.returnsVoid) {
      if (route.returnsFuture) {
        sb.write("await ");
      }
    }

    if (route.groupNames.length > 0) {
      sb.write(route.groupNames.join('.'));
      sb.write('.');
    }

    sb.write(route.name + "(");

    if (route.needsHttpRequest) {
      sb.write("request, ");
    }

    if (route.isWebSocket) {
      sb.write("ws, ");
    }

    if (route.inputs.length != 0) {
      final String params = route.inputs.map((Input inp) {
        if (inp is InputInterceptor) {
          return inp.genName;
        } else if (inp is InputCookie) {
          return "request.cookies.firstWhere((cookie) => cookie.name == '${inp.key}', orElse: () => null)?.value";
        } else if (inp is InputCookies) {
          return 'request.cookies';
        } else if (inp is InputHeader) {
          return "request.headers.value('${inp.key}')";
        } else if (inp is InputHeaders) {
          return 'request.headers';
        } else if (inp is InputPathParams) {
          //TODO what if it is dynamic
          //TODO what if it has no FromPathParam constructor
          //TODO validate
          return 'new ' + inp.type.displayName + '.FromPathParam(pathParams)';
        } else if (inp is InputQueryParams) {
          //TODO what if it is dynamic
          //TODO what if it has no FromQueryParam constructor
          //TODO validate
          return 'new ' + inp.type.displayName + '.FromQueryParam(queryParams)';
        }
      }).join(", ");
      sb.write(params);
      sb.write(',');
    }

    if (route.nonInputParams.length > 0) {
      final String paramsStr = route.nonInputParams
          .map((ParameterElement param) => new ParameterElementWrap(param))
          .map((ParameterElementWrap param) {
        if (!param.type.isBuiltin) {
          return 'null';
        }
        String build = _getStringTo(param);
        build += "(pathParams.getField('${param.name}'))";
        return build;
      }).join(", ");

      sb.write(paramsStr);
      sb.write(',');
    }

    if (route.optionalParams.length > 0) {
      if (route.areOptionalParamsPositional) {
        final String params = route.optionalParams
            .map((ParameterElement info) => new ParameterElementWrap(info))
            .map((ParameterElementWrap info) {
          if (!info.type.isBuiltin) {
            return 'null';
          }
          String build = _getStringTo(info);
          build += "(queryParams.getField('${info.name}'))";
          if (info.toValueIfBuiltin != null) {
            build += "??${info.toValueIfBuiltin}";
          }
          return build;
        }).join(", ");
        sb.write(params);
        sb.write(',');
      } else {
        final String params = route.optionalParams
            .where((ParameterElement info) =>
                new DartTypeWrap(info.type).isBuiltin)
            .map((ParameterElement info) => new ParameterElementWrap(info))
            .map((ParameterElementWrap info) {
          String build = "${info.name}: " + _getStringTo(info);
          build += "(queryParams.getField('${info.name}'))";
          if (info.toValueIfBuiltin != null) {
            build += "??${info.toValueIfBuiltin}";
          }
          return build;
        }).join(", ");
        sb.write(params);
        sb.write(',');
      }
    }

    sb.writeln(");");

    return sb.toString();
  }
}
