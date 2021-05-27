// @dart=2.9
import 'package:flutter_test/flutter_test.dart';
import 'package:todolist/smart_contracts/contract.dart';
import 'package:todolist/state_management/contract_cubit.dart';
import 'package:todolist/state_management/contract_state.dart';
import 'package:matcher/matcher.dart' as matcher;

void main() {
   ContractCubit sut;
  ContractLinking api;
  setUp(() async{
    // api = ContractLinking();
    // await api.initialSetup();
    // sut = ContractCubit(api);
  });

  

  group('Cubit Testing',(){
    test('getTasks',() async {
        await sut.getTasks();
        await expectLater(sut,emits(matcher.TypeMatcher<GetTaskState>()));
        final state =sut.state as GetTaskState;
       
        print(state.tasks.length);
    });

    // test('setTasks',() async {
    //     await sut.setTasks("Lawda lassun");
    //     await expectLater(sut,emits(matcher.TypeMatcher<SetTaskState>()));
    //     final state =sut.state as SetTaskState;
    // });
  });
}
