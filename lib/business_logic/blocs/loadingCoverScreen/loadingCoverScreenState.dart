import 'package:photo_tracker/business_logic/blocs/loadingCoverScreen/loadingCoverScreenBloc.dart';

class LoadingCoverScreenState   {
  const LoadingCoverScreenState._({
    this.status = LoadingCoverScreenStatus.notLoading,
  });

  const LoadingCoverScreenState.notLoading() : this._();

  const LoadingCoverScreenState.loading()
      : this._(status: LoadingCoverScreenStatus.loading);

  final LoadingCoverScreenStatus status;

}
