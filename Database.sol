//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract ERC20Basic is IERC20 {

    string public constant name = "EmployeeCoin";
    string public constant symbol = "ECX";
    uint8 public constant decimals = 1;


    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;

    uint256 totalSupply_ = 10 ether;


   constructor() {
    balances[msg.sender] = totalSupply_;
    }

    function totalSupply() public override view returns (uint256) {
    return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender]-numTokens;
        balances[receiver] = balances[receiver]+numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner]-numTokens;
        allowed[owner][msg.sender] = allowed[owner][msg.sender]-numTokens;
        balances[buyer] = balances[buyer]+numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}

contract ECXToken{
    IERC20 public token;
    event Bought(uint256 amount);
    event Sold(uint256 amount);
    constructor(){
        token = new ERC20Basic();
    }
    
    function buy() payable public {
       uint256 amountTobuy = msg.value;
       uint256 tokenBalance = token.balanceOf(address(this));
       require(amountTobuy > 0, "You need to send some ether");
       require(amountTobuy <= tokenBalance, "Not enough tokens in the reserve");
       token.transfer(msg.sender, amountTobuy);
       emit Bought(amountTobuy);
    }

    function sell(uint256 amount) public {
        require(amount > 0, "You need to sell at least some tokens");
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        token.transferFrom(msg.sender, address(this), amount);
        payable(msg.sender).transfer(amount);
        emit Sold(amount);
    }
    function transfer(address sender,address reciver,uint256 amount)public{
        require(amount > 0, "You need to sell at least some tokens");
        uint256 allowance = token.allowance(sender, reciver);
        require(allowance >= amount, "Check the token allowance");
        token.transferFrom(sender, reciver, amount);
        payable(sender).transfer(amount);
        emit Sold(amount);
    }
}

