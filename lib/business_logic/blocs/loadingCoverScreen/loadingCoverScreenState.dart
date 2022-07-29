import 'package:equatable/equatable.dart';
import 'package:photo_tracker/business_logic/blocs/loadingCoverScreen/loadingCoverScreenBloc.dart';

class LoadingCoverScreenState extends Equatable {
  const LoadingCoverScreenState._({
    this.status = LoadingCoverScreenStatus.notLoading,
  });

  const LoadingCoverScreenState.notLoading() : this._();

  const LoadingCoverScreenState.loading()
      : this._(status: LoadingCoverScreenStatus.loading);

  final LoadingCoverScreenStatus status;

  @override
  // TODO: implement props
  List<Object?> get props => [status];
}
