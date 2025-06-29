import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied()
abstract class Env {

  @EnviedField(varName: 'GEMINI_API_KEY', obfuscate: true)
  static String geminiApiKey = _Env.geminiApiKey;  



}