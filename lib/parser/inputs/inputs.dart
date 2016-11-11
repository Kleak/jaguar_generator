library jaguar.parser.inputs;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/src/annotation.dart';

import 'package:jaguar/src/annotations/import.dart' as ant;
import 'package:source_gen_help/import.dart';

class Input {}

class InputHeader implements Input {
  final String key;

  const InputHeader(this.key);

  InputHeader.FromAnnotation(ant.InputHeader annot) : key = annot.key;
}

class InputCookie implements Input {
  final String key;

  const InputCookie(this.key);

  InputCookie.FromAnnotation(ant.InputCookie annot) : key = annot.key;
}

class InputHeaders implements Input {}

class InputCookies implements Input {}

class InputPathParams implements Input {
  DartTypeWrap type;
}

class InputQueryParams implements Input {
  DartTypeWrap type;
}

/// Holds information about a single input to an interceptor method or function
class InputInterceptor implements Input {
  /// Results of which interceptor must be injected to this input
  final DartTypeWrap resultFrom;

  final String id;

  InputInterceptor(this.resultFrom, this.id);

  String toString() => genName;

  String get genName => 'r' + resultFrom.name + (id ?? '');

  bool get isRouteResponse =>
      resultFrom.compare('RouteResponse', 'jaguar.src.annotations');
}

InputInterceptor instantiateInputAnnotation(ElementAnnotation annot) {
  annot.computeConstantValue();
  final ParameterizedType type = annot.constantValue.type;
  if (type.displayName != "Input") {
    return null;
  }

  if (type.element.library.displayName != "jaguar.src.annotations") {
    return null;
  }

  InterfaceType resultFrom =
      annot.constantValue.getField('resultFrom').toTypeValue();

  String id = annot.constantValue.getField('id').toStringValue();

  return new InputInterceptor(new DartTypeWrap(resultFrom), id);
}

Input createInput(ElementAnnotation annot) {
  try {
    dynamic instance = instantiateAnnotation(annot);

    if (instance is ant.InputCookie) {
      return new InputCookie.FromAnnotation(instance);
    } else if (instance is ant.InputHeader) {
      return new InputHeader.FromAnnotation(instance);
    } else if (instance is ant.InputHeaders) {
      return new InputHeaders();
    } else if (instance is ant.InputCookies) {
      return new InputCookies();
    } else if (instance is ant.InputPathParams) {
      return new InputPathParams();
    } else if (instance is ant.InputQueryParams) {
      return new InputQueryParams();
    }
  } catch (e) {
    //Do nothing
  }

  return instantiateInputAnnotation(annot);
}
