import 'package:equatable/equatable.dart';
import 'package:photo_tracker/business_logic/blocs/loadingCoverScreen/loadingCoverScreenBloc.dart';

abstract class LoadingCoverScreenEvent extends Equatable {
  const LoadingCoverScreenEvent();

  @override
  List<Object> get props => [];
}

class LoadingCoverScreenEventChanged extends LoadingCoverScreenEvent {
  const LoadingCoverScreenEventChanged(this.status);

  final LoadingCoverScreenStatus status;

  @override
  List<Object> get props => [status];
}
