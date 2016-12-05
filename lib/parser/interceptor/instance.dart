part of jaguar.generator.parser.route;

class ParsedInterceptorInstance extends NamedElement {
  final AnnotationElementWrap element;

  String get name => type.name;

  String get libraryName => type.libraryName;

  final DartTypeWrap type;

  final String id;

  final Map<String, ParsedMakeParam> params;

  ParsedInterceptorInstance(this.element, this.type, this.id, this.params);

  String get returnVarName => 'r${type.displayName}' + (id ?? '');

  factory ParsedInterceptorInstance.FromElementAnnotation(
      AnnotationElementWrap annot) {
    DartObject constVal = annot.constantValue;

    DartTypeWrap type = new DartTypeWrap(constVal.type);
    String id = constVal.getField('(super)')?.getField('id')?.toStringValue();

    Map<String, ParsedMakeParam> params = {};

    DartObject object = constVal.getField('(super)')?.getField('makeParams');
    if (object is DartObject) {
      Map map = object.toMapValue();

      if (map is Map) {
        map.forEach((DartObject key, DartObject val) {
          final String name = key.toSymbolValue();
          if (name == 'state' || name == 'makeParams') {
            throw new Exception(
                'Cannot provide state and params param to interceptor!');
          }
          params[key.toSymbolValue()] = ParsedMakeParam.detect(val);
        });
      }
    }

    return new ParsedInterceptorInstance(annot, type, id, params);
  }

  String get instantiationString {
    String lRet = (element as ElementAnnotationImpl).annotationAst.toSource();
    lRet = lRet.substring(1);
    return 'new ' + lRet;
  }
}
