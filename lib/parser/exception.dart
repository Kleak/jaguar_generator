part of jaguar.generator.parser.route;

class ParsedExceptionHandler {
  final AnnotationElementWrap _handler;

  final DartTypeWrap _exception;

  final MethodElementWrap method;

  String get handlerName => _handler.name;

  String get exceptionName => _exception.name;

  ParsedExceptionHandler(this._handler, this._exception, this.method) {}

  String get instantiationString => _handler.instantiationString;

  static ParsedExceptionHandler detectException(AnnotationElementWrap element) {
    if (element.constantValue.type.element is! ClassElement) {
      return null;
    }

    ClassElementWrap clazz =
        new ClassElementWrap(element.constantValue.type.element);

    InterfaceTypeWrap interface = clazz.getSubtypeOf(kTypeExceptionHandler);
    if (interface is! InterfaceTypeWrap) {
      return null;
    }

    if (interface.typeArguments.length == 0) {
      throw new GeneratorException(
          '', 0, "ExceptionHandler must specify exception type!");
    }

    MethodElementWrap method = clazz.methods.firstWhere(
        (MethodElementWrap method) => method.name == 'onRouteException',
        orElse: () => null);

    if (method == null) {
      throw new GeneratorException(
          '', 0, "ExceptionHandler must have onRouteException method!");
    }

    return new ParsedExceptionHandler(
        element, interface.typeArguments[0], method);
  }

  static List<ParsedExceptionHandler> detectAllExceptions(
      WithMetadata element) {
    return element.metadata
        .map((AnnotationElementWrap annot) => detectException(annot))
        .where((value) => value is ParsedExceptionHandler)
        .toList();
  }
}
