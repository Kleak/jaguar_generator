part of jaguar.generator.parser.route;

class ParsedGroup {
  final ant.Group group;

  final DartTypeWrap type;

  final String name;

  ParsedGroup(this.group, this.type, this.name);

  /// Returns the associated Group info if the field has Group annotation
  static ant.Group detectGroup(FieldElement element) {
    //TODO make sure that there is only one group annotation
    return element.metadata.map((ElementAnnotation annot) {
      annot.computeConstantValue();
      try {
        return instantiateAnnotation(annot);
      } catch (_) {
        return null;
      }
    }).firstWhere((dynamic instance) => instance is ant.Group,
        orElse: () => null);
  }
}
