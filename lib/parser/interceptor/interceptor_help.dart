part of jaguar.generator.parser.route;

class ParsedInstantiated {
  final ClassElementWrap clazz;

  final List<ParsedInput> inputs;

  ParsedInstantiated(this.clazz, this.inputs);

  static ParsedInstantiated make(DartTypeWrap type) {
    ClassElementWrap clazz = type.clazz;

    List<ParsedInput> inputs = ParsedInput.detectInputs(
        clazz.unnamedConstructor,
        clazz.unnamedConstructor.requiredParameters,
        0);

    return new ParsedInstantiated(clazz, inputs);
  }

  static _detectInputs(WithMetadata host) {}
}

class ParsedInterceptorInstance extends NamedElement {
  final AnnotationElementWrap element;

  String get name => type.name;

  String get libraryName => type.libraryName;

  final DartTypeWrap type;

  final String id;

  final Map<String, ParsedInstantiated> params;

  ParsedInterceptorInstance(this.element, this.type, this.id, this.params);

  String get returnVarName => 'r${type.displayName}' + (id ?? '');

  factory ParsedInterceptorInstance.FromElementAnnotation(
      AnnotationElementWrap annot) {
    DartObject constVal = annot.constantValue;

    DartTypeWrap type = new DartTypeWrap(constVal.type);
    String id = constVal.getField('(super)')?.getField('id')?.toStringValue();

    Map<String, ParsedInstantiated> params = {};

    DartObject object = constVal.getField('(super)')?.getField('params');
    if (object is DartObject) {
      Map map = object.toMapValue();

      if (map is Map) {
        map.forEach((DartObject key, DartObject val) {
          final String name = key.toSymbolValue();
          if (name == 'state' || name == 'params') {
            throw new Exception(
                'Cannot provide state and params param to interceptor!');
          }
          params[key.toSymbolValue()] =
              ParsedInstantiated.make(new DartTypeWrap(val.toTypeValue()));
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
