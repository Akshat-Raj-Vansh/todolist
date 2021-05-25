

import 'package:equatable/equatable.dart';
import 'package:todolist/smart_contracts/task.dart';


abstract class ContractState extends Equatable{}

class IntialState extends ContractState{
  @override
  // TODO: implement props
  List<Object> get props => [];}

  class LoadingState extends ContractState{
  @override
  // TODO: implement props
  List<Object> get props => [];

  }

  class GetTaskState extends ContractState{
  final List<Task> tasks;

  GetTaskState(this.tasks);
  @override
  // TODO: implement props
  List<Object> get props => [this.tasks];

  }

  class SetTaskState extends ContractState{
    
     @override
  // TODO: implement props
  List<Object> get props => [];
  }

  class ErrorState extends ContractState{
  final String error;
  ErrorState(this.error);
  @override
  // TODO: implement props
  List<Object> get props => [];

  }
