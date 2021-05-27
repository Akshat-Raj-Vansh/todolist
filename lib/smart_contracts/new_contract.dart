// @dart=2.9
import 'dart:convert';
import 'dart:js_util';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web3_provider/ethers.dart';
import 'package:provider/provider.dart';
import 'package:todolist/smart_contracts/task.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:web_socket_channel/io.dart';

class NewContractLinking  {
    Web3Provider provider;
  // final String _rpcUrl = "http://127.0.0.1:7545";
  // final String _wsUrl = "ws://127.0.0.1:7545/";
  // final String _privateKey =
  //     "0691e426ea3c51b652d254b83ab5ba051a1c3ca4fc8ec70e3bd8056fcb8707b9";
  //  Web3Client _client;
  //  bool isLoading = true;

   String _abiCode;
   String _contractAddress;

  //  Credentials _credentials;
  Contract _newContract;
  //  DeployedContract _contract;
  //  ContractFunction _getTasks,_getCount;
  //  ContractFunction _setTasks;

   List<Task> task=[];
  int count=0;



  initialSetup(Web3Provider _provider) async {
    // establish a connection to the ethereum rpc node. The socketConnector
    // property allows more efficient event streams over websocket instead of
    // // http-polls. However, the socketConnector property is experimental.
    // _client = Web3Client(_rpcUrl, Client(), socketConnector: () {
    //   return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    // });
  this.provider  = _provider;
    await getAbi();
     await getDeployedContract();
      // await getCredentials();
  }

  Future<void> getAbi() async {
    // Reading the contract abi
    String abiStringFile = await rootBundle.loadString("assets/TodoList.json");
    var jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi["abi"]);
    _contractAddress =jsonAbi["networks"]["5777"]["address"];
  }

  // Future<void> getCredentials() async {
  //   _credentials = await _client.credentialsFromPrivateKey(_privateKey);
   
  // }

  Future<void> getDeployedContract() async {
    // Telling Web3dart where our contract is declared.

    const _contractAbi = [
      "function taskCount() view returns (uint)",
      "function tasks(uint256) view returns (uint,string,bool)",
      "function createTask(string)"
    ];
   _newContract = Contract(_contractAddress, _contractAbi, provider);
    // Extracting the functions, declared in contract.
  
    // await getTask();
   
  }

 getCount() async {
    
    var count = promiseToFuture(callMethod(_newContract, "taskCount", []));
   int counter;
   await count.then((value) => counter = int.parse(value.toString()));
   
    return counter;
  }

  getTask() async {
    task=[];
    int n =  await getCount(); 
    print(n);
    for(int i=1;i<=n.toInt();i++){
       var currentName = promiseToFuture(callMethod(_newContract,"tasks", [i]));
       await currentName.then((value) =>task.add(Task(int.parse(value[0].toString()),value[1] as String,value[2] as bool)));
        }
    
  }

 setTask(String message) async {
    
   
  var _contract = _newContract.connect(provider.getSigner());
  var res =
    await promiseToFuture(callMethod(_contract, "createTask", [
    message
    ]));
      await getTask();
      }
  
}

