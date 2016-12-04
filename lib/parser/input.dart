part of jaguar.generator.parser.route;

class ParsedInput {
  static List<ParsedInput> detectInputs(WithMetadata host,
      List<ParameterElementWrap> params, int numDefaultInputs) {
    List<ParsedInput> inputs = [];
    int paramIdx = numDefaultInputs;
    for (int annotIdx = 0; annotIdx < host.metadata.length; annotIdx++) {
      AnnotationElementWrap annot = host.metadata[annotIdx];

      if (!isAnnotationInput(annot)) {
        continue;
      }

      if (paramIdx >= params.length) {
        throw new GeneratorException('', 0, 'More inputs than parameters!');
      }

      ParsedInput inp = createInput(annot, params[paramIdx]);
      inputs.add(inp);

      paramIdx++;
    }

    return inputs;
  }
}

class ParsedInputHeader implements ParsedInput {
  final String key;

  const ParsedInputHeader(this.key);

  ParsedInputHeader.FromAnnotation(ant.InputHeader annot) : key = annot.key;
}

class ParsedInputCookie implements ParsedInput {
  final String key;

  const ParsedInputCookie(this.key);

  ParsedInputCookie.FromAnnotation(ant.InputCookie annot) : key = annot.key;
}

class ParsedInputHeaders implements ParsedInput {}

class ParsedInputCookies implements ParsedInput {}

class ParsedInputPathParams implements ParsedInput {
  final DartTypeWrap type;

  final bool validate;

  ParsedInputPathParams(this.type, this.validate);
}

class ParsedInputQueryParams implements ParsedInput {
  final DartTypeWrap type;

  final bool validate;

  ParsedInputQueryParams(this.type, this.validate);
}

class ParsedInputRouteResponse implements ParsedInput {
  ParsedInputRouteResponse();
}

/// Input that requests results from an Interceptor
class ParsedInputInterceptor implements ParsedInput {
  /// Results of which interceptor must be injected to this input
  final DartTypeWrap resultFrom;

  final String id;

  ParsedInputInterceptor(this.resultFrom, this.id);

  String toString() => genName;

  String get genName => 'r' + resultFrom.name + (id ?? '');
}

ParsedInputInterceptor instantiateInputAnnotation(AnnotationElementWrap annot) {
  if (!annot.compareNamedElement(kTypeInput)) {
    return null;
  }

  InterfaceType resultFrom =
      annot.constantValue.getField('resultFrom').toTypeValue();

  String id = annot.constantValue.getField('id').toStringValue();

  return new ParsedInputInterceptor(new DartTypeWrap(resultFrom), id);
}

bool isAnnotationInput(AnnotationElementWrap annot) {
  dynamic instance = annot.instantiated;

  if (instance is ant.InputCookie) {
    return true;
  } else if (instance is ant.InputHeader) {
    return true;
  } else if (instance is ant.InputHeaders) {
    return true;
  } else if (instance is ant.InputCookies) {
    return true;
  } else if (instance is ant.InputPathParams) {
    return true;
  } else if (instance is ant.InputQueryParams) {
    return true;
  } else if (instance is ant.InputRouteResponse) {
    return true;
  }

  return annot.compareNamedElement(kTypeInput);
}

ParsedInput createInput(
    AnnotationElementWrap annot, ParameterElementWrap param) {
  dynamic instance = annot.instantiated;

  if (instance is ant.InputCookie) {
    return new ParsedInputCookie.FromAnnotation(instance);
  } else if (instance is ant.InputHeader) {
    return new ParsedInputHeader.FromAnnotation(instance);
  } else if (instance is ant.InputHeaders) {
    return new ParsedInputHeaders();
  } else if (instance is ant.InputCookies) {
    return new ParsedInputCookies();
  } else if (instance is ant.InputPathParams) {
    return new ParsedInputPathParams(param.type, instance.validate);
  } else if (instance is ant.InputQueryParams) {
    return new ParsedInputQueryParams(param.type, instance.validate);
  } else if (instance is ant.InputRouteResponse) {
    return new ParsedInputRouteResponse();
  }

  return instantiateInputAnnotation(annot);
}
