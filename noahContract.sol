pragma solidity ^0.4.13;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;

  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {
  mapping (address => mapping (address => uint256)) allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}

/**
 *
 */
contract NoahToken is StandardToken, Ownable {
  string public constant name = "Tesla tokens";
  string public constant symbol = "TSLA";
  uint32 public constant decimals = 18;

  event Mint(address indexed to, uint256 amount);
  event Burn(address indexed burner, uint indexed value);
  event MintFinished();

  bool public mintingFinished = false;
 
  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier canBurn() {
    //require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) canMint {
    require(_amount > 0);
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
  }

  function burn(uint256 _amount) canBurn {
    require(_amount > 0);
    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_amount);
    totalSupply = totalSupply.sub(_amount);
    Burn(burner, _amount);
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner {
    mintingFinished = true;
    MintFinished();
  }
}

/**
 *
 */
contract NoahContract is NoahToken {
    address public issuerAddress; /* Адрес кошелька эмитента */

    uint256 public ethPrice; /* Цена в USD ETH */
    uint256 public assetPrice; /* Цена в USD базового актива */
    uint256 public numberOfAsset; /* Количетсво единиц актива */

    event ContractDone();

    bool contractDone = false; /* Контракт исполнен */

    modifier contractIsNotDone() {
        require(!contractDone);
        _;
    }

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function NoahContract(address _issuerAddress, uint256 _numberOfAsset, uint256 _assetPrice, uint256 _ethPrice) {
        issuerAddress = _issuerAddress;

        ethPrice = _ethPrice;
        assetPrice = _assetPrice;
        numberOfAsset = _numberOfAsset;
    }

    function () payable {
        //uint256 _ethSurrender = 0;
        uint256 _ethAmount = msg.value;
        //uint256 _availableTokens = numberOfAsset - totalSupply;
        uint256 _numberOfCreateTokens = (_ethAmount * ethPrice) / assetPrice;

        //require(_numberOfCreateTokens <= 0 && _availableTokens > 0);

        // if (_numberOfCreateTokens >= _availableTokens) {
        //   _ethSurrender = (_numberOfCreateTokens - _availableTokens) / ethPrice;
        //   _ethAmount = _ethAmount - _ethSurrender;
        //   _numberOfCreateTokens = _availableTokens;
        // }

        issuerAddress.transfer(_ethAmount);

        // if (_ethSurrender > 0) {
        //   msg.sender.transfer(_ethSurrender);
        // }

        mint(msg.sender, _numberOfCreateTokens);

        // if (_availableTokens == 0) {
        ///   finishMinting();
        // }
    }
 
    function burnTokens() public {
      require(!mintingFinished || balanceOf(msg.sender) != numberOfAsset);

      // Проверить на успешность
      burn(balanceOf(msg.sender));

      contractDone = true;

      ContractDone();
    }
}
