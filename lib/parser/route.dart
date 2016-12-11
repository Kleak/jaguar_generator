part of jaguar.generator.parser.route;

class ParsedRoute extends Object with ChainFunction {
  final ParsedUpper upper;

  final MethodElementWrap method;

  final AnnotationElementWrap routeAnnot;

  ant.RouteBase item;

  final List<ParsedInput> inputs = <ParsedInput>[];

  final List<ParsedInterceptor> interceptors = <ParsedInterceptor>[];

  Map<String, bool> _interceptorResultUsed = {};

  final List<ParsedExceptionHandler> exceptions = <ParsedExceptionHandler>[];

  ParsedRoute(this.upper, this.method, this.routeAnnot) {
    item = routeAnnot.instantiated;

    _detectInputs();

    ParsedInterceptor.detectInterceptors(method).forEach((inter) {
      interceptors.add(inter);
      _interceptorResultUsed.addAll(inter.interceptorResultsUsed);
    });

    ParsedExceptionHandler.detectAllExceptions(method).forEach(exceptions.add);
  }

  //Detects inputs
  void _detectInputs() {
    inputs.addAll(
        ParsedInput.detectInputs(method, method.parameters, numDefaultInputs));

    inputs.forEach((inp) {
      if (inp is ParsedInputInterceptor) {
        _interceptorResultUsed[inp.genName] = true;
      }
    });
  }

  bool get canHaveQueryParams => true;

  String get instantiationString => routeAnnot.instantiationString;

  String get prototype => method.prototype;

  bool get isWebSocket => item is ant.Ws;

  @override
  int get numDefaultInputs =>
      (needsHttpRequest ? 1 : 0) + (isWebSocket ? 1 : 0);

  bool get usesQueryParam {
    if (inputs.any((ParsedInput inp) => inp is ParsedInputQueryParams)) {
      return true;
    }

    if (!areOptionalParamsPositional && optionalParams.length != 0) {
      return true;
    }

    if (interceptors.any((ParsedInterceptor info) => info.usesQueryParam)) {
      return true;
    }

    return false;
  }

  bool isInterceptorResultUsed(ParsedInterceptor inter) =>
      _interceptorResultUsed.containsKey(inter.resultName) ||
      upper.interceptors.any((intercep) =>
          intercep.interceptorResultsUsed.containsKey(inter.resultName));

  /// Finds route annotation on the given method
  static ParsedRoute detectRoute(ParsedUpper upper, MethodElementWrap element) {
    List<AnnotationElementWrap> annots = element.metadata
        .where((annot) => annot.instantiated is ant.RouteBase)
        .toList();

    if (annots.length == 0) {
      return null;
    }

    if (annots.length != 1) {
      StringBuffer sb = new StringBuffer();

      sb.write('${element.name} has more than one Route annotations.');
      throw new GeneratorException('', 0, sb.toString());
    }

    return new ParsedRoute(upper, element, annots.first);
  }
}
