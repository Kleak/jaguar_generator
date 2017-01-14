library jaguar_generator.toModels;

import 'package:analyzer/dart/element/element.dart';
import 'package:jaguar_generator/parser/parser.dart';
import 'package:jaguar_generator/models/models.dart';
import 'package:source_gen_help/source_gen_help.dart';

class ToModelUpper {
  ParsedUpper upper;

  final Upper _ret = new Upper();

  ToModelUpper(this.upper) {
    _perform();
  }

  Upper toModel() => _ret;

  void _perform() {
    _ret.name = '_\$Jaguar' + upper.name;
    _ret.prefix = upper.path;

    bool usesQueryParam = false;

    for (ParsedRoute route in upper.routes) {
      _ret.addMethod(new Method(route.method.name, route.method.prototype));

      Route newRoute = new Route();
      newRoute.instantiation = 'const ' + route.instantiationString;
      newRoute.prototype = route.prototype;
      newRoute.value = route.item;
      newRoute.isWebsocket = route.isWebSocket;
      newRoute.needsHttpRequest = route.needsHttpRequest;

      for (ParsedInterceptor interceptor in upper.interceptors) {
        newRoute.interceptors.add(makeInterceptor(route, interceptor));
      }

      for (ParsedInterceptor interceptor in route.interceptors) {
        newRoute.interceptors.add(makeInterceptor(route, interceptor));
      }

      _ret.routes.add(newRoute);

      {
        RouteMethod method = new RouteMethod();

        method.name = route.method.name;
        method.returnType = route.method.returnTypeWithoutFuture.displayName;
        method.returnsVoid = route.method.returnType.isVoid;
        method.returnsResponse = route.returnsResponse;
        if (!route.jaguarResponseType.isVoid) {
          method.jaguarResponseType = route.jaguarResponseType.name;
        } else {
          method.jaguarResponseType = 'dynamic';
        }
        method.isAsync = route.method.returnType.isAsync;

        List<Input> inputs = _makeInputs(route.inputs);

        List<PathParam> pathParams = <PathParam>[];
        List<QueryParam> queryParams = <QueryParam>[];

        for (ParameterElementWrap pathParam in route.nonInputParams) {
          if (!pathParam.type.isBuiltin) {
            pathParams.add(new PathParamNull());
          } else {
            pathParams.add(
                new PathParamKeyed(pathParam.name, _getStringTo(pathParam)));
          }
        }

        if (!route.areOptionalParamsPositional) {
          for (ParameterElementWrap queryParam in route.optionalParams) {
            queryParams.add(new QueryParam(queryParam.name,
                _getStringTo(queryParam), queryParam.toValueIfBuiltin));
          }
        }

        method.pathParams = pathParams;
        method.queryParams = queryParams;
        method.inputs = inputs;
        newRoute.method = method;
      }

      //Exceptions
      {
        List<ExceptionHandler> handlers = <ExceptionHandler>[];

        final func = (ParsedExceptionHandler except) => new ExceptionHandler(
            except.exceptionName,
            except.handlerName,
            except.instantiationString,
            except.method.returnType.isAsync);

        upper.exceptions.map(func).forEach(handlers.add);
        route.exceptions.map(func).forEach(handlers.add);
        newRoute.exceptions = handlers;
      }

      {
        int respIndex = 0;
        for (Interceptor inter in newRoute.interceptors.reversed) {
          if (inter.post == null) {
            continue;
          }

          for (Input inp in inter.post.inputs) {
            if (inp is InputRouteResponse) {
              inp.respIndex = respIndex;
            }
          }

          if (inter.post.returnsResponse) {
            respIndex++;
            inter.post.respIndex = respIndex;
          }
        }
        newRoute.respIndex = respIndex;
      }

      usesQueryParam = usesQueryParam || route.usesQueryParam;
    }

    _ret.usesQueryParam = usesQueryParam;

    for (ParsedGroup group in upper.groups) {
      Group newGroup = new Group();

      newGroup.name = group.name;
      newGroup.path = group.group.path;
      newGroup.type = group.type.displayName;

      _ret.groups.add(newGroup);
    }
  }

