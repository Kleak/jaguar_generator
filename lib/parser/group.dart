part of jaguar.generator.parser.route;

class ParsedGroup {
  final ant.Group group;

  final DartTypeWrap type;

  final String name;

  ParsedGroup(this.group, this.type, this.name);

  /// Returns the associated Group info if the field has Group annotation
  static ParsedGroup detectGroup(FieldElement element) {
    List<ant.Group> groups = element.metadata
        .map((annot) => new AnnotationElementWrap(annot))
        .map((AnnotationElementWrap annot) => annot.instantiated)
        .where((dynamic instance) => instance is ant.Group)
        .toList();

    if (groups.length == 0) {
      return null;
    }

    if (groups.length != 1) {
      StringBuffer sb = new StringBuffer();

      sb.write('${element.name} has more than one Group annotations.');
      throw new GeneratorException('', 0, sb.toString());
    }

    DartTypeWrap type = new DartTypeWrap(element.type);
    return new ParsedGroup(groups.first, type, element.name);
  }
}
