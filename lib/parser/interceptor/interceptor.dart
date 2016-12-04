part of jaguar.generator.parser.route;

class ParsedInterceptor {
  /// Annotation used to instantiate interceptor
  final AnnotationElementWrap annotation;

  /// Holds the constant value of the interceptor annotation
  final ParsedInterceptorInstance instance;

  /// The class of the interceptor
  final ClassElementWrap clazz;

  /// Pre interceptor info
  final ParsedInterceptorFuncDef pre;

  /// Post interceptor info
  final ParsedInterceptorFuncDef post;

  final Map<String, bool> interceptorResultsUsed;

  ParsedInterceptor(this.annotation, this.clazz, this.instance, this.pre,
      this.post, this.interceptorResultsUsed);

  factory ParsedInterceptor.Make(AnnotationElementWrap annot) {
    final ClassElementWrap clazz = annot.ancestorClazz;
    final instance = new ParsedInterceptorInstance.FromElementAnnotation(annot);
    ParsedInterceptorFuncDef pre;
    ParsedInterceptorFuncDef post;

    /// Find pre and post interceptors in class
    clazz.methods.forEach((MethodElementWrap method) {
      if (method.name == 'pre') {
        pre = new ParsedInterceptorFuncDef.Make(method);
      } else if (method.name == 'post') {
        post = new ParsedInterceptorFuncDef.Make(method);
      }
    });

    Map<String, bool> interceptorResultsUsed = {};

    pre?.inputs?.forEach((ParsedInput inp) {
      if (inp is ParsedInputInterceptor) {
        interceptorResultsUsed[inp.genName] = true;
      }
    });

    post?.inputs?.forEach((ParsedInput inp) {
      if (inp is ParsedInputInterceptor) {
        interceptorResultsUsed[inp.genName] = true;
      }
    });

    return new ParsedInterceptor(
        annot, clazz, instance, pre, post, interceptorResultsUsed);
  }

  /// Return type of pre step
  DartTypeWrap get returnType => pre?.returnType;

  /// Flattened return type of pre step
  DartTypeWrap get returnsFutureFlattened => pre?.returnsFutureFlattened;

  /// Id specified for the interceptor instantiation
  String get id => instance.id;

  String get resultName => 'r${clazz.name}' + (id ?? '');

  /// Constructor of the interceptor
  ConstructorElementWrap get constructor => clazz.unnamedConstructor;

  /// Method element of createState
  MethodElementWrap get createStateMethod => clazz.methods.where((method) {
        return method.isStatic;
      }).firstWhere((method) => method.name == 'createState',
          orElse: () => null);

  /// Can this interceptor create state?
  bool get canCreateState => createStateMethod is MethodElementWrap;

  ParameterElementWrap get stateParam => constructor.optionalParameters
      .firstWhere((param) => param.name == 'state', orElse: () => null);

  bool get needsState => stateParam is ParameterElementWrap && !stateProvided;

  bool get stateProvided {
    for (Expression exp in annotation.argumentAst) {
      if (exp is NamedExpression) {
        if (exp.name.label.name == 'state') {
          return true;
        }
      }
    }

    return false;
  }

  /// Does this interceptor use Query parameters
  bool get usesQueryParam {
    if (pre != null && pre.usesQueryParam) {
      return true;
    }

    if (post != null && post.usesQueryParam) {
      return true;
    }

    return false;
  }

  /// Detects interceptors on a given method or class
  static List<ParsedInterceptor> detectInterceptors(WithMetadata element) {
    List<ParsedInterceptor> ret = <ParsedInterceptor>[];

    for (AnnotationElementWrap annot in element.metadata) {
      final ClassElementWrap clazz = annot.ancestorClazz;

      if (clazz is! ClassElementWrap) {
        continue;
      }

      if (!clazz.isSubtypeOf(kTypeInterceptor)) {
        continue;
      }

      ret.add(new ParsedInterceptor.Make(annot));
    }

    return ret;
  }
}
