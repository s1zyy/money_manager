part of 'transaction_bloc.dart';

@immutable
sealed class TransactionState {}


//starting state
final class TransactionInitial extends TransactionState {}

//data loading state
final class TransactionLoading extends TransactionState {}

//data loaded state
final class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  TransactionLoaded(this.transactions);
}
//error state
final class TransactionError extends TransactionState {
  final String message;
  TransactionError(this.message);
}