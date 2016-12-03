part of jaguar_generator.writer;

class InterceptorCreateWriter {
  final Route _r;

  final Interceptor _i;

  InterceptorCreateWriter(this._r, this._i);

  InterceptorCreator get _c => _i.creator;

  String generate() {
    StringBuffer sb = new StringBuffer();

    sb.write('${_i.name} ${_i.genInstanceName} = new ${_i.name}(');

    for (InterceptorRequiredParam param in _c.required) {
      sb.write(param.source);
      sb.write(',');
    }

    for (InterceptorNamedParam param in _c.optional) {
      sb.write('${param.key}: ');
      if (param is InterceptorNamedParamProvided) {
        sb.write('new ${param.type}(');
        sb.write(param.inputs.map((inp) => inp.writeVal).join(','));
        sb.write(')');
      } else if (param is InterceptorNamedParamState) {
        sb.write('${_i.name}.createState()');
      }
      sb.write(',');
    }

    sb.write(')');
    sb.writeln(";");

    return sb.toString();
  }
}