contract TechnicalFunctions{
    
    function parseAddress(string memory _a) public pure returns (address _parsedAddress) {
    bytes memory tmp = bytes(_a);
    uint160 iaddr = 0;
    uint160 b1;
    uint160 b2;
    for (uint i = 2; i < 2 + 2 * 20; i += 2) {
        iaddr *= 256;
        b1 = uint160(uint8(tmp[i]));
        b2 = uint160(uint8(tmp[i + 1]));
        if ((b1 >= 97) && (b1 <= 102)) {
            b1 -= 87;
        } else if ((b1 >= 65) && (b1 <= 70)) {
            b1 -= 55;
        } else if ((b1 >= 48) && (b1 <= 57)) {
            b1 -= 48;
        }
        if ((b2 >= 97) && (b2 <= 102)) {
            b2 -= 87;
        } else if ((b2 >= 65) && (b2 <= 70)) {
            b2 -= 55;
        } else if ((b2 >= 48) && (b2 <= 57)) {
            b2 -= 48;
        }
        iaddr += (b1 * 16 + b2);
    }
    return address(iaddr);
}
}


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
  

    ECXToken token;
    TechnicalFunctions technical;
    uint256 companyCount=0;
    uint256 employeeCount=0;
    uint256 inviteCount=0;
    mapping(uint256=>Company) public company;
    mapping(uint256=>Employee) public employee;
    mapping(uint256=>Invite) public invite;
    event CompanyCreated(uint256 id, string _companyAddress,string _companyName,uint256 _timestamp);
    event EmployeeCreated(uint256 id,bytes32 uid,string name,string employeeAddress,string companyAddress ,string phoneNumber,string location,uint256 timeStamp,string job,uint256 salary,string national);
    event InviteCreated(uint256 id,string _employeeAddress,string _companyAddress,uint256 _offerPrice,bool _accepted,bool _rejected,uint256 _timeStamp);
    
    constructor(){
        technical = new TechnicalFunctions();
        token = new ECXToken();
    }

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
    
     function AddEmployee(string memory _name,string memory _employeeAddress,string memory _companyAddress,
     string memory _phoneNumber,string memory _location,string memory _job,
     uint256  _salary,string memory _national)public{
         require(bytes(_name).length > 1,"Enter a name!");
         require(bytes(_companyAddress).length > 1,"You must enter the cypto wallet address!");
         require(bytes(_phoneNumber).length > 1,"Enter a phone number!");
         require(bytes(_location).length > 1,"Enter a location!");
         require(bytes(_job).length > 1,"Enter a job!");
         require(bytes(_national).length > 1,"Enter a national!");
         require(ControlEmployeeInfoForInvite(_employeeAddress) == false,"This employee address already added");
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
       function UpdateEmployeeSalary(string memory _employeeAddress,string memory _companyAddress,uint256 _salary)public{
                require(bytes(_employeeAddress).length == 42,"You must enter the name of employee");
                require(bytes(_companyAddress).length == 42,"You must enter the Company Crypto wallet address");
                require(_salary > 0,"Enter the salary of the employee");
                for(uint i=0; i<employeeCount;i++){
                        if(keccak256(bytes(employee[i].employeeAddress)) == keccak256(bytes(_employeeAddress))
                        && keccak256(bytes(employee[i].companyAddress)) == keccak256(bytes(_companyAddress))){
                                employee[i].salary = _salary;
                                break;
                            }
                        }
       }
       function UpdateInviteDecision(string memory _employeeAddress,uint256 _id,bool _desicion)public{
           require(ControlEmployeeInfoForInvite(_employeeAddress) == true,"Employee Address is not valid!");
           require(_id >= 0,"Id issue detected!");
           if(keccak256(bytes(invite[_id].employeeAddress)) == keccak256(bytes(_employeeAddress))){
                      if(_desicion){
                          uint daysDiff = (block.timestamp-GetTimeStampFromEmployee(_employeeAddress)) / 60 / 60 / 24; 
                          if(daysDiff >= 365 && invite[_id].accepted == false && invite[_id].rejected == false){
                               token.transfer(
                                technical.parseAddress(invite[_id].companyAddress),
                                technical.parseAddress(invite[_id].employeeAddress),
                                invite[_id].offerPrice);
                               invite[_id].accepted = true;
                               RemoveEmployee(GetCompanyAddressFromEmployee(_employeeAddress),GetIdFromEmployee(_employeeAddress));
                               Employee memory _employee = GetEmployeeFromAddress(invite[_id].employeeAddress);
                               AddEmployee(_employee.name,_employee.employeeAddress,
                               invite[_id].companyAddress,_employee.phoneNumber,_employee.location,
                               _employee.job,invite[_id].offerPrice,_employee.national);
                          }   
                      }
                      else{
                          invite[_id].rejected = true;
                      }
           }

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
   function GetEmployeeFromAddress(string memory _employeeAddress)private view returns(Employee memory){
      Employee memory _employee;
      for(uint256 i=0; i<employeeCount;i++){
          if(keccak256(bytes(_employeeAddress)) == keccak256(bytes(employee[i].employeeAddress))){
              _employee = employee[i];
          }
      }
     return _employee;
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
   function GetEmployeesFromCompany(string memory _companyAddress)public view returns(Employee  [] memory){
        require(bytes(_companyAddress).length >1,"Enter the name of the company!");
        require(ControlCompanyInfoForCreatedCompany(_companyAddress,"") == false,"Company address is already created!");
        uint _counter=0;
        Employee [] memory _employees = new Employee[](employeeCount);
        for(uint i=0; i<companyCount;i++){
            if(keccak256(bytes(_companyAddress)) == keccak256(bytes(company[i].companyAddress))){
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
    function GetTheInvitesFromEmployee(string memory _employeeAddress)public view returns(Invite [] memory){
        require(bytes(_employeeAddress).length >1,"Enter the address of the employee!");
        require(ControlEmployeeInfoForInvite(_employeeAddress) == true,"Employee Address is not valid!");
        uint _counter=0;
        Invite [] memory _invites = new Invite[](inviteCount);
        for(uint256 i=0; i<inviteCount;i++){
            if(keccak256(bytes(invite[i].employeeAddress)) == keccak256(bytes(_employeeAddress)) && invite[i].rejected == false
            && invite[i].accepted == false){
                _invites[_counter] = invite[i];
                _counter++;
            }
        }
        return _invites;
    }
    function GetTimeStampFromEmployee(string memory _employeeAddress)public view returns(uint256){
        require(bytes(_employeeAddress).length >1,"Enter the address of the employee!");
        require(ControlEmployeeInfoForInvite(_employeeAddress) == true,"Employee Address is not valid!");
     
        uint256 _time=0;
        for(uint i=0; i<employeeCount;i++){
            if(keccak256(bytes(_employeeAddress)) == keccak256(bytes(employee[i].employeeAddress))){
                _time = employee[i].timeStamp;
                break;
            }
        }
        return _time;
    }
    function GetIdFromEmployee(string memory _employeeAddress)public view returns(uint256){
        require(bytes(_employeeAddress).length >1,"Enter the address of the employee!");
        require(ControlEmployeeInfoForInvite(_employeeAddress) == true,"Employee Address is not valid!");
        uint256 _id=0;
        for(uint i=0; i<employeeCount;i++){
            if(keccak256(bytes(_employeeAddress)) == keccak256(bytes(employee[i].employeeAddress))){
                _id = employee[i].id;
                break;
            }
        }
        return _id;
    }
    function GetCompanyAddressFromEmployee(string memory _employeeAddress)public view returns(string memory){
        require(bytes(_employeeAddress).length >1,"Enter the address of the employee!");
        require(ControlEmployeeInfoForInvite(_employeeAddress) == true,"Employee Address is not valid!");
        string memory _address;
        for(uint i=0; i<employeeCount;i++){
            if(keccak256(bytes(_employeeAddress)) == keccak256(bytes(employee[i].employeeAddress))){
                _address = employee[employeeCount].companyAddress;
                break;
            }
        }
        return _address;
    }
    
}
