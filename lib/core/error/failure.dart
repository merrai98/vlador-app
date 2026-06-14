import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

import '../constants/app_constants.dart';
import '../utils/enums.dart';
import '../utils/helper_function.dart';
import '../utils/toast_manager.dart';

class Failure extends Equatable {
  final String message;
  final int code;

  const Failure({required this.code, required this.message});

  @override
  List<Object?> get props => [code, message];
}

class OfflineFailure extends Failure {
  final String offlineMessage;
  final int offlineCode;

  const OfflineFailure(this.offlineMessage, this.offlineCode)
      : super(code: offlineCode, message: offlineMessage);

  @override
  List<Object?> get props => [code, message];
}

class GlobalFailure extends Failure {
  final String globalMessage;
  final int globalCode;

  const GlobalFailure(this.globalMessage, this.globalCode)
      : super(code: globalCode, message: globalMessage);

  @override
  List<Object?> get props => [code, message];
}

class ServerFailure extends Failure {
  final String serverMessage;
  final int serverCode;

  const ServerFailure(this.serverMessage, this.serverCode)
      : super(code: serverCode, message: serverMessage);

  @override
  List<Object?> get props => [code, message];

  void onError() {
    switch (serverCode) {
      case 500:
        ToastService.showToast(
          context: AppConstants.navigatorKey.currentState!.context,
          toastType: ToastType.failed,
          title: "error".tr(),
          message: "server_error".tr(),
        );
        break;
      case 401:
        removeUser().then((value) {});
        break;
      default:
        ToastService.showToast(
          context: AppConstants.navigatorKey.currentState!.context,
          toastType: ToastType.failed,
          title: "error".tr(),
          message: serverMessage,
        );
        break;
    }
  }
}
