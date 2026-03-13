import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_refresher/smart_refresher.dart';

// Events
abstract class DataEvent {}
class FetchData extends DataEvent {}
class RefreshData extends DataEvent {}

// States
abstract class DataState {}
class DataInitial extends DataState {}
class DataLoading extends DataState {}
class DataLoaded extends DataState {
  final List<String> items;
  DataLoaded(this.items);
}
class DataError extends DataState {
  final String error;
  DataError(this.error);
}

// Bloc
class DataBloc extends Bloc<DataEvent, DataState> {
  DataBloc() : super(DataInitial()) {
    on<FetchData>((event, emit) async {
      emit(DataLoading());
      await Future.delayed(const Duration(seconds: 2));
      emit(DataLoaded(List.generate(20, (i) => 'BLoC Item $i')));
    });
    on<RefreshData>((event, emit) async {
      await Future.delayed(const Duration(seconds: 2));
      emit(DataLoaded(List.generate(20, (i) => 'Refreshed BLoC Item $i')));
    });
  }
}

class BlocExample extends StatefulWidget {
  const BlocExample({super.key});

  @override
  State<BlocExample> createState() => _BlocExampleState();
}

class _BlocExampleState extends State<BlocExample> {
  final RefreshController _refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DataBloc()..add(FetchData()),
      child: Scaffold(
        appBar: AppBar(title: const Text('BLoC Integration')),
        body: BlocConsumer<DataBloc, DataState>(
          listener: (context, state) {
            if (state is DataLoaded) {
              _refreshController.refreshCompleted();
            } else if (state is DataError) {
              _refreshController.refreshFailed();
            }
          },
          builder: (context, state) {
            return SmartRefresher(
              controller: _refreshController,
              onRefresh: () {
                context.read<DataBloc>().add(RefreshData());
              },
              child: _buildContent(state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(DataState state) {
    if (state is DataLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is DataError) {
      return Center(child: Text(state.error));
    }
    if (state is DataLoaded) {
      return ListView.builder(
        itemCount: state.items.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(state.items[index]),
        ),
      );
    }
    return Container();
  }
}
