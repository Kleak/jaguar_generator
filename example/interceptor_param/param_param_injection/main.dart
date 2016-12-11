/// File: main.dart
library jaguar.example.silly;

import 'dart:async';
import 'dart:io';
import 'package:jaguar/jaguar.dart';

part 'main.g.dart';

class User {
  final String name;

  final String password;

  const User(this.name, this.password);
}

class WrapUserProvider implements RouteWrapper<UserProvider> {
  final User model;

  final String id;

  final Map<Symbol, MakeParam> makeParams;

  const WrapUserProvider({this.model, this.id, this.makeParams});

  UserProvider createInterceptor() => new UserProvider(this.model);
}

class UserProvider extends Interceptor {
  final User model;

  const UserProvider(this.model);

  User pre() => model;
}

class ParamUsesInjection {
  @Input(UserProvider)
  ParamUsesInjection(User user);
}

class WrapWithParam implements RouteWrapper<WithParam> {
  final ParamUsesInjection param;

  final String id;

  final Map<Symbol, MakeParam> makeParams;

  const WrapWithParam({this.param, this.id, this.makeParams});

  WithParam createInterceptor() => new WithParam(this.param);
}

class WithParam extends Interceptor {
  const WithParam(ParamUsesInjection param);

  void pre() {}
}

const User user = const User('teja', 'wont be this anyway');

/// Example of basic API class
@RouteGroup(path: '/api')
class ExampleApi extends Object with _$JaguarExampleApi {
  /// Example of basic route
  @Get(path: '/ping')
  @WrapUserProvider(model: user)
  @WrapWithParam(
      makeParams: const {#param: const MakeParamFromType(ParamUsesInjection)})
  @Input(UserProvider)
  String ping(User model) => "You pinged me!";
}

Future<Null> main(List<String> args) async {
  ExampleApi api = new ExampleApi();

  Configuration configuration = new Configuration();
  configuration.addApi(api);

  await serve(configuration);
}
