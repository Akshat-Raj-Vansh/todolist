// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_cubit/flutter_cubit.dart';
import 'package:provider/provider.dart';
import 'package:todolist/smart_contracts/contract.dart';
import 'package:todolist/smart_contracts/task.dart';
import 'package:todolist/state_management/contract_cubit.dart';
import 'package:todolist/state_management/contract_state.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
   TextEditingController yourNameController = TextEditingController();
 
    List<Task> data = [];
    List<bool> checked=[];

    @override
    void initState() {
        super.initState();
       CubitProvider.of<ContractCubit>(context).getTasks();
    }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("TodoList !"),
        centerTitle: true,
      ),
      body:  CubitConsumer<ContractCubit,ContractState>(builder: (context,state){
        if(state is GetTaskState){
          data = state.tasks;
          if(data.length != checked.length)
              checked = List.generate(data.length, (index) => false);
         
        }
        if(state is SetTaskState)
        {
          CubitProvider.of<ContractCubit>(context).getTasks();
        }
        return buildBody();
        
      }, listener: ( context, state) {
         if(state is ErrorState)
        {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error),));
        }
        if(state is SetTaskState)
        {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Added the task to the chain"),));
          
        }
        },)
      )
    ;
  }


  buildBody()=>Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child:  SingleChildScrollView(
                    child: Form(
                      child: Column(
                        children: [
                        
                              Text(
                                "Tasks",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 52),
                              ),
                              Container(
                                width:400,
                                height: 400,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: data.length,
                                  itemBuilder: (context,index){
                                    return CheckboxListTile(
                                      checkColor: Colors.white,
                                      value: checked[index], onChanged: (bool value){
                                      setState(() {
                                        checked[index]=value;
                                  
                                      });
                                    },title: Text(data[index].content));
                                }),
                              )
                              
                      ,
                          Padding(
                            padding: EdgeInsets.only(top: 29),
                            child: TextFormField(
                              controller: yourNameController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Add Task",
                                  hintText: "Whatever you wanna add ?",
                                  icon: Icon(Icons.drive_file_rename_outline)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 30),
                            child: ElevatedButton(
                              child: Text(
                                '+',
                                style: TextStyle(fontSize: 30),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.green,
                              ),
                              onPressed: () {
                                
                                CubitProvider.of<ContractCubit>(context).setTasks(yourNameController.text);
                                yourNameController.clear();
                                
                                                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
          ),
        );
}



