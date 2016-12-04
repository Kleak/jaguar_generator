library jaguar_generator.validator;

import 'package:source_gen_help/import.dart';
import 'package:jaguar_generator/parser/parser.dart';
import 'package:jaguar_generator/common/validator.dart';

import 'interceptor/interceptor.dart';

part 'interceptor_func.dart';
part 'interceptor_order.dart';
part 'input.dart';

class ValidatorOfGroup implements Validator {
  ParsedGroup group;

  void validate() {
    //TODO check that type implements RequestHandler
    //TODO make sure that there is only one group annotation
  }
}

class ValidatorUpper implements Validator {
  ParsedUpper upper;

  ValidatorUpper(this.upper);

  void validate() {
    upper.interceptors.forEach((inter) {
      new NoPrePost(inter)..validate();
    });

    upper.routes.forEach((route) {
      List<ParsedInterceptor> interceptors = upper.interceptors.toList();
      interceptors.addAll(route.interceptors);

      //Check route inputs
      {
        for (int inpIdx = 0; inpIdx < route.inputs.length; inpIdx++) {
          new InputTypeChecker(route, inpIdx, interceptors)..validate();
        }
      }

      //Check interceptor inputs
      route.interceptors.forEach((inter) {
        new NoPrePost(inter)..validate();

        if (inter.pre != null) {
          for (int inpIdx = 0; inpIdx < inter.pre.inputs.length; inpIdx++) {
            new InputTypeChecker(inter.pre, inpIdx, interceptors)..validate();
          }
        }

        if (inter.post != null) {
          for (int inpIdx = 0; inpIdx < inter.post.inputs.length; inpIdx++) {
            new InputTypeChecker(inter.post, inpIdx, interceptors)..validate();
          }
        }
      });

      {
        //Check interceptor order
        new InterceptorOrderValidator(upper, route)..validate();
      }
    });
  }
}
