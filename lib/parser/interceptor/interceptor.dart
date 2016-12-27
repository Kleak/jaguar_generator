part of jaguar.generator.parser.route;

class ParsedInterceptor extends Object with NamedElement {
  /// Holds the constant value of the interceptor annotation
  final ParsedRouteWrapper routeWrapper;

  /// The class of the interceptor
  final ClassElementWrap clazz;

  String get name => clazz.name;

  String get libraryName => clazz.libraryName;

  /// Pre interceptor info
  final ParsedInterceptorFuncDef pre;

  /// Post interceptor info
  final ParsedInterceptorFuncDef post;

  final Map<String, bool> interceptorResultUsed;

  ParsedInterceptor(this.clazz, this.routeWrapper, this.pre, this.post,
      this.interceptorResultUsed);

  factory ParsedInterceptor.Make(AnnotationElementWrap annot) {
    final routeWrapper = new ParsedRouteWrapper.FromElementAnnotation(annot);
    final ClassElementWrap clazz = routeWrapper.wrapped;
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
        clazz, routeWrapper, pre, post, interceptorResultsUsed);
  }

  /// Return type of pre step
  DartTypeWrap get returnType => pre?.returnType;

  /// Flattened return type of pre step
  DartTypeWrap get returnsFutureFlattened => pre?.returnsFutureFlattened;

  /// Id specified for the interceptor instantiation
  String get id => routeWrapper.id;

  String get resultName => 'r${clazz.name}' + (id ?? '');

  /// Constructor of the interceptor
  ConstructorElementWrap get constructor => clazz.unnamedConstructor;

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

  bool isInterceptorResultUsed(ParsedInterceptor inter) =>
      interceptorResultUsed.containsKey(inter.resultName);

  /// Detects interceptors on a given method or class
  static List<ParsedInterceptor> detectInterceptors(WithMetadata element) {
    List<ParsedInterceptor> ret = <ParsedInterceptor>[];

    for (AnnotationElementWrap annot in element.metadata) {
      final ClassElementWrap clazz = annot.ancestorClazz;

      if (clazz is! ClassElementWrap) {
        continue;
      }

      if (!clazz.isSubtypeOf(kTypeRouteWrapper)) {
        continue;
      }

      ret.add(new ParsedInterceptor.Make(annot));
    }

    return ret;
  }
}
