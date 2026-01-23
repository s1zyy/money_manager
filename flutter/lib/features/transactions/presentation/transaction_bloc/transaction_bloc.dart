import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:money_manager/features/transactions/domain/entities/transaction.dart';
import 'package:money_manager/features/transactions/domain/repositories/transaction_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository repository;  

  TransactionBloc(this.repository) : super(TransactionInitial()) {

    on<LoadTransactions>((event, emit) async {

      emit(TransactionLoading());
      try{
        final txs = await repository.getTransactions();
        emit(TransactionLoaded(txs));
      } catch (e) {
        emit(TransactionError(e.toString()));
      }
    });

    on<AddTransaction>((event, emit) async {
      emit(TransactionLoading());
      try{
        await repository.createTransaction(event.transaction);
        final txs = await repository.getTransactions();
        emit(TransactionLoaded(txs));
      } catch (e) {
        emit(TransactionError(e.toString()));
      }
    });

    on<DeleteTransaction>((event, emit) async {
      // Implement delete logic
    });

    on<UpdateTransaction>((event, emit) async {
      emit(TransactionLoading());
      try{
        await repository.updateTransaction(event.transaction);
        final txs = await repository.getTransactions();
        emit(TransactionLoaded(txs));
      } catch (e) {
        emit(TransactionError(e.toString()));
      }
    });

    on<SyncTransactions>((event, emit) async {
      emit(TransactionLoading());
      try {
        await repository.sync();
        final txs = await repository.getTransactions();
        emit(TransactionLoaded(txs));
      } catch (e) {
        emit(TransactionError(e.toString()));
      }
    });

  }
}
