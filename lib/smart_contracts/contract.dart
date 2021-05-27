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
    String abiStringFile =jsonEncode(jsonFile);
    // await rootBundle.loadString("assets/TodoList.json");
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
    print(ContractAbi.fromJson(_abiCode, "TodoList").toString());
    // Extracting the functions, decla red in contract.
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


const jsonFile = {
  "contractName": "TodoList",
  "abi": [
    {
      "inputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "constructor"
    },
    {
      "constant": true,
      "inputs": [],
      "name": "taskCount",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    },
    {
      "constant": true,
      "inputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "name": "tasks",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "id",
          "type": "uint256"
        },
        {
          "internalType": "string",
          "name": "content",
          "type": "string"
        },
        {
          "internalType": "bool",
          "name": "completed",
          "type": "bool"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    },
    {
      "constant": false,
      "inputs": [
        {
          "internalType": "string",
          "name": "_content",
          "type": "string"
        }
      ],
      "name": "createTask",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
    }
  ],
  "metadata": "{\"compiler\":{\"version\":\"0.5.16+commit.9c3226ce\"},\"language\":\"Solidity\",\"output\":{\"abi\":[{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"constant\":false,\"inputs\":[{\"internalType\":\"string\",\"name\":\"_content\",\"type\":\"string\"}],\"name\":\"createTask\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"taskCount\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"name\":\"tasks\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"id\",\"type\":\"uint256\"},{\"internalType\":\"string\",\"name\":\"content\",\"type\":\"string\"},{\"internalType\":\"bool\",\"name\":\"completed\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}],\"devdoc\":{\"methods\":{}},\"userdoc\":{\"methods\":{}}},\"settings\":{\"compilationTarget\":{\"/home/starlord/todoBlockchain/contracts/TodoList.sol\":\"TodoList\"},\"evmVersion\":\"istanbul\",\"libraries\":{},\"optimizer\":{\"enabled\":true,\"runs\":200},\"remappings\":[]},\"sources\":{\"/home/starlord/todoBlockchain/contracts/TodoList.sol\":{\"keccak256\":\"0x1bb218e3457b27ad23c1494562e235c862eaac2b753f02a0878134629350b612\",\"urls\":[\"bzz-raw://474ea09c9e8604c8e3b1680d63f7db29ff1862d0f2b5446f08463285e22b6318\",\"dweb:/ipfs/Qmd46y8n4EdWapYUmuUXvySuhqujPmZUchTeN1vemad8Ue\"]}},\"version\":1}",
  "bytecode": "0x60806040526000805534801561001457600080fd5b5060408051808201909152601781527f48656c6c6f20426c6f636b636861696e2064756e697961000000000000000000602082015261005b906001600160e01b0361006016565b610167565b60008054600190810180835560408051606081018252828152602080820187815282840187905293865284815291909420845181559151805192936100ad939085019291909101906100cc565b50604091909101516002909101805460ff191691151591909117905550565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f1061010d57805160ff191683800117855561013a565b8280016001018555821561013a579182015b8281111561013a57825182559160200191906001019061011f565b5061014692915061014a565b5090565b61016491905b808211156101465760008155600101610150565b90565b6103a0806101766000396000f3fe608060405234801561001057600080fd5b50600436106100415760003560e01c8063111002aa146100465780638d977672146100ee578063b6cb58a514610195575b600080fd5b6100ec6004803603602081101561005c57600080fd5b81019060208101813564010000000081111561007757600080fd5b82018360208201111561008957600080fd5b803590602001918460018302840111640100000000831117156100ab57600080fd5b91908080601f0160208091040260200160405190810160405280939291908181526020018383808284376000920191909152509295506101af945050505050565b005b61010b6004803603602081101561010457600080fd5b503561021b565b604051808481526020018060200183151515158152602001828103825284818151815260200191508051906020019080838360005b83811015610158578181015183820152602001610140565b50505050905090810190601f1680156101855780820380516001836020036101000a031916815260200191505b5094505050505060405180910390f35b61019d6102ca565b60408051918252519081900360200190f35b60008054600190810180835560408051606081018252828152602080820187815282840187905293865284815291909420845181559151805192936101fc939085019291909101906102d0565b50604091909101516002909101805460ff191691151591909117905550565b600160208181526000928352604092839020805481840180548651600296821615610100026000190190911695909504601f810185900485028601850190965285855290949193929091908301828280156102b75780601f1061028c576101008083540402835291602001916102b7565b820191906000526020600020905b81548152906001019060200180831161029a57829003601f168201915b5050506002909301549192505060ff1683565b60005481565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f1061031157805160ff191683800117855561033e565b8280016001018555821561033e579182015b8281111561033e578251825591602001919060010190610323565b5061034a92915061034e565b5090565b61036891905b8082111561034a5760008155600101610354565b9056fea265627a7a72315820a01f5970818d2fba2ec2b7cf86f860311ffce97e0de4f24654e100dbdf28f41d64736f6c63430005100032",
  "deployedBytecode": "0x608060405234801561001057600080fd5b50600436106100415760003560e01c8063111002aa146100465780638d977672146100ee578063b6cb58a514610195575b600080fd5b6100ec6004803603602081101561005c57600080fd5b81019060208101813564010000000081111561007757600080fd5b82018360208201111561008957600080fd5b803590602001918460018302840111640100000000831117156100ab57600080fd5b91908080601f0160208091040260200160405190810160405280939291908181526020018383808284376000920191909152509295506101af945050505050565b005b61010b6004803603602081101561010457600080fd5b503561021b565b604051808481526020018060200183151515158152602001828103825284818151815260200191508051906020019080838360005b83811015610158578181015183820152602001610140565b50505050905090810190601f1680156101855780820380516001836020036101000a031916815260200191505b5094505050505060405180910390f35b61019d6102ca565b60408051918252519081900360200190f35b60008054600190810180835560408051606081018252828152602080820187815282840187905293865284815291909420845181559151805192936101fc939085019291909101906102d0565b50604091909101516002909101805460ff191691151591909117905550565b600160208181526000928352604092839020805481840180548651600296821615610100026000190190911695909504601f810185900485028601850190965285855290949193929091908301828280156102b75780601f1061028c576101008083540402835291602001916102b7565b820191906000526020600020905b81548152906001019060200180831161029a57829003601f168201915b5050506002909301549192505060ff1683565b60005481565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f1061031157805160ff191683800117855561033e565b8280016001018555821561033e579182015b8281111561033e578251825591602001919060010190610323565b5061034a92915061034e565b5090565b61036891905b8082111561034a5760008155600101610354565b9056fea265627a7a72315820a01f5970818d2fba2ec2b7cf86f860311ffce97e0de4f24654e100dbdf28f41d64736f6c63430005100032",
  "sourceMap": "66:419:0:-;;;117:1;90:28;;262:75;8:9:-1;5:2;;;30:1;27;20:12;5:2;-1:-1;293:37:0;;;;;;;;;;;;;;;;;;;-1:-1:-1;;;;;293:10:0;:37;:::i;:::-;66:419;;343:140;404:9;:11;;;;;;;;;444:32;;;;;;;;;;;;;;;;;;;;;;;;425:16;;;;;;;;;;:51;;;;;;;;:16;;:51;;;;;;;;;;;;:::i;:::-;-1:-1:-1;425:51:0;;;;;;;;;;;;-1:-1:-1;;425:51:0;;;;;;;;;;-1:-1:-1;343:140:0:o;66:419::-;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;-1:-1:-1;66:419:0;;;-1:-1:-1;66:419:0;:::i;:::-;;;:::o;:::-;;;;;;;;;;;;;;;;;;;;:::o;:::-;;;;;;;",
  "deployedSourceMap": "66:419:0:-;;;;8:9:-1;5:2;;;30:1;27;20:12;5:2;66:419:0;;;;;;;;;;;;;;;;;;;;;;;;;;;;;343:140;;;;;;13:2:-1;8:3;5:11;2:2;;;29:1;26;19:12;2:2;343:140:0;;;;;;;;21:11:-1;5:28;;2:2;;;46:1;43;36:12;2:2;343:140:0;;35:9:-1;28:4;12:14;8:25;5:40;2:2;;;58:1;55;48:12;2:2;343:140:0;;;;;;100:9:-1;95:1;81:12;77:20;67:8;63:35;60:50;39:11;25:12;22:29;11:107;8:2;;;131:1;128;121:12;8:2;343:140:0;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;30:3:-1;22:6;14;1:33;99:1;81:16;;74:27;;;;-1:-1;343:140:0;;-1:-1:-1;343:140:0;;-1:-1:-1;;;;;343:140:0:i;:::-;;218:37;;;;;;13:2:-1;8:3;5:11;2:2;;;29:1;26;19:12;2:2;-1:-1;218:37:0;;:::i;:::-;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;23:1:-1;8:100;33:3;30:1;27:10;8:100;;;90:11;;;84:18;71:11;;;64:39;52:2;45:10;8:100;;;12:14;218:37:0;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;90:28;;;:::i;:::-;;;;;;;;;;;;;;;;343:140;404:9;:11;;;;;;;;;444:32;;;;;;;;;;;;;;;;;;;;;;;;425:16;;;;;;;;;;:51;;;;;;;;:16;;:51;;;;;;;;;;;;:::i;:::-;-1:-1:-1;425:51:0;;;;;;;;;;;;-1:-1:-1;;425:51:0;;;;;;;;;;-1:-1:-1;343:140:0:o;218:37::-;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;-1:-1:-1;;218:37:0;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;-1:-1:-1;;;218:37:0;;;;;;;-1:-1:-1;;218:37:0;;;:::o;90:28::-;;;;:::o;66:419::-;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;-1:-1:-1;66:419:0;;;-1:-1:-1;66:419:0;:::i;:::-;;;:::o;:::-;;;;;;;;;;;;;;;;;;;;:::o",
  "source": "// SPDX-License-Identifier: MIT\npragma solidity >=0.4.22 <0.9.0;\n\ncontract TodoList {\n    uint256 public taskCount = 0;\n\n    struct Task {\n        uint256 id;\n        string content;\n        bool completed;\n    }\n\n    mapping(uint256 => Task) public tasks;\n\n    constructor() public {\n        createTask(\"Hello Blockchain duniya\");\n    }\n\n    function createTask(string memory _content) public {\n        taskCount++;\n        tasks[taskCount] = Task(taskCount, _content, false);\n    }\n}\n",
  "sourcePath": "/home/starlord/todoBlockchain/contracts/TodoList.sol",
  "ast": {
    "absolutePath": "/home/starlord/todoBlockchain/contracts/TodoList.sol",
    "exportedSymbols": {
      "TodoList": [
        43
      ]
    },
    "id": 44,
    "nodeType": "SourceUnit",
    "nodes": [
      {
        "id": 1,
        "literals": [
          "solidity",
          ">=",
          "0.4",
          ".22",
          "<",
          "0.9",
          ".0"
        ],
        "nodeType": "PragmaDirective",
        "src": "32:32:0"
      },
      {
        "baseContracts": [],
        "contractDependencies": [],
        "contractKind": "contract",
        "documentation": null,
        "fullyImplemented": true,
        "id": 43,
        "linearizedBaseContracts": [
          43
        ],
        "name": "TodoList",
        "nodeType": "ContractDefinition",
        "nodes": [
          {
            "constant": false,
            "id": 4,
            "name": "taskCount",
            "nodeType": "VariableDeclaration",
            "scope": 43,
            "src": "90:28:0",
            "stateVariable": true,
            "storageLocation": "default",
            "typeDescriptions": {
              "typeIdentifier": "t_uint256",
              "typeString": "uint256"
            },
            "typeName": {
              "id": 2,
              "name": "uint256",
              "nodeType": "ElementaryTypeName",
              "src": "90:7:0",
              "typeDescriptions": {
                "typeIdentifier": "t_uint256",
                "typeString": "uint256"
              }
            },
            "value": {
              "argumentTypes": null,
              "hexValue": "30",
              "id": 3,
              "isConstant": false,
              "isLValue": false,
              "isPure": true,
              "kind": "number",
              "lValueRequested": false,
              "nodeType": "Literal",
              "src": "117:1:0",
              "subdenomination": null,
              "typeDescriptions": {
                "typeIdentifier": "t_rational_0_by_1",
                "typeString": "int_const 0"
              },
              "value": "0"
            },
            "visibility": "public"
          },
          {
            "canonicalName": "TodoList.Task",
            "id": 11,
            "members": [
              {
                "constant": false,
                "id": 6,
                "name": "id",
                "nodeType": "VariableDeclaration",
                "scope": 11,
                "src": "147:10:0",
                "stateVariable": false,
                "storageLocation": "default",
                "typeDescriptions": {
                  "typeIdentifier": "t_uint256",
                  "typeString": "uint256"
                },
                "typeName": {
                  "id": 5,
                  "name": "uint256",
                  "nodeType": "ElementaryTypeName",
                  "src": "147:7:0",
                  "typeDescriptions": {
                    "typeIdentifier": "t_uint256",
                    "typeString": "uint256"
                  }
                },
                "value": null,
                "visibility": "internal"
              },
              {
                "constant": false,
                "id": 8,
                "name": "content",
                "nodeType": "VariableDeclaration",
                "scope": 11,
                "src": "167:14:0",
                "stateVariable": false,
                "storageLocation": "default",
                "typeDescriptions": {
                  "typeIdentifier": "t_string_storage_ptr",
                  "typeString": "string"
                },
                "typeName": {
                  "id": 7,
                  "name": "string",
                  "nodeType": "ElementaryTypeName",
                  "src": "167:6:0",
                  "typeDescriptions": {
                    "typeIdentifier": "t_string_storage_ptr",
                    "typeString": "string"
                  }
                },
                "value": null,
                "visibility": "internal"
              },
              {
                "constant": false,
                "id": 10,
                "name": "completed",
                "nodeType": "VariableDeclaration",
                "scope": 11,
                "src": "191:14:0",
                "stateVariable": false,
                "storageLocation": "default",
                "typeDescriptions": {
                  "typeIdentifier": "t_bool",
                  "typeString": "bool"
                },
                "typeName": {
                  "id": 9,
                  "name": "bool",
                  "nodeType": "ElementaryTypeName",
                  "src": "191:4:0",
                  "typeDescriptions": {
                    "typeIdentifier": "t_bool",
                    "typeString": "bool"
                  }
                },
                "value": null,
                "visibility": "internal"
              }
            ],
            "name": "Task",
            "nodeType": "StructDefinition",
            "scope": 43,
            "src": "125:87:0",
            "visibility": "public"
          },
          {
            "constant": false,
            "id": 15,
            "name": "tasks",
            "nodeType": "VariableDeclaration",
            "scope": 43,
            "src": "218:37:0",
            "stateVariable": true,
            "storageLocation": "default",
            "typeDescriptions": {
              "typeIdentifier": "t_mapping\$_t_uint256_\$_t_struct\$_Task_\$11_storage_\$",
              "typeString": "mapping(uint256 => struct TodoList.Task)"
            },
            "typeName": {
              "id": 14,
              "keyType": {
                "id": 12,
                "name": "uint256",
                "nodeType": "ElementaryTypeName",
                "src": "226:7:0",
                "typeDescriptions": {
                  "typeIdentifier": "t_uint256",
                  "typeString": "uint256"
                }
              },
              "nodeType": "Mapping",
              "src": "218:24:0",
              "typeDescriptions": {
                "typeIdentifier": "t_mapping\$_t_uint256_\$_t_struct\$_Task_\$11_storage_\$",
                "typeString": "mapping(uint256 => struct TodoList.Task)"
              },
              "valueType": {
                "contractScope": null,
                "id": 13,
                "name": "Task",
                "nodeType": "UserDefinedTypeName",
                "referencedDeclaration": 11,
                "src": "237:4:0",
                "typeDescriptions": {
                  "typeIdentifier": "t_struct\$_Task_\$11_storage_ptr",
                  "typeString": "struct TodoList.Task"
                }
              }
            },
            "value": null,
            "visibility": "public"
          },
          {
            "body": {
              "id": 22,
              "nodeType": "Block",
              "src": "283:54:0",
              "statements": [
                {
                  "expression": {
                    "argumentTypes": null,
                    "arguments": [
                      {
                        "argumentTypes": null,
                        "hexValue": "48656c6c6f20426c6f636b636861696e2064756e697961",
                        "id": 19,
                        "isConstant": false,
                        "isLValue": false,
                        "isPure": true,
                        "kind": "string",
                        "lValueRequested": false,
                        "nodeType": "Literal",
                        "src": "304:25:0",
                        "subdenomination": null,
                        "typeDescriptions": {
                          "typeIdentifier": "t_stringliteral_52c07a936e2de63a5d170cf6e88bcee73a46b254972cb6ded16a2db828956393",
                          "typeString": "literal_string \"Hello Blockchain duniya\""
                        },
                        "value": "Hello Blockchain duniya"
                      }
                    ],
                    "expression": {
                      "argumentTypes": [
                        {
                          "typeIdentifier": "t_stringliteral_52c07a936e2de63a5d170cf6e88bcee73a46b254972cb6ded16a2db828956393",
                          "typeString": "literal_string \"Hello Blockchain duniya\""
                        }
                      ],
                      "id": 18,
                      "name": "createTask",
                      "nodeType": "Identifier",
                      "overloadedDeclarations": [],
                      "referencedDeclaration": 42,
                      "src": "293:10:0",
                      "typeDescriptions": {
                        "typeIdentifier": "t_function_internal_nonpayable\$_t_string_memory_ptr_\$returns\$__\$",
                        "typeString": "function (string memory)"
                      }
                    },
                    "id": 20,
                    "isConstant": false,
                    "isLValue": false,
                    "isPure": false,
                    "kind": "functionCall",
                    "lValueRequested": false,
                    "names": [],
                    "nodeType": "FunctionCall",
                    "src": "293:37:0",
                    "typeDescriptions": {
                      "typeIdentifier": "t_tuple\$__\$",
                      "typeString": "tuple()"
                    }
                  },
                  "id": 21,
                  "nodeType": "ExpressionStatement",
                  "src": "293:37:0"
                }
              ]
            },
            "documentation": null,
            "id": 23,
            "implemented": true,
            "kind": "constructor",
            "modifiers": [],
            "name": "",
            "nodeType": "FunctionDefinition",
            "parameters": {
              "id": 16,
              "nodeType": "ParameterList",
              "parameters": [],
              "src": "273:2:0"
            },
            "returnParameters": {
              "id": 17,
              "nodeType": "ParameterList",
              "parameters": [],
              "src": "283:0:0"
            },
            "scope": 43,
            "src": "262:75:0",
            "stateMutability": "nonpayable",
            "superFunction": null,
            "visibility": "public"
          },
          {
            "body": {
              "id": 41,
              "nodeType": "Block",
              "src": "394:89:0",
              "statements": [
                {
                  "expression": {
                    "argumentTypes": null,
                    "id": 29,
                    "isConstant": false,
                    "isLValue": false,
                    "isPure": false,
                    "lValueRequested": false,
                    "nodeType": "UnaryOperation",
                    "operator": "++",
                    "prefix": false,
                    "src": "404:11:0",
                    "subExpression": {
                      "argumentTypes": null,
                      "id": 28,
                      "name": "taskCount",
                      "nodeType": "Identifier",
                      "overloadedDeclarations": [],
                      "referencedDeclaration": 4,
                      "src": "404:9:0",
                      "typeDescriptions": {
                        "typeIdentifier": "t_uint256",
                        "typeString": "uint256"
                      }
                    },
                    "typeDescriptions": {
                      "typeIdentifier": "t_uint256",
                      "typeString": "uint256"
                    }
                  },
                  "id": 30,
                  "nodeType": "ExpressionStatement",
                  "src": "404:11:0"
                },
                {
                  "expression": {
                    "argumentTypes": null,
                    "id": 39,
                    "isConstant": false,
                    "isLValue": false,
                    "isPure": false,
                    "lValueRequested": false,
                    "leftHandSide": {
                      "argumentTypes": null,
                      "baseExpression": {
                        "argumentTypes": null,
                        "id": 31,
                        "name": "tasks",
                        "nodeType": "Identifier",
                        "overloadedDeclarations": [],
                        "referencedDeclaration": 15,
                        "src": "425:5:0",
                        "typeDescriptions": {
                          "typeIdentifier": "t_mapping\$_t_uint256_\$_t_struct\$_Task_\$11_storage_\$",
                          "typeString": "mapping(uint256 => struct TodoList.Task storage ref)"
                        }
                      },
                      "id": 33,
                      "indexExpression": {
                        "argumentTypes": null,
                        "id": 32,
                        "name": "taskCount",
                        "nodeType": "Identifier",
                        "overloadedDeclarations": [],
                        "referencedDeclaration": 4,
                        "src": "431:9:0",
                        "typeDescriptions": {
                          "typeIdentifier": "t_uint256",
                          "typeString": "uint256"
                        }
                      },
                      "isConstant": false,
                      "isLValue": true,
                      "isPure": false,
                      "lValueRequested": true,
                      "nodeType": "IndexAccess",
                      "src": "425:16:0",
                      "typeDescriptions": {
                        "typeIdentifier": "t_struct\$_Task_\$11_storage",
                        "typeString": "struct TodoList.Task storage ref"
                      }
                    },
                    "nodeType": "Assignment",
                    "operator": "=",
                    "rightHandSide": {
                      "argumentTypes": null,
                      "arguments": [
                        {
                          "argumentTypes": null,
                          "id": 35,
                          "name": "taskCount",
                          "nodeType": "Identifier",
                          "overloadedDeclarations": [],
                          "referencedDeclaration": 4,
                          "src": "449:9:0",
                          "typeDescriptions": {
                            "typeIdentifier": "t_uint256",
                            "typeString": "uint256"
                          }
                        },
                        {
                          "argumentTypes": null,
                          "id": 36,
                          "name": "_content",
                          "nodeType": "Identifier",
                          "overloadedDeclarations": [],
                          "referencedDeclaration": 25,
                          "src": "460:8:0",
                          "typeDescriptions": {
                            "typeIdentifier": "t_string_memory_ptr",
                            "typeString": "string memory"
                          }
                        },
                        {
                          "argumentTypes": null,
                          "hexValue": "66616c7365",
                          "id": 37,
                          "isConstant": false,
                          "isLValue": false,
                          "isPure": true,
                          "kind": "bool",
                          "lValueRequested": false,
                          "nodeType": "Literal",
                          "src": "470:5:0",
                          "subdenomination": null,
                          "typeDescriptions": {
                            "typeIdentifier": "t_bool",
                            "typeString": "bool"
                          },
                          "value": "false"
                        }
                      ],
                      "expression": {
                        "argumentTypes": [
                          {
                            "typeIdentifier": "t_uint256",
                            "typeString": "uint256"
                          },
                          {
                            "typeIdentifier": "t_string_memory_ptr",
                            "typeString": "string memory"
                          },
                          {
                            "typeIdentifier": "t_bool",
                            "typeString": "bool"
                          }
                        ],
                        "id": 34,
                        "name": "Task",
                        "nodeType": "Identifier",
                        "overloadedDeclarations": [],
                        "referencedDeclaration": 11,
                        "src": "444:4:0",
                        "typeDescriptions": {
                          "typeIdentifier": "t_type\$_t_struct\$_Task_\$11_storage_ptr_\$",
                          "typeString": "type(struct TodoList.Task storage pointer)"
                        }
                      },
                      "id": 38,
                      "isConstant": false,
                      "isLValue": false,
                      "isPure": false,
                      "kind": "structConstructorCall",
                      "lValueRequested": false,
                      "names": [],
                      "nodeType": "FunctionCall",
                      "src": "444:32:0",
                      "typeDescriptions": {
                        "typeIdentifier": "t_struct\$_Task_\$11_memory",
                        "typeString": "struct TodoList.Task memory"
                      }
                    },
                    "src": "425:51:0",
                    "typeDescriptions": {
                      "typeIdentifier": "t_struct\$_Task_\$11_storage",
                      "typeString": "struct TodoList.Task storage ref"
                    }
                  },
                  "id": 40,
                  "nodeType": "ExpressionStatement",
                  "src": "425:51:0"
                }
              ]
            },
            "documentation": null,
            "id": 42,
            "implemented": true,
            "kind": "function",
            "modifiers": [],
            "name": "createTask",
            "nodeType": "FunctionDefinition",
            "parameters": {
              "id": 26,
              "nodeType": "ParameterList",
              "parameters": [
                {
                  "constant": false,
                  "id": 25,
                  "name": "_content",
                  "nodeType": "VariableDeclaration",
                  "scope": 42,
                  "src": "363:22:0",
                  "stateVariable": false,
                  "storageLocation": "memory",
                  "typeDescriptions": {
                    "typeIdentifier": "t_string_memory_ptr",
                    "typeString": "string"
                  },
                  "typeName": {
                    "id": 24,
                    "name": "string",
                    "nodeType": "ElementaryTypeName",
                    "src": "363:6:0",
                    "typeDescriptions": {
                      "typeIdentifier": "t_string_storage_ptr",
                      "typeString": "string"
                    }
                  },
                  "value": null,
                  "visibility": "internal"
                }
              ],
              "src": "362:24:0"
            },
            "returnParameters": {
              "id": 27,
              "nodeType": "ParameterList",
              "parameters": [],
              "src": "394:0:0"
            },
            "scope": 43,
            "src": "343:140:0",
            "stateMutability": "nonpayable",
            "superFunction": null,
            "visibility": "public"
          }
        ],
        "scope": 44,
        "src": "66:419:0"
      }
    ],
    "src": "32:454:0"
  },
  "legacyAST": {
    "attributes": {
      "absolutePath": "/home/starlord/todoBlockchain/contracts/TodoList.sol",
      "exportedSymbols": {
        "TodoList": [
          43
        ]
      }
    },
    "children": [
      {
        "attributes": {
          "literals": [
            "solidity",
            ">=",
            "0.4",
            ".22",
            "<",
            "0.9",
            ".0"
          ]
        },
        "id": 1,
        "name": "PragmaDirective",
        "src": "32:32:0"
      },
      {
        "attributes": {
          "baseContracts": [
            null
          ],
          "contractDependencies": [
            null
          ],
          "contractKind": "contract",
          "documentation": null,
          "fullyImplemented": true,
          "linearizedBaseContracts": [
            43
          ],
          "name": "TodoList",
          "scope": 44
        },
        "children": [
          {
            "attributes": {
              "constant": false,
              "name": "taskCount",
              "scope": 43,
              "stateVariable": true,
              "storageLocation": "default",
              "type": "uint256",
              "visibility": "public"
            },
            "children": [
              {
                "attributes": {
                  "name": "uint256",
                  "type": "uint256"
                },
                "id": 2,
                "name": "ElementaryTypeName",
                "src": "90:7:0"
              },
              {
                "attributes": {
                  "argumentTypes": null,
                  "hexvalue": "30",
                  "isConstant": false,
                  "isLValue": false,
                  "isPure": true,
                  "lValueRequested": false,
                  "subdenomination": null,
                  "token": "number",
                  "type": "int_const 0",
                  "value": "0"
                },
                "id": 3,
                "name": "Literal",
                "src": "117:1:0"
              }
            ],
            "id": 4,
            "name": "VariableDeclaration",
            "src": "90:28:0"
          },
          {
            "attributes": {
              "canonicalName": "TodoList.Task",
              "name": "Task",
              "scope": 43,
              "visibility": "public"
            },
            "children": [
              {
                "attributes": {
                  "constant": false,
                  "name": "id",
                  "scope": 11,
                  "stateVariable": false,
                  "storageLocation": "default",
                  "type": "uint256",
                  "value": null,
                  "visibility": "internal"
                },
                "children": [
                  {
                    "attributes": {
                      "name": "uint256",
                      "type": "uint256"
                    },
                    "id": 5,
                    "name": "ElementaryTypeName",
                    "src": "147:7:0"
                  }
                ],
                "id": 6,
                "name": "VariableDeclaration",
                "src": "147:10:0"
              },
              {
                "attributes": {
                  "constant": false,
                  "name": "content",
                  "scope": 11,
                  "stateVariable": false,
                  "storageLocation": "default",
                  "type": "string",
                  "value": null,
                  "visibility": "internal"
                },
                "children": [
                  {
                    "attributes": {
                      "name": "string",
                      "type": "string"
                    },
                    "id": 7,
                    "name": "ElementaryTypeName",
                    "src": "167:6:0"
                  }
                ],
                "id": 8,
                "name": "VariableDeclaration",
                "src": "167:14:0"
              },
              {
                "attributes": {
                  "constant": false,
                  "name": "completed",
                  "scope": 11,
                  "stateVariable": false,
                  "storageLocation": "default",
                  "type": "bool",
                  "value": null,
                  "visibility": "internal"
                },
                "children": [
                  {
                    "attributes": {
                      "name": "bool",
                      "type": "bool"
                    },
                    "id": 9,
                    "name": "ElementaryTypeName",
                    "src": "191:4:0"
                  }
                ],
                "id": 10,
                "name": "VariableDeclaration",
                "src": "191:14:0"
              }
            ],
            "id": 11,
            "name": "StructDefinition",
            "src": "125:87:0"
          },
          {
            "attributes": {
              "constant": false,
              "name": "tasks",
              "scope": 43,
              "stateVariable": true,
              "storageLocation": "default",
              "type": "mapping(uint256 => struct TodoList.Task)",
              "value": null,
              "visibility": "public"
            },
            "children": [
              {
                "attributes": {
                  "type": "mapping(uint256 => struct TodoList.Task)"
                },
                "children": [
                  {
                    "attributes": {
                      "name": "uint256",
                      "type": "uint256"
                    },
                    "id": 12,
                    "name": "ElementaryTypeName",
                    "src": "226:7:0"
                  },
                  {
                    "attributes": {
                      "contractScope": null,
                      "name": "Task",
                      "referencedDeclaration": 11,
                      "type": "struct TodoList.Task"
                    },
                    "id": 13,
                    "name": "UserDefinedTypeName",
                    "src": "237:4:0"
                  }
                ],
                "id": 14,
                "name": "Mapping",
                "src": "218:24:0"
              }
            ],
            "id": 15,
            "name": "VariableDeclaration",
            "src": "218:37:0"
          },
          {
            "attributes": {
              "documentation": null,
              "implemented": true,
              "isConstructor": true,
              "kind": "constructor",
              "modifiers": [
                null
              ],
              "name": "",
              "scope": 43,
              "stateMutability": "nonpayable",
              "superFunction": null,
              "visibility": "public"
            },
            "children": [
              {
                "attributes": {
                  "parameters": [
                    null
                  ]
                },
                "children": [],
                "id": 16,
                "name": "ParameterList",
                "src": "273:2:0"
              },
              {
                "attributes": {
                  "parameters": [
                    null
                  ]
                },
                "children": [],
                "id": 17,
                "name": "ParameterList",
                "src": "283:0:0"
              },
              {
                "children": [
                  {
                    "children": [
                      {
                        "attributes": {
                          "argumentTypes": null,
                          "isConstant": false,
                          "isLValue": false,
                          "isPure": false,
                          "isStructConstructorCall": false,
                          "lValueRequested": false,
                          "names": [
                            null
                          ],
                          "type": "tuple()",
                          "type_conversion": false
                        },
                        "children": [
                          {
                            "attributes": {
                              "argumentTypes": [
                                {
                                  "typeIdentifier": "t_stringliteral_52c07a936e2de63a5d170cf6e88bcee73a46b254972cb6ded16a2db828956393",
                                  "typeString": "literal_string \"Hello Blockchain duniya\""
                                }
                              ],
                              "overloadedDeclarations": [
                                null
                              ],
                              "referencedDeclaration": 42,
                              "type": "function (string memory)",
                              "value": "createTask"
                            },
                            "id": 18,
                            "name": "Identifier",
                            "src": "293:10:0"
                          },
                          {
                            "attributes": {
                              "argumentTypes": null,
                              "hexvalue": "48656c6c6f20426c6f636b636861696e2064756e697961",
                              "isConstant": false,
                              "isLValue": false,
                              "isPure": true,
                              "lValueRequested": false,
                              "subdenomination": null,
                              "token": "string",
                              "type": "literal_string \"Hello Blockchain duniya\"",
                              "value": "Hello Blockchain duniya"
                            },
                            "id": 19,
                            "name": "Literal",
                            "src": "304:25:0"
                          }
                        ],
                        "id": 20,
                        "name": "FunctionCall",
                        "src": "293:37:0"
                      }
                    ],
                    "id": 21,
                    "name": "ExpressionStatement",
                    "src": "293:37:0"
                  }
                ],
                "id": 22,
                "name": "Block",
                "src": "283:54:0"
              }
            ],
            "id": 23,
            "name": "FunctionDefinition",
            "src": "262:75:0"
          },
          {
            "attributes": {
              "documentation": null,
              "implemented": true,
              "isConstructor": false,
              "kind": "function",
              "modifiers": [
                null
              ],
              "name": "createTask",
              "scope": 43,
              "stateMutability": "nonpayable",
              "superFunction": null,
              "visibility": "public"
            },
            "children": [
              {
                "children": [
                  {
                    "attributes": {
                      "constant": false,
                      "name": "_content",
                      "scope": 42,
                      "stateVariable": false,
                      "storageLocation": "memory",
                      "type": "string",
                      "value": null,
                      "visibility": "internal"
                    },
                    "children": [
                      {
                        "attributes": {
                          "name": "string",
                          "type": "string"
                        },
                        "id": 24,
                        "name": "ElementaryTypeName",
                        "src": "363:6:0"
                      }
                    ],
                    "id": 25,
                    "name": "VariableDeclaration",
                    "src": "363:22:0"
                  }
                ],
                "id": 26,
                "name": "ParameterList",
                "src": "362:24:0"
              },
              {
                "attributes": {
                  "parameters": [
                    null
                  ]
                },
                "children": [],
                "id": 27,
                "name": "ParameterList",
                "src": "394:0:0"
              },
              {
                "children": [
                  {
                    "children": [
                      {
                        "attributes": {
                          "argumentTypes": null,
                          "isConstant": false,
                          "isLValue": false,
                          "isPure": false,
                          "lValueRequested": false,
                          "operator": "++",
                          "prefix": false,
                          "type": "uint256"
                        },
                        "children": [
                          {
                            "attributes": {
                              "argumentTypes": null,
                              "overloadedDeclarations": [
                                null
                              ],
                              "referencedDeclaration": 4,
                              "type": "uint256",
                              "value": "taskCount"
                            },
                            "id": 28,
                            "name": "Identifier",
                            "src": "404:9:0"
                          }
                        ],
                        "id": 29,
                        "name": "UnaryOperation",
                        "src": "404:11:0"
                      }
                    ],
                    "id": 30,
                    "name": "ExpressionStatement",
                    "src": "404:11:0"
                  },
                  {
                    "children": [
                      {
                        "attributes": {
                          "argumentTypes": null,
                          "isConstant": false,
                          "isLValue": false,
                          "isPure": false,
                          "lValueRequested": false,
                          "operator": "=",
                          "type": "struct TodoList.Task storage ref"
                        },
                        "children": [
                          {
                            "attributes": {
                              "argumentTypes": null,
                              "isConstant": false,
                              "isLValue": true,
                              "isPure": false,
                              "lValueRequested": true,
                              "type": "struct TodoList.Task storage ref"
                            },
                            "children": [
                              {
                                "attributes": {
                                  "argumentTypes": null,
                                  "overloadedDeclarations": [
                                    null
                                  ],
                                  "referencedDeclaration": 15,
                                  "type": "mapping(uint256 => struct TodoList.Task storage ref)",
                                  "value": "tasks"
                                },
                                "id": 31,
                                "name": "Identifier",
                                "src": "425:5:0"
                              },
                              {
                                "attributes": {
                                  "argumentTypes": null,
                                  "overloadedDeclarations": [
                                    null
                                  ],
                                  "referencedDeclaration": 4,
                                  "type": "uint256",
                                  "value": "taskCount"
                                },
                                "id": 32,
                                "name": "Identifier",
                                "src": "431:9:0"
                              }
                            ],
                            "id": 33,
                            "name": "IndexAccess",
                            "src": "425:16:0"
                          },
                          {
                            "attributes": {
                              "argumentTypes": null,
                              "isConstant": false,
                              "isLValue": false,
                              "isPure": false,
                              "isStructConstructorCall": true,
                              "lValueRequested": false,
                              "names": [
                                null
                              ],
                              "type": "struct TodoList.Task memory",
                              "type_conversion": false
                            },
                            "children": [
                              {
                                "attributes": {
                                  "argumentTypes": [
                                    {
                                      "typeIdentifier": "t_uint256",
                                      "typeString": "uint256"
                                    },
                                    {
                                      "typeIdentifier": "t_string_memory_ptr",
                                      "typeString": "string memory"
                                    },
                                    {
                                      "typeIdentifier": "t_bool",
                                      "typeString": "bool"
                                    }
                                  ],
                                  "overloadedDeclarations": [
                                    null
                                  ],
                                  "referencedDeclaration": 11,
                                  "type": "type(struct TodoList.Task storage pointer)",
                                  "value": "Task"
                                },
                                "id": 34,
                                "name": "Identifier",
                                "src": "444:4:0"
                              },
                              {
                                "attributes": {
                                  "argumentTypes": null,
                                  "overloadedDeclarations": [
                                    null
                                  ],
                                  "referencedDeclaration": 4,
                                  "type": "uint256",
                                  "value": "taskCount"
                                },
                                "id": 35,
                                "name": "Identifier",
                                "src": "449:9:0"
                              },
                              {
                                "attributes": {
                                  "argumentTypes": null,
                                  "overloadedDeclarations": [
                                    null
                                  ],
                                  "referencedDeclaration": 25,
                                  "type": "string memory",
                                  "value": "_content"
                                },
                                "id": 36,
                                "name": "Identifier",
                                "src": "460:8:0"
                              },
                              {
                                "attributes": {
                                  "argumentTypes": null,
                                  "hexvalue": "66616c7365",
                                  "isConstant": false,
                                  "isLValue": false,
                                  "isPure": true,
                                  "lValueRequested": false,
                                  "subdenomination": null,
                                  "token": "bool",
                                  "type": "bool",
                                  "value": "false"
                                },
                                "id": 37,
                                "name": "Literal",
                                "src": "470:5:0"
                              }
                            ],
                            "id": 38,
                            "name": "FunctionCall",
                            "src": "444:32:0"
                          }
                        ],
                        "id": 39,
                        "name": "Assignment",
                        "src": "425:51:0"
                      }
                    ],
                    "id": 40,
                    "name": "ExpressionStatement",
                    "src": "425:51:0"
                  }
                ],
                "id": 41,
                "name": "Block",
                "src": "394:89:0"
              }
            ],
            "id": 42,
            "name": "FunctionDefinition",
            "src": "343:140:0"
          }
        ],
        "id": 43,
        "name": "ContractDefinition",
        "src": "66:419:0"
      }
    ],
    "id": 44,
    "name": "SourceUnit",
    "src": "32:454:0"
  },
  "compiler": {
    "name": "solc",
    "version": "0.5.16+commit.9c3226ce.Emscripten.clang"
  },
  "networks": {
    "5777": {
      "events": {},
      "links": {},
      "address": "0x5e6481b9A7F5b447033a72de06bDFEbf66C00ABe",
      "transactionHash": "0xf296786ae43f745e5ac0d1cc76385fb27d8ec833cf125a86b00deda893024da5"
    }
  },
  "schemaVersion": "3.4.1",
  "updatedAt": "2021-05-27T07:08:40.131Z",
  "networkType": "ethereum",
  "devdoc": {
    "methods": {}
  },
  "userdoc": {
    "methods": {}
  }
};
