import 'package:photo_tracker/business_logic/blocs/loadingCoverScreen/loadingCoverScreenBloc.dart';

abstract class LoadingCoverScreenEvent {
  const LoadingCoverScreenEvent();
}

class LoadingCoverScreenEventChanged extends LoadingCoverScreenEvent {
  const LoadingCoverScreenEventChanged(this.status);

  final LoadingCoverScreenStatus status;
}
