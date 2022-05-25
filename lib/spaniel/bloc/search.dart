import 'package:bloc/bloc.dart';
import 'package:bloc_event_transformers/bloc_event_transformers.dart';
import 'package:equatable/equatable.dart';
import 'package:spaniel/pifs/client.dart';
import 'package:spaniel/pifs/data/search_result.dart';
import 'package:spaniel/pifs/parameters/parameters.dart';

abstract class SPSearchEvent {}

// SearchSearchEventFactoryFactory
class SPSearchSearchEvent implements SPSearchEvent {
  final String query;
  SPSearchSearchEvent(this.query);
}

class SPSearchState with EquatableMixin {
  final bool isBusy;
  final List<PifsSearchResult> results;

  SPSearchState._internal({
    required this.isBusy,
    required this.results
  });

  factory SPSearchState.initial() {
    return SPSearchState._internal(
      isBusy: false,
      results: []
    );
  }

  SPSearchState withBusy(bool isBusy) {
    return SPSearchState._internal(
        isBusy: isBusy,
        results: results
    );
  }

  SPSearchState withResults(List<PifsSearchResult> results) {
    return SPSearchState._internal(
        isBusy: isBusy,
        results: results
    );
  }

  @override List<Object?> get props => [isBusy, results];
}

class SPSearchBloc extends Bloc<SPSearchEvent, SPSearchState> {
  final PifsClient client;

  SPSearchBloc({
    required this.client
  }) : super(SPSearchState.initial()) {
    on<SPSearchSearchEvent>(_onSearch, transformer: debounce(const Duration(milliseconds: 350)));
  }

  Future<void> _onSearch(SPSearchSearchEvent event, Emitter emit) async {
    emit(state.withBusy(true));
    final results = await client.searchPerform(PifsSearchPerformParameters(query: event.query));
    emit(state.withResults(results.fold(
      (result) => result,
      (error) => []
    )).withBusy(false));
  }
}
