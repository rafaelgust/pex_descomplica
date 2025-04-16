import 'package:jwt_decoder/jwt_decoder.dart';

abstract class JwtService {
  /// Verifica se o token JWT é válido e não expirado
  bool isTokenValid(String? token);

  /// Retorna a data de expiração do token JWT
  DateTime? getExpirationDate(String token);

  /// Decodifica o token JWT e retorna seus claims
  Map<String, dynamic>? decodeToken(String token);

  /// Retorna um claim específico do token JWT
  dynamic getClaim(String token, String claimKey);
}

class JwtServiceImpl implements JwtService {
  @override
  bool isTokenValid(String? token) {
    if (token == null || token.isEmpty) return false;
    return !JwtDecoder.isExpired(token);
  }

  @override
  DateTime? getExpirationDate(String token) {
    return JwtDecoder.getExpirationDate(token);
  }

  @override
  Map<String, dynamic>? decodeToken(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      return null;
    }
  }

  @override
  dynamic getClaim(String token, String claimKey) {
    final claims = decodeToken(token);
    return claims?[claimKey];
  }
}
