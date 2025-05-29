import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/protection_tip.dart';
import '../services/protection_tips_service.dart';

// First, create the service provider
final protectionTipsServiceProvider = Provider<ProtectionTipsService>((ref) {
  return ProtectionTipsService();
});

// Then, create the tips provider that uses the service
final protectionTipsProvider = StreamProvider<List<ProtectionTip>>((ref) {
  return ref.read(protectionTipsServiceProvider).getTipsStream();
});
