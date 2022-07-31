pragma solidity ^0.8.0;
contract Database{

   struct Employee{
       uint256 id;
       bytes32 uid;
       string name;
       string companyAddress;
       string phoneNumber;
       string location;
       uint256 timeStamp;
       string job;
       uint256 salary;
       string national;
   }
    struct Company{
       uint256 id;
       string companyAddress;
       string companyName; 
   }
     uint256 companyCount=0;
     uint256 employeeCount=0;
     Company[] companyData;
     mapping(uint256=>Company) public company;
     mapping(uint256=>Employee) public employee;
     event CompanyCreated(uint256 id, string _companyAddress,string _companyName);
     event EmployeeCreated(bytes32 uid,string name,string companyAddress ,string phoneNumber,string location,uint256 timeStamp,string job,uint256 salary,string national);
    
     function CreatedCompany(string memory _companyAddress,string memory _companyName)public{
          require(bytes(_companyAddress).length > 1,"You must enter the cypto wallet address!");
          require(bytes(_companyName).length > 1,"You must enter the company name!");
          bool isAlreadyCreated=false;
          for(uint i=0; i<companyData.length;i++){
                  if(keccak256(bytes(_companyAddress)) == keccak256(bytes(companyData[i].companyAddress))){
                      isAlreadyCreated = true;
                  }      
          }
          if(!isAlreadyCreated){
                  company[companyCount] = Company(companyCount,_companyAddress,_companyName);
                  emit CompanyCreated(companyCount,_companyAddress,_companyName);
                  companyData.push(company[companyCount]);
                  companyCount++;
          }
     }
    
     function AddEmployee(string memory _name,string memory _companyAddress,string memory _phoneNumber,string memory _location,string memory _job,
     uint256  _salary,string memory _national)public{
         require(bytes(_name).length > 1,"Enter a name!");
         require(bytes(_companyAddress).length > 1,"You must enter the cypto wallet address!");
         require(bytes(_phoneNumber).length > 1,"Enter a phone number!");
         require(bytes(_location).length > 1,"Enter a location!");
         require(bytes(_job).length > 1,"Enter a job!");
         require(bytes(_national).length > 1,"Enter a national!");
        
         for(uint i=0; i<companyData.length;i++){
             if(keccak256(bytes(_companyAddress)) == keccak256(bytes(companyData[i].companyAddress))){
                    bytes32 _uid = keccak256(abi.encodePacked(block.timestamp));
                    uint256 _time = block.timestamp; 
                    employee[employeeCount] = Employee(
                        employeeCount,
                        _uid,
                        _name,
                        _companyAddress,
                       _phoneNumber,
                       _location,
                       _time,
                       _job,
                      _salary,
                       _national

                    );
                    employee[employeeCount] = Employee(employeeCount,_uid,_name,_companyAddress,_phoneNumber,_location,_time,_job,_salary,_national);
                    emit EmployeeCreated(_uid,_name,_companyAddress,_phoneNumber,_location,_time,_job,_salary,_national);
                    employeeCount++;
                    break;        
               }
           }
       }
       
   
   
   
   
   
   
   
   
   
   
   
   }
