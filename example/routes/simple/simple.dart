library jaguar.example.routes.simple;

import 'dart:async';
import 'dart:io';
import 'package:jaguar/jaguar.dart';

part 'simple.g.dart';

class SampleInterceptor extends Interceptor {
  const SampleInterceptor();

  void pre({String name}) {
    //TODO
  }
}

/// Example of basic API class
@RouteGroup(path: '/api')
class SubGroup extends Object with _$JaguarSubGroup {
  /// Example of basic route
  @Route(path: '/ping')
  @SampleInterceptor()
  String normal() => "You pinged me!";

  @Post(path: '/:id')
  void postRoute(int id) {}

  @Put(path: '/:id')
  void voidRoute(String id) {}
}

/// Example of basic API class
@RouteGroup(path: '/api')
class MotherGroup extends Object with _$JaguarMotherGroup {
  /// Example of basic route
  @Route(path: '/ping')
  String ping() => "You pinged me!";

  @Group(path: '/sub')
  final SubGroup subGroup = new SubGroup();
}
