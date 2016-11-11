part of jaguar.generator.writer;

class InterceptorClassPreWriter {
  final RouteInfo route;

  final InterceptorClassInfo info;

  InterceptorClassPreWriter(this.route, this.info);

  String generate() {
    StringBuffer sb = new StringBuffer();

    InterceptorFuncDef pre = info.dual.pre;

    if (route.isDualInterceptorResultUsed(info)) {
      if (!info.result.isVoid) {
        if (!info.result.isDartAsyncFuture) {
          sb.write(info.result.toString() + " ");
          sb.write(info.genReturnVarName + " = ");
        } else {
          sb.write(info.returnsFutureFlattened.toString() + " ");
          sb.write(info.genReturnVarName + " = await ");
        }
      }
    } else {
      if (!info.result.isVoid) {
        if (info.result.isDartAsyncFuture) {
          sb.write("await ");
        }
      }
    }

    sb.write(info.genInstanceName);
    sb.write(".pre(");

    if (pre.needsHttpRequest) {
      sb.write("request, ");
    }

    if (pre.inputs.length != 0) {
      final String params = pre.inputs.map((Input inp) {
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

    if (pre.nonInputParams.length > 0) {
      final String paramsStr = pre.nonInputParams
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
