import 'package:flutter/cupertino.dart';
import 'package:flutter_cubit/flutter_cubit.dart';
import 'package:todolist/smart_contracts/contract.dart';
import 'package:todolist/smart_contracts/new_contract.dart';
import 'package:todolist/state_management/contract_cubit.dart';
import 'package:todolist/state_management/contract_state.dart';
import 'package:todolist/ui/home.dart';

class CompositionRoot{
  static late NewContractLinking contractLinking;
  static configure() async{
    contractLinking = NewContractLinking();
   
  }
  static composeHomeUi(){
    ContractCubit contractCubit = ContractCubit(contractLinking);
    return CubitProvider(create: (BuildContext context) => contractCubit,child: Home(),);
  }
  
}