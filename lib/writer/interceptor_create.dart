part of jaguar_generator.writer;

class InterceptorCreateWriter {
  final Route _r;

  final Interceptor _i;

  InterceptorCreateWriter(this._r, this._i);

  InterceptorCreator get _c => _i.creator;

  String generate() {
    StringBuffer sb = new StringBuffer();

    sb.write('${_i.genInstanceName} = new ${_c.name}(');

    for (InterceptorRequiredParam param in _c.required) {
      sb.write(param.source);
      sb.write(',');
    }

    for (InterceptorNamedParam param in _c.optional) {
      sb.write('${param.key}: ');
      if (param is InterceptorNamedMakeParamType) {
        sb.write('new ${param.type}(');
        sb.write(param.inputs.map((inp) => inp.writeVal).join(','));
        sb.write(')');
      } else if (param is InterceptorNamedMakeParamMethod) {
        if (param.isAsync) {
          sb.write('await ');
        }
        sb.write('${param.methodName}()');
      } else if (param is InterceptorNamedMakeParamSettings) {
        sb.write('Settings.getString(');
        sb.write('"${param.settingKey}"');
        if (param.defaultValue != null) {
          sb.write(', defaultValue: "${param.defaultValue}"');
        }
        if (param.filterStr != null) {
          sb.write(', settingsFilter: SettingsFilter.${param.filterStr}');
        }
        sb.write(')');
      }
      sb.write(',');
    }

    sb.writeln(').createInterceptor();');

    return sb.toString();
  }
}
