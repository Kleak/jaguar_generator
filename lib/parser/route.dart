part of jaguar.generator.parser.route;

class ParsedRoute extends Object with ChainFunction {
  ParsedUpper upper;

  MethodElementWrap method;

  AnnotationElementWrap routeAnnot;

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
    int paramIdx = numDefaultInputs;
    for (int annotIdx = 0; annotIdx < method.metadata.length; annotIdx++) {
      AnnotationElementWrap annot = method.metadata[annotIdx];

      if (!isAnnotationInput(annot)) {
        continue;
      }

      ParsedInput inp = createInput(annot, method.parameters[paramIdx]);
      inputs.add(inp);

      if (inp is ParsedInputInterceptor) {
        _interceptorResultUsed[inp.genName] = true;
      }

      paramIdx++;
    }
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
      _interceptorResultUsed.containsKey(inter.instance.returnVarName);

  /// Finds route annotation on the given method
  static AnnotationElementWrap detectRoute(MethodElementWrap element) {
    List<AnnotationElementWrap> annots = element.metadata
        .where((AnnotationElementWrap annot) =>
            annot.instantiated is ant.RouteBase)
        .toList();

    if (annots.length == 0) {
      return null;
    }

    if (annots.length != 1) {
      StringBuffer sb = new StringBuffer();

      sb.write('${element.name} has more than one Route annotations.');
      throw new GeneratorException('', 0, sb.toString());
    }

    return annots.first;
  }
}
