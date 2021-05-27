// @dart=2.9
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todolist/smart_contracts/task.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:web_socket_channel/io.dart';

class ContractLinking  {
  final String _rpcUrl = "http://127.0.0.1:7545";
  final String _wsUrl = "ws://127.0.0.1:7545/";
  final String _privateKey =
      "0691e426ea3c51b652d254b83ab5ba051a1c3ca4fc8ec70e3bd8056fcb8707b9";
   Web3Client _client;
   bool isLoading = true;

   String _abiCode;
   EthereumAddress _contractAddress;

   Credentials _credentials;

   DeployedContract _contract;
   ContractFunction _getTasks,_getCount;
   ContractFunction _setTasks;

   List<Task> task=[];
  int count=0;


  initialSetup() async {
    // establish a connection to the ethereum rpc node. The socketConnector
    // property allows more efficient event streams over websocket instead of
    // http-polls. However, the socketConnector property is experimental.
    _client = Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });

    await getAbi();
     await getDeployedContract();
      await getCredentials();
  }

  Future<void> getAbi() async {
    // Reading the contract abi
    String abiStringFile = await rootBundle.loadString("assets/TodoList.json");
    var jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi["abi"]);
    _contractAddress =
        EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
  }

  Future<void> getCredentials() async {
    _credentials = await _client.credentialsFromPrivateKey(_privateKey);
   
  }

  Future<void> getDeployedContract() async {
    // Telling Web3dart where our contract is declared.
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "TodoList"), _contractAddress);

    // Extracting the functions, declared in contract.
    _getTasks = _contract.function("tasks");
    _setTasks = _contract.function("createTask");
    _getCount = _contract.function("taskCount");

    await getTask();
   
  }

getCount() async {
    
    var count = await _client
        .call(contract: _contract, function: _getCount, params: []);
    return count[0];
  }

  getTask() async {
    task=[];
    BigInt n =  await getCount(); 
  
    for(int i=1;i<=n.toInt();i++){
       var currentName = await _client
        .call(contract: _contract, function: _getTasks, params: [BigInt.from(i)]);
        task.add(Task(currentName[0].toInt(),currentName[1] as String,currentName[2]));
        }
  
  }

 setTask(String message) async {
    
   
    await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
            contract: _contract, function: _setTasks, parameters: [message]));
      await getTask();
      }
  
}

