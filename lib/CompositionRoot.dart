import 'package:flutter/cupertino.dart';
import 'package:flutter_cubit/flutter_cubit.dart';
import 'package:todolist/smart_contracts/contract.dart';
import 'package:todolist/state_management/contract_cubit.dart';
import 'package:todolist/state_management/contract_state.dart';
import 'package:todolist/ui/home.dart';

class CompositionRoot{
  static late ContractLinking contractLinking;
  static configure() async{
    contractLinking = ContractLinking();
    await contractLinking.initialSetup();
   
  }
  static composeHomeUi(){
    ContractCubit contractCubit = ContractCubit(contractLinking);
    return CubitProvider(create: (BuildContext context) => contractCubit,child: Home(),);
  }
  
}