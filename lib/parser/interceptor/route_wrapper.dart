part of jaguar.generator.parser.route;

class ParsedRouteWrapper extends NamedElement {
  final AnnotationElementWrap annotation;

  String get name => type.name;

  String get libraryName => type.libraryName;

  final DartTypeWrap type;

  final String id;

  final Map<String, ParsedMakeParam> params;

  final ClassElementWrap wrapped;

  ParsedRouteWrapper(
      this.annotation, this.type, this.id, this.params, this.wrapped);

  factory ParsedRouteWrapper.FromElementAnnotation(
      AnnotationElementWrap annot) {
    DartObject constVal = annot.constantValue;

    DartTypeWrap type = new DartTypeWrap(constVal.type);
    String id = constVal.getField('id')?.toStringValue();

    Map<String, ParsedMakeParam> params = {};

    DartObject object = constVal.getField('makeParams');
    if (object is DartObject) {
      Map map = object.toMapValue();

      if (map is Map) {
        map.forEach((DartObject key, DartObject val) {
          final String name = key.toSymbolValue();
          if (name == 'makeParams') {
            throw new Exception('Cannot use makeParams in makeParams!');
          }
          params[key.toSymbolValue()] = ParsedMakeParam.detect(val);
        });
      }
    }

    InterfaceTypeWrap interfaceType =
        type.clazz.getSubtypeOf(kTypeRouteWrapper);
    if (interfaceType.typeArguments.length != 1) {
      throw new Exception('Provide Interceptor in RouteWrapper!');
    }

    ClassElementWrap clazz = interfaceType.typeArguments.first.clazz;

    return new ParsedRouteWrapper(annot, type, id, params, clazz);
  }
}
