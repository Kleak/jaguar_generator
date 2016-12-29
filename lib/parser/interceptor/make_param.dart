part of jaguar.generator.parser.route;

abstract class ParsedMakeParam {
  static ParsedMakeParam detect(DartObject object) {
    DartType objType = object.type;
    DartTypeWrap makeParam = new DartTypeWrap(objType);

    if (makeParam.compareNamedElement(kTypeMakeParamFromType)) {
      DartTypeWrap type =
          new DartTypeWrap(object.getField('type').toTypeValue());
      return ParsedMakeParamType.make(type);
    } else if (makeParam.compareNamedElement(kTypeMakeParamFromMethod)) {
      String method = object.getField('methodName').toSymbolValue();
      return new ParsedMakeParamFromMethod(method);
    } else if (makeParam.compareNamedElement(kTypeMakeParamFromSettings)) {
      String key = object.getField('key').toStringValue();
      String defaultValue = object.getField('defaultValue').toStringValue();
      String filter =
          object.getField('filter')?.getField('name')?.toStringValue();
      return new ParsedMakeParamFromSettings(key, defaultValue, filter);
    } else {
      throw new GeneratorException('', 0, 'Invalid makeParam entry!');
    }
  }
}

class ParsedMakeParamType implements ParsedMakeParam {
  final ClassElementWrap clazz;

  final List<ParsedInput> inputs;

  ParsedMakeParamType(this.clazz, this.inputs);

  static ParsedMakeParamType make(DartTypeWrap type) {
    ClassElementWrap clazz = type.clazz;

    List<ParsedInput> inputs = ParsedInput.detectInputs(
        clazz.unnamedConstructor,
        clazz.unnamedConstructor.requiredParameters,
        0);

    return new ParsedMakeParamType(clazz, inputs);
  }

  static _detectInputs(WithMetadata host) {}
}

class ParsedMakeParamFromMethod implements ParsedMakeParam {
  final String methodName;

  ParsedMakeParamFromMethod(this.methodName);
}

class ParsedMakeParamFromSettings implements ParsedMakeParam {
  final String settingKey;

  final String defaultValue;

  final String filterStr;

  ParsedMakeParamFromSettings(
      this.settingKey, this.defaultValue, this.filterStr);
}
