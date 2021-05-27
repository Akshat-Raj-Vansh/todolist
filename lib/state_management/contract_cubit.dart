import 'package:async/src/result/result.dart';

import 'package:cubit/cubit.dart';
import 'package:flutter_web3_provider/ethers.dart';
import 'package:todolist/smart_contracts/contract.dart';
import 'package:todolist/smart_contracts/new_contract.dart';
import 'package:todolist/state_management/contract_state.dart';


class ContractCubit extends Cubit<ContractState> {
  final NewContractLinking contractLinking;

  ContractCubit(this.contractLinking) : super(IntialState());

  startContract(Web3Provider provider) async{
    
    await this.contractLinking.initialSetup(provider);
    //await getTasks();
    emit(StartContractState());
  }

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
