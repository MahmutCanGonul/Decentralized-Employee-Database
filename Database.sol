pragma solidity ^0.8.0;

contract Database{

   struct Employee{
       uint256 id;
       bytes32 uid;
       string name;
       string employeeAddress;
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
       uint256 totalCoin;
       string companyAddress;
       string companyName;
       uint256 timeStamp; 
   }
   struct Invite{
       uint256 id;
       string employeeAddress;
       string companyAddress;
       uint256 offerPrice;
       bool accepted;
       bool rejected;
       uint256 timeStamp;
   }

    uint256 companyCount=0;
    uint256 employeeCount=0;
    uint256 inviteCount=0;
    mapping(uint256=>Company) public company;
    mapping(uint256=>Employee) public employee;
    mapping(uint256=>Invite) public invite;
    event CompanyCreated(uint256 id, string _companyAddress,string _companyName,uint256 _timestamp);
    event EmployeeCreated(uint256 id,bytes32 uid,string name,string employeeAddress,string companyAddress ,string phoneNumber,string location,uint256 timeStamp,string job,uint256 salary,string national);
    event InviteCreated(uint256 id,string _employeeAddress,string _companyAddress,uint256 _offerPrice,bool _accepted,bool _rejected,uint256 _timeStamp);
    function ControlCompanyInfoForCreatedCompany(string memory _companyAddress,string memory _companyName)private view returns(bool){
        bool isValid=true;
        for(uint i=0; i<companyCount;i++){
            if(keccak256(bytes(company[i].companyAddress)) == keccak256(bytes(_companyAddress)) ||
              keccak256(bytes(company[i].companyName)) == keccak256(bytes(_companyName))){
                isValid=false;
            }
        }
        return isValid;
    }
    function ControlEmployeeInfoForInvite(string memory _employeeAddress)private view returns(bool){
        bool isValid =false;
        for(uint256 i=0; i<employeeCount;i++){
            if(keccak256(bytes(_employeeAddress)) == keccak256(bytes(employee[i].employeeAddress))){
                isValid = true;
                break;
            }
        }
        return isValid;
    }
    
    function CreatedInvite(string memory _employeeAddress,string memory _companyAddress,uint256 _offerPrice)public{
        require(ControlEmployeeInfoForInvite(_employeeAddress) == true,"Can not found employee!");
        require(ControlCompanyInfoForCreatedCompany(_companyAddress,"") == false,"Can not found Company!"); 
        require(_offerPrice > 0,"Coin value is not valid!");
        require(GetCompanyFromAddress(_companyAddress).totalCoin >=_offerPrice,"Company Coin is not enough!");
        uint256 _timeStamp = block.timestamp;
        invite[inviteCount] = Invite(inviteCount,_employeeAddress,_companyAddress,_offerPrice,false,false,_timeStamp);
        emit InviteCreated(inviteCount,_employeeAddress,_companyAddress,_offerPrice,false,false,_timeStamp);
        inviteCount++;
              
    } 
     
     function CreatedCompany(string memory _companyAddress,string memory _companyName)public{
        require(bytes(_companyAddress).length == 42,"You must enter the cypto wallet address!");
        require(bytes(_companyName).length > 2,"You must enter the company name!");
        require(ControlCompanyInfoForCreatedCompany(_companyAddress,_companyName) == true,"Address or Name already registered!");
        uint256 _time = block.timestamp;
        company[companyCount] = Company(companyCount,0,_companyAddress,_companyName,_time);
        emit CompanyCreated(companyCount,_companyAddress,_companyName,_time);
        companyCount++; 
          
     }
    
     function AddEmployee(string memory _name,string memory _employeeAddress,string memory _companyAddress,string memory _phoneNumber,string memory _location,string memory _job,
     uint256  _salary,string memory _national)public{
         require(bytes(_name).length > 1,"Enter a name!");
         require(bytes(_companyAddress).length > 1,"You must enter the cypto wallet address!");
         require(bytes(_phoneNumber).length > 1,"Enter a phone number!");
         require(bytes(_location).length > 1,"Enter a location!");
         require(bytes(_job).length > 1,"Enter a job!");
         require(bytes(_national).length > 1,"Enter a national!");
        
         for(uint i=0; i<companyCount;i++){
             if(keccak256(bytes(_companyAddress)) == keccak256(bytes(company[i].companyAddress))){
                    bytes32 _uid = keccak256(abi.encodePacked(employeeCount));
                    uint256 _time = block.timestamp; 
                    employee[employeeCount] = Employee(
                        employeeCount,
                        _uid,
                        _name,
                        _employeeAddress,
                        _companyAddress,
                       _phoneNumber,
                       _location,
                       _time,
                       _job,
                      _salary,
                       _national

                    );
                    employee[employeeCount] = Employee(employeeCount,_uid,_name,_employeeAddress,_companyAddress,_phoneNumber,_location,_time,_job,_salary,_national);
                    emit EmployeeCreated(employeeCount,_uid,_name,_employeeAddress,_companyAddress,_phoneNumber,_location,_time,_job,_salary,_national);
                    employeeCount++;
                    break;        
               }
           }

       }

       function RemoveEmployee(string memory _companyAddress,uint256 _id)public{
           for(uint i=0; i<companyCount;i++){
                if(keccak256(bytes(company[i].companyAddress)) == keccak256(bytes(_companyAddress))){
                     for(uint j=0; j<employeeCount;j++){
                         if(employee[j].uid == keccak256(abi.encodePacked(_id))){
                                 employee[j].employeeAddress="***";
                                 employee[j].companyAddress="***";
                                 employee[j].phoneNumber="***";
                                 employee[j].name="***";
                                 employee[j].location="***";
                                 employee[j].national="***";
                                 employee[j].job="***";
                                 break;
                         }
                     }
                }
           }
       }
       function UpdateEmployeeSalary(string memory _name,string memory _companyAddress,uint256 _salary)public{
                  require(bytes(_name).length > 1,"You must enter the name of employee");
                  require(bytes(_companyAddress).length == 42,"You must enter the Company Crypto wallet address");
                  require(_salary > 0,"Enter the salary of the employee");
                  bool _isUpdate=false;
                  for(uint i=0; i<companyCount;i++){
                      if(keccak256(bytes(company[i].companyAddress)) == keccak256(bytes(_companyAddress))){
                          for(uint j=0; j<employeeCount;j++){
                              if(keccak256(bytes(employee[j].name)) == keccak256(bytes(_name))){
                                  employee[j].salary = _salary;
                                  _isUpdate=true;
                                  break;
                              }
                          }
                      }

                      if(_isUpdate)
                          break;
                  }
       }
        
       function EmployeesNumberFromCompany(string memory _companyName)public view returns(uint256){
           require(bytes(_companyName).length >1,"Enter the name of the company!");
           uint256 _employeeCounter=0;
           for(uint i=0; i<companyCount;i++){
              if(keccak256(bytes(company[i].companyName)) == keccak256(bytes(_companyName))){
                        for(uint j=0; j<employeeCount;j++){
                            if(keccak256(bytes(employee[j].companyAddress)) == keccak256(bytes(company[i].companyAddress))){
                                  _employeeCounter++;
                            }
                        }
                        break;
              }
         }
         return _employeeCounter;
       }
       function EmployeesExpensesFromCompany(string memory _companyName)public view returns(uint256){
           require(bytes(_companyName).length >1,"Enter the name of the company!");
           uint256 _expenses=0;
           for(uint i=0; i<companyCount;i++){
              if(keccak256(bytes(company[i].companyName)) == keccak256(bytes(_companyName))){
                        for(uint j=0; j<employeeCount;j++){
                            if(keccak256(bytes(employee[j].companyAddress)) == keccak256(bytes(company[i].companyAddress))){
                                  _expenses += employee[j].salary;
                            }
                        }
                    break;
              }
       }
        return _expenses;
   }
   function GetCompanyFromAddress(string memory _companyAddress)private view returns(Company memory){
      Company memory _company;
      for(uint256 i=0; i<companyCount;i++){
          if(keccak256(bytes(_companyAddress)) == keccak256(bytes(company[i].companyAddress))){
              _company = company[i];
          }
      }
     return _company;
   }
   function GetEmployeesFromLocation(string memory _location)public view returns(Employee  [] memory){
       require(bytes(_location).length >1,"Enter the location!");
       uint _counter=0;
       Employee [] memory _employees = new Employee[](employeeCount);
       for(uint i=0; i<employeeCount;i++){
           if(keccak256(bytes(_location)) == keccak256(bytes(employee[i].location))){
               _employees[_counter] = employee[i];
               _counter++;
           }
       }
       return _employees;
   } 
   function GetEmployeesFromCompany(string memory _companyName)public view returns(Employee  [] memory){
        require(bytes(_companyName).length >1,"Enter the name of the company!");
        uint _counter=0;
        Employee [] memory _employees = new Employee[](employeeCount);
        for(uint i=0; i<companyCount;i++){
            if(keccak256(bytes(_companyName)) == keccak256(bytes(company[i].companyName))){
                for(uint j=0; j<employeeCount;j++){
                    if(keccak256(bytes(employee[j].companyAddress)) == keccak256(bytes(company[i].companyAddress))){
                        _employees[_counter] = employee[j];
                        _counter++;
        
                    }
                }
                break;
            }
        }
        return _employees;
    }
   

    
}
