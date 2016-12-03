library jaguar_generator.toModels;

import 'package:jaguar_generator/parser/parser.dart';
import 'package:jaguar_generator/models/models.dart';
//TODO import 'package:jaguar/src/annotations/import.dart' as ant;
import 'package:source_gen_help/import.dart';
import 'package:jaguar_generator/common/constants.dart';

class ToModelUpper {
  ParsedUpper upper;

  ToModelUpper(this.upper) {}

  Upper toModel() {
    Upper ret = new Upper();

    ret.name = '_\$Jaguar' + upper.name;
    ret.prefix = upper.path;

    bool usesQueryParam = false;

    for (ParsedRoute route in upper.routes) {
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

      ret.routes.add(newRoute);

      {
        RouteMethod method = new RouteMethod();

        method.name = route.method.name;
        method.returnType = route.method.returnTypeWithoutFuture.displayName;
        method.returnsVoid = route.method.returnType.isVoid;
        method.returnsResponse = route.method.returnTypeWithoutFuture
            .compareNamedElement(kJaguarResponse);
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

      usesQueryParam = usesQueryParam || route.usesQueryParam;
    }

    ret.usesQueryParam = usesQueryParam;

    for (ParsedGroup group in upper.groups) {
      Group newGroup = new Group();

      newGroup.name = group.name;
      newGroup.path = group.group.path;
      newGroup.type = group.type.displayName;

      ret.groups.add(newGroup);
    }

    return ret;
  }

  //Creates interceptor model for given parsed interceptor
  Interceptor makeInterceptor(
      ParsedRoute route, ParsedInterceptor interceptor) {
    Interceptor newInterceptor = new Interceptor();

    newInterceptor.name = interceptor.instance.name;
    newInterceptor.id = interceptor.instance.id;

    //Make constructor
    {
      //Required parameter written in annotation
      List<InterceptorRequiredParam> req = [];
      for (dynamic arg in interceptor.annotation.argumentAst) {
        req.add(new InterceptorRequiredParam(arg.toString()));
      }

      //State parameter
      List<InterceptorNamedParam> opt = [];
      if (interceptor.needsState && interceptor.canCreateState) {
        opt.add(new InterceptorNamedParamState());
      }

      //Provided parameters
      for (String key in interceptor.instance.params.keys) {
        ParsedInstantiated instantiated = interceptor.instance.params[key];

        opt.add(new InterceptorNamedParamProvided(
            key, instantiated.clazz.name, _makeInputs(instantiated.inputs)));
      }

      newInterceptor.creator = new InterceptorCreator(req, opt);
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