  //Creates interceptor model for given parsed interceptor
  Interceptor makeInterceptor(
      ParsedRoute route, ParsedInterceptor interceptor) {
    Interceptor newInterceptor = new Interceptor();

    newInterceptor.name = interceptor.name;
    newInterceptor.id = interceptor.id;

    //Make constructor
    {
      //Required parameter written in annotation
      List<InterceptorRequiredParam> req = [];
      for (int i = 0;
          i < interceptor.routeWrapper.annotation.argumentAst.length;
          i++) {
        var arg = interceptor.routeWrapper.annotation.argumentAst[i];
        ParameterElementWrap _param = interceptor
            .routeWrapper.type.clazz.unnamedConstructor.parameters
            .firstWhere(
                (ParameterElementWrap pew) =>
                    pew.name == arg.name.label.toString(),
                orElse: () => null);
        if (_param != null) {
          req.add(new InterceptorRequiredParam(_param.name, arg.toString()));
        }
      }

      //State parameter
      List<InterceptorNamedParam> opt = [];

      //Provided parameters
      for (String key in interceptor.routeWrapper.params.keys) {
        ParsedMakeParam instantiated = interceptor.routeWrapper.params[key];

        if (instantiated is ParsedMakeParamType) {
          opt.add(new InterceptorNamedMakeParamType(
              key, instantiated.clazz.name, _makeInputs(instantiated.inputs)));
        } else if (instantiated is ParsedMakeParamFromMethod) {
          MethodElementWrap meth = upper.upper.methods.firstWhere(
              (meth) => meth.name == instantiated.methodName,
              orElse: () => null);

          _ret.addMethod(new Method(meth.name, meth.prototype));

          opt.add(new InterceptorNamedMakeParamMethod(
              key, instantiated.methodName, meth.returnType.isAsync));
        } else if (instantiated is ParsedMakeParamFromSettings) {
          final val = new InterceptorNamedMakeParamSettings(
              key,
              instantiated.settingKey,
              instantiated.defaultValue,
              instantiated.filterStr);
          opt.add(val);
        }
      }

      newInterceptor.creator =
          new InterceptorCreator(interceptor.routeWrapper.name, req, opt);
    }

    //Make pre
    if (interceptor.pre is ParsedInterceptorFuncDef) {
      InterceptorPre pre = new InterceptorPre();
      pre.needsHttpRequest = interceptor.pre.needsHttpRequest;
      pre.returnType = interceptor.pre.returnsFutureFlattened.displayName;
      pre.isAsync = interceptor.pre.returnType.isAsync;
      pre.isVoid = interceptor.pre.returnType.isVoid;
      pre.isResultUseful = route.isInterceptorResultUsed(interceptor);
      pre.inputs = _makeInputs(interceptor.pre.inputs);
      newInterceptor.pre = pre;
    }

    //Make post
    if (interceptor.post is ParsedInterceptorFuncDef) {
      InterceptorPost post = new InterceptorPost();
      post.needsHttpRequest = interceptor.post.needsHttpRequest;
      post.returnsResponse = interceptor.post.returnsResponse;
      post.isAsync = interceptor.post.returnType.isAsync;
      post.inputs = _makeInputs(interceptor.post.inputs);
      if (interceptor.post.returnsResponse) {
        post.jaguarResponseType = interceptor.post.jaguarResponseType.name;
      }
      newInterceptor.post = post;
    }

    return newInterceptor;
  }

  List<Input> _makeInputs(List<ParsedInput> parsed) {
    List<Input> inputs = <Input>[];

    for (ParsedInput input in parsed) {
      if (input is ParsedInputInterceptor) {
        inputs.add(new InputInterceptor(input.id, input.resultFrom.name));
      } else if (input is ParsedInputCookie) {
        inputs.add(new InputCookie(input.key));
      } else if (input is ParsedInputCookies) {
        inputs.add(new InputCookies());
      } else if (input is ParsedInputHeader) {
        inputs.add(new InputHeader(input.key));
      } else if (input is ParsedInputHeaders) {
        inputs.add(new InputHeaders());
      } else if (input is ParsedInputPathParams) {
        inputs.add(new InputPathParams(input.type.displayName));
      } else if (input is ParsedInputQueryParams) {
        inputs.add(new InputQueryParams(input.type.displayName));
      } else if (input is ParsedInputRouteResponse) {
        inputs.add(new InputRouteResponse());
      }
    }

    return inputs;
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
