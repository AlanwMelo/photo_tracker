import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_tracker/business_logic/blocs/loadingCoverScreen/loadingCoverScreenEvent.dart';
import 'package:photo_tracker/business_logic/blocs/loadingCoverScreen/loadingCoverScreenState.dart';

enum LoadingCoverScreenStatus { loading, notLoading }

class BlocOfLoadingCoverScreen
    extends Bloc<LoadingCoverScreenEvent, LoadingCoverScreenState> {
  BlocOfLoadingCoverScreen(LoadingCoverScreenState initialState)
      : super(const LoadingCoverScreenState.notLoading()) {
    on<LoadingCoverScreenEventChanged>(_onLoadingCoverScreenState);
  }
}

_onLoadingCoverScreenState(
  LoadingCoverScreenEventChanged event,
  Emitter<LoadingCoverScreenState> emit,
) async {
  switch (event.status) {
    case LoadingCoverScreenStatus.notLoading:
      return emit(const LoadingCoverScreenState.notLoading());
    case LoadingCoverScreenStatus.loading:
      return emit(const LoadingCoverScreenState.loading());

    default:
      return emit(const LoadingCoverScreenState.notLoading());
  }
}
