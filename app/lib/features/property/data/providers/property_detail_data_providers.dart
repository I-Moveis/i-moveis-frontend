import 'package:app/core/constants.dart';
import 'package:app/core/providers/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/property_detail_repository.dart';
import '../repositories/property_detail_repository_impl.dart';

final propertyDetailRepositoryProvider =
    Provider<PropertyDetailRepository>((ref) {
  return PropertyDetailRepositoryImpl(
    dio: ref.watch(dioProvider),
    useMock: kUseMockData,
  );
});
