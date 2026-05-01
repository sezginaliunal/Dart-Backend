import 'package:dart_backend/core/enums/user.dart';
import 'package:dart_backend/core/jwt/jwt_service.dart';
import 'package:dart_backend/feature/product/handler/product_handler.dart';
import 'package:dart_backend/feature/product/product_service.dart';
import 'package:dart_backend/server/middleware/jwt_auth_middleware.dart';
import 'package:dart_backend/server/middleware/role_guard_middleware.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

/// JWT korumalı ürün endpoint'leri.
///
///   POST   /products                (sahibi JWT'den alınır)
///   GET    /products/me
///   GET    /products                (admin/moderatör)
///   POST   /products/<id>/photos
///   DELETE /products/<id>/photos
///   DELETE /products/<id>
Handler productRouter({
  required ProductService productService,
  required JwtService jwtService,
}) {
  final handler = ProductHandler(productService: productService);

  final auth = Pipeline().addMiddleware(jwtAuthMiddleware(jwtService));

  final adminAuth = Pipeline()
      .addMiddleware(jwtAuthMiddleware(jwtService))
      .addMiddleware(requireRoles({UserRole.admin, UserRole.moderator}));

  final userRouter = Router()
    ..post('/products', handler.create)
    ..get('/products/me', handler.myProducts)
    ..post('/products/<id>/photos', handler.addPhotos)
    ..delete('/products/<id>/photos', handler.removePhoto)
    ..delete('/products/<id>', handler.delete);

  final adminRouter = Router()
    ..get('/products', handler.listAll);

  return Cascade()
      .add(auth.addHandler(userRouter.call))
      .add(adminAuth.addHandler(adminRouter.call))
      .handler;
}
