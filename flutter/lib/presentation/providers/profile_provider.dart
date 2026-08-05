import 'package:flutter/foundation.dart';
import 'package:money_manager/domain/usecases/participant/upload_avatar.dart';

class ProfileProvider extends ChangeNotifier {
  final UploadAvatarUseCase uploadAvatarUseCase;

  ProfileProvider({required this.uploadAvatarUseCase});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _avatarUrl;
  String? get avatarUrl => _avatarUrl;

  Future<bool> uploadAvatar(String filePath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final url = await uploadAvatarUseCase.call(filePath);
      _avatarUrl = url;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
