    import '../aave/contracts/FlashLoanReceiverBase.sol';
import '../aave/contracts/LendingPool.sol';
import '../aave/contracts/LendingPoolAddressesProvider.sol';

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Borrower is FlashLoanReceiverBase, Ownable {
    using SafeMath for uint256;

    LendingPoolAddressesProvider public provider;
    dai public _dai;

    event StartLoan(address indexed borrower, uint256 amount, address asset);
    event FinishLoan();

    constructor(address _provider, address _dai) FlashLoanReceiverBase(_provider) {
        provider = _provider;
        dai = _dai;
    }

    function startLoan(uint256 amount, bytes memory _params) public onlyOwner() {
        LendingPool lendingPool = LendingPool(provider.getLendingPool());

        // start a DAI loan to this contract, for amount
        lendingPool.flashLoan(address(this), dai, amount, _params);
        emit StartLoan(address(this), amount, dai);
    }

    function executeOperation(
        address _reserve,
        uint256 _amount,
        uint256 _fee,
        bytes memory _params
    ) public onlyOwner() {
        //check the contract has the specified balance
        require(_amount <= getBalanceInternal(address(this), _reserve), 
            "Invalid balance for the contract");

        transferFundsBackToPoolInternal(_reserve, _amount.add(_fee));
    }
}