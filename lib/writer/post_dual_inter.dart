part of jaguar.generator.writer;

class InterceptorClassPostWriter {
  final RouteInfo route;

  final InterceptorClassInfo info;

  InterceptorClassPostWriter(this.route, this.info);

  String generate() {
    StringBuffer sb = new StringBuffer();

    if (!info.dual.post.returnsVoid) {
      if (info.dual.post.returnsResponse) {
        sb.write("rRouteResponse = ");
      }
      if (info.dual.post.returnsFuture) {
        sb.write("await ");
      }
    }

    sb.write(info.genInstanceName);
    sb.write(".post(");

    if (info.dual.post.needsHttpRequest) {
      sb.write("request, ");
    }

    if (info.dual.post.inputs.length != 0) {
      final String params = info.dual.post.inputs.map((Input inp) {
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

    if (info.dual.post.nonInputParams.length > 0) {
      final String paramsStr = info.dual.post.nonInputParams
          .map((ParameterElement param) => new ParameterElementWrap(param))
          .map((ParameterElementWrap param) {
        return 'null';
      }).join(',');

      sb.write(paramsStr);
      sb.write(',');
    }

    sb.writeln(");");

    return sb.toString();
  }
}
