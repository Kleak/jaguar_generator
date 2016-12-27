part of jaguar.generator.parser.route;

class ParsedRoute extends Object with ChainFunction {
  final ParsedUpper upper;

  final MethodElementWrap method;

  final AnnotationElementWrap routeAnnot;

  final List<ParsedInput> inputs;

  final List<ParsedInterceptor> interceptors;

  final List<ParsedExceptionHandler> exceptions;

  final Map<String, bool> _interceptorResultUsed;

  ant.RouteBase get item => routeAnnot.instantiated;

  String get instantiationString => routeAnnot.instantiationString;

  String get prototype => method.prototype;

  bool get isWebSocket => item is ant.Ws;

  bool get returnsResponse =>
      method.returnTypeWithoutFuture.compareNamedElement(kJaguarResponse);

  DartTypeWrap get jaguarResponseType {
    if (!returnsResponse) {
      return method.returnTypeWithoutFuture;
    }

    return method.returnTypeWithoutFuture.typeArguments.first;
  }

  bool get canHaveQueryParams => true;

  @override
  int get numDefaultInputs =>
      getNumDefaultInputs(needsHttpRequest, isWebSocket);

  bool get usesQueryParam {
    if (super.usesQueryParam) return true;

    if (interceptors.any((info) => info.usesQueryParam)) return true;

    return false;
  }

  ParsedRoute(this.upper, this.method, this.routeAnnot, this.inputs,
      this.interceptors, this.exceptions, this._interceptorResultUsed);

  bool isInterceptorResultUsed(ParsedInterceptor inter) =>
      _interceptorResultUsed.containsKey(inter.resultName) ||
      upper.interceptors
          .any((intercep) => intercep.isInterceptorResultUsed(inter));

  static int getNumDefaultInputs(bool httpReq, bool isWebSocket) =>
      (httpReq ? 1 : 0) + (isWebSocket ? 1 : 0);
}

class _ParsedRouteBuilder {
  final ParsedUpper upper;

  final MethodElementWrap method;

  ParsedRoute _route;

  ParsedRoute get route => _route;

  final Map<String, bool> _interceptorResultUsed = {};

  dynamic _instantiated;

  int get numDefaultInputs => ParsedRoute.getNumDefaultInputs(
      _needsHttpRequest(method), _instantiated is ant.Ws);

  _ParsedRouteBuilder(this.upper, this.method) {
    List<AnnotationElementWrap> annots = method.metadata
        .where((annot) => annot.instantiated is ant.RouteBase)
        .toList();

    if (annots.length == 0) {
      return;
    }

    if (annots.length != 1) {
      final except = new RouteException(
          'Route method has more than one route annotations!');
      except.upper = upper.name;
      except.route = method.name;
      throw except;
    }

    _instantiated = annots.first.instantiated;

    final List<ParsedInput> inputs = [];
    inputs.addAll(_detectInputs());

    final List<ParsedInterceptor> interceptors = [];
    ParsedInterceptor.detectInterceptors(method).forEach((inter) {
      interceptors.add(inter);
      _interceptorResultUsed.addAll(inter.interceptorResultUsed);
    });

    final List<ParsedExceptionHandler> exceptions = [];
    ParsedExceptionHandler.detectAllExceptions(method).forEach(exceptions.add);

    _route = new ParsedRoute(upper, method, annots.first, inputs, interceptors,
        exceptions, _interceptorResultUsed);
  }

  //Detects inputs
  List<ParsedInput> _detectInputs() {
    final List<ParsedInput> inputs =
        ParsedInput.detectInputs(method, method.parameters, numDefaultInputs);

    final int numMethodInps = numDefaultInputs + inputs.length;
    bool hasFinished = false;

    //Detect inputs on parameters
    for (int idx = numDefaultInputs;
        idx < method.requiredParameters.length;
        idx++) {
      final ParameterElementWrap param = method.requiredParameters[idx];

      ParsedInput input = ParsedInput.detectOnParam(param);

      if (idx < numMethodInps) {
        if (input is ParsedInput) {
          final except = new InputException(
              'Input for this method is already specified on method!');
          except.param = param.name;
          throw except;
        }
        continue;
      }

      if (input is ParsedInput) {
        if (hasFinished) {
          final except = new InputException(
              'Inputs must be specified in consecutive params!');
          except.param = param.name;
          throw except;
        }
        inputs.add(input);
      } else {
        hasFinished = true;
      }
    }

    inputs.forEach((inp) {
      if (inp is ParsedInputInterceptor) {
        _interceptorResultUsed[inp.genName] = true;
      }
    });

    return inputs;
  }
}
