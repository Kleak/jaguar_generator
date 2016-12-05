import 'package:source_gen_help/import.dart';

const String kLibraryAnnotation = 'jaguar.src.annotations';

const NamedElement kJaguarResponse =
    const NamedElementImpl.Make('Response', 'jaguar.src.http.response');

const NamedElement kHttpRequest =
    const NamedElementImpl.Make('HttpRequest', 'dart.io');

const NamedElement kTypeInput =
    const NamedElementImpl.Make('Input', kLibraryAnnotation);

const NamedElement kTypeInterceptor =
    const NamedElementImpl.Make('Interceptor', kLibraryAnnotation);

const NamedElement kTypeExceptionHandler =
    const NamedElementImpl.Make('ExceptionHandler', kLibraryAnnotation);

const NamedElement kTypeMakeParamFromType =
    const NamedElementImpl.Make('MakeParamFromType', kLibraryAnnotation);

const NamedElement kTypeMakeParamFromMethod =
    const NamedElementImpl.Make('MakeParamFromMethod', kLibraryAnnotation);
