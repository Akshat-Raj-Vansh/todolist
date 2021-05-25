import 'package:async/src/result/result.dart';

import 'package:cubit/cubit.dart';
import 'package:todolist/smart_contracts/contract.dart';
import 'package:todolist/state_management/contract_state.dart';


class ContractCubit extends Cubit<ContractState> {
  final ContractLinking contractLinking;

  ContractCubit(this.contractLinking) : super(IntialState());

  getTasks() async {
    _startLoading();
    try{
   await this.contractLinking.getTask();  
   var tasks = this.contractLinking.task;
   emit(GetTaskState(tasks));
   }
   catch(e){
      emit(ErrorState(e.toString()));}
    
  }

  setTasks(String task) async{
    try{
      await this.contractLinking.setTask(task);
      emit(SetTaskState());
      
    }
    catch(e){
      emit(ErrorState(e.toString()));
    }
    
  }

  void _startLoading(){
    emit(LoadingState());
  }
  
}
