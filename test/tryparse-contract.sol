/**
 *Submitted for verification at BscScan.com on 2021-04-11
*/

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [// importANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * // importANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}



contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;


    constructor (string memory name, string memory symbol) {
        _name = name;
        _symbol = symbol;
    }

    function name() public view returns (string memory) {
        return _name;
    }


    function symbol() public view returns (string memory) {
        return _symbol;
    }


    function decimals() public pure returns (uint8) {
        return 18;
    }


    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }


    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }


    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }


    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }


    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }


    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}




// pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


// pragma solidity >=0.5.0;

interface IUniswapV2ERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
}




// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}



// pragma solidity >=0.6.2;



interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


interface Lottery {
    //A lottery contract keeps track of who is eligible, so
    //this must be called on each lottery contract when a user's balance
    //is updated
    function addressBalancesUpdated(
        address user1,
        uint256 balance1,
        address user2,
        uint256 balance2) external;
}

pragma solidity 0.7.3;

// SPDX-License-Identifier: Unlicensed

contract XXXToken is ERC20, Ownable {

    using SafeMath for uint256;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public _burnPool = 0x0000000000000000000000000000000000000000;

    uint256 private minTokensBeforeSwap;

    uint256 internal _totalSupply;

    bool inSwapAndLiquify;
    uint256 swapAndLiquifyBlockNumber;
    bool swapAndLiquifyEnabled;
    bool feesEnabled;

    address private teamAllocationWalletA = 0x0000000000000000000000000000000000000000;
    address private teamAllocationWalletB = 0x0000000000000000000000000000000000000000;
    address private teamAllocationWalletC = 0x0000000000000000000000000000000000000000;
    address private teamAllocationWalletD = 0x0000000000000000000000000000000000000000;
    address private teamMasterWallet = 0x0000000000000000000000000000000000000000;

    address private teamOperationsWallet = 0x0000000000000000000000000000000000000000;

    address private teamFeesWalletA = 0x0000000000000000000000000000000000000000;
    address private teamFeesWalletB = 0x0000000000000000000000000000000000000000;
    address private teamFeesWalletC = 0x0000000000000000000000000000000000000000;
    address private teamFeesWalletD = 0x0000000000000000000000000000000000000000;
    address private teamOperationsFeesWallet = 0x0000000000000000000000000000000000000000;

    address private presaleDeployerWallet = 0x0000000000000000000000000000000000000000;


    //Lock wallets A to D for 21 days from transferring
    mapping(address => bool) public lockedWallets;

    //Set to 21 days after deploy
    uint256 public lockedWalletsUnlockTime;

    Lottery public lotteryContractA;
    Lottery public lotteryContractB;

    //If this is set to true, the lotteryContractA cannot be changed anymore.
    bool public lotteryContractALocked;
    //If this is set to true, the lotteryContractB cannot be changed anymore.
    bool public lotteryContractBLocked;


    uint256 private teamFeesA = 75; //Fees are in 100ths of a percent. 0.75%
    uint256 private teamFeesB = 75;
    uint256 private teamFeesC = 75; 
    uint256 private teamFeesD = 25; 
    uint256 private teamOperationsFees = 50;

    uint256 private lotteryContractAFee = 250;
    uint256 private lotteryContractBFee = 250;
    uint256 private liquidityFee = 100;
    uint256 private burnRate = 100;

    event LotteryContractAUpdated(address addr);
    event LotteryContractBUpdated(address addr);
    event LotteryContractALocked(address addr);
    event LotteryContractBLocked(address addr);

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event FeesEnabledUpdated(bool enabled);

    event SwapTokensFailed(
        uint256 tokensSwapped
    );

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(
        IUniswapV2Router02 _uniswapV2Router,
        uint256 _minTokensBeforeSwap,
        bool _feesEnabled
    ) ERC20("XXX", "$XXX") {

        //Initial token count is 77,777,777
        uint256 teamAllocationWalletATokens = 1555555.54 ether;
        uint256 teamAllocationWalletBTokens = 1555555.54 ether;
        uint256 teamAllocationWalletCTokens = 1555555.54 ether;
        uint256 teamAllocationWalletDTokens = 388888.885 ether;
        uint256 teamMasterWalletTokens = 45111110.66 ether;

        uint256 teamOperationsTokens = 2722222.195 ether;

        uint256 presaleDeployerTokens = 24888888.64 ether;

        _mint(teamAllocationWalletA, teamAllocationWalletATokens);
        _mint(teamAllocationWalletB, teamAllocationWalletBTokens);
        _mint(teamAllocationWalletC, teamAllocationWalletCTokens);
        _mint(teamAllocationWalletD, teamAllocationWalletDTokens);
        _mint(teamMasterWallet, teamMasterWalletTokens);

        _mint(teamOperationsWallet, teamOperationsTokens);

        _mint(presaleDeployerWallet, presaleDeployerTokens);

        //Lock team allocation wallets for 21 days
        lockedWalletsUnlockTime = block.timestamp.add(1814400);

        lockedWallets[teamAllocationWalletA] = true;
        lockedWallets[teamAllocationWalletB] = true;
        lockedWallets[teamAllocationWalletC] = true;
        lockedWallets[teamAllocationWalletD] = true;


        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;

        updateMinTokensBeforeSwap(_minTokensBeforeSwap);

        if(_feesEnabled) {
            setFeesEnabled();
        }
    }


    //Stores the fees for a transfer, including the total fees
    struct Fees
    {
        uint256 teamFeesATokens;
        uint256 teamFeesBTokens;
        uint256 teamFeesCTokens;
        uint256 teamFeesDTokens;
        uint256 teamOperationsFeesTokens;
        uint256 lotteryContractATokens;
        uint256 lotteryContractBTokens;
        uint256 liquidityTokens;
        uint256 burnTokens;
        uint256 totalFees;
    }

    function setLotteryContractA(
        address addr,
        bool locked
    ) external onlyOwner {
        //Cannot update if already locked
        require(!lotteryContractALocked);
        lotteryContractA = Lottery(addr);
        lotteryContractALocked = locked;

        emit LotteryContractAUpdated(addr);

        if(locked) {
            emit LotteryContractALocked(addr);
        }
    }

    function lockLotteryContractA()
        external onlyOwner {
        //Cannot lock if already locked
        require(!lotteryContractALocked);
        //Cannot lock if no lottery set
        require(address(lotteryContractA) != address(0x0));

        lotteryContractALocked = true;

        emit LotteryContractALocked(address(lotteryContractA));
    }


    function setLotteryContractB(
        address addr,
        bool locked
    ) external onlyOwner {
        //Cannot update if already locked
        require(!lotteryContractBLocked);
        require(address(lotteryContractB) == address(0x0));
        lotteryContractB = Lottery(addr);
        lotteryContractBLocked = locked;

        emit LotteryContractBUpdated(addr);

        if(locked) {
            emit LotteryContractBLocked(addr);
        }
    }


    function lockLotteryContractB()
        external onlyOwner {
        //Cannot lock if already locked
        require(!lotteryContractBLocked);
        //Cannot lock if no lottery set
        require(address(lotteryContractB) != address(0x0));

        lotteryContractBLocked = true;

        emit LotteryContractBLocked(address(lotteryContractB));
    }

    //Generates a Fee struct for a given amount that is transferred
    //If a lottery contract is not set, there will be no fees for that (ie, those tokens are not burned)
    function getFees(
        uint256 amount
    ) private view returns (Fees memory) {
        Fees memory fees;

        uint totalFees = 0;

        //Calculate tokens to payout to address and contracts
        fees.teamFeesATokens = amount.mul(teamFeesA).div(10000);
        totalFees = totalFees.add(fees.teamFeesATokens);

        fees.teamFeesBTokens = amount.mul(teamFeesB).div(10000);
        totalFees = totalFees.add(fees.teamFeesBTokens);

        fees.teamFeesCTokens = amount.mul(teamFeesC).div(10000);
        totalFees = totalFees.add(fees.teamFeesCTokens);

        fees.teamFeesDTokens = amount.mul(teamFeesD).div(10000);
        totalFees = totalFees.add(fees.teamFeesDTokens);

        fees.teamOperationsFeesTokens = amount.mul(teamOperationsFees).div(10000);
        totalFees = totalFees.add(fees.teamOperationsFeesTokens);

        if(address(lotteryContractA) != address(0x0)) {
            fees.lotteryContractATokens = amount.mul(lotteryContractAFee).div(10000);
            totalFees = totalFees.add(fees.lotteryContractATokens);
        }

        if(address(lotteryContractB) != address(0x0)) {
            fees.lotteryContractBTokens = amount.mul(lotteryContractBFee).div(10000);
            totalFees = totalFees.add(fees.lotteryContractBTokens);
        }

        fees.liquidityTokens = amount.mul(liquidityFee).div(10000);
        totalFees = totalFees.add(fees.liquidityTokens);

        fees.burnTokens = amount.mul(burnRate).div(10000);
        totalFees = totalFees.add(fees.burnTokens);

        fees.totalFees = totalFees;

        return fees;
    }

    //Pays out the fees from the address specified by from
    function _payoutFees(
        address from,
        Fees memory fees
    ) private {
            super._transfer(from, teamFeesWalletA, fees.teamFeesATokens);
            super._transfer(from, teamFeesWalletB, fees.teamFeesBTokens);
            super._transfer(from, teamFeesWalletC, fees.teamFeesCTokens);
            super._transfer(from, teamFeesWalletD, fees.teamFeesDTokens);
            super._transfer(from, teamOperationsFeesWallet, fees.teamOperationsFeesTokens);

            //Will be 0 if contract not set
            if(fees.lotteryContractATokens > 0) {
                super._transfer(from, address(lotteryContractA), fees.lotteryContractATokens);
            }

            //Will be 0 if contract not set
            if(fees.lotteryContractBTokens > 0) {
                super._transfer(from, address(lotteryContractB), fees.lotteryContractBTokens);
            }

            //1% burn rate
            _burn(from, fees.burnTokens);

            //The liquidity fee is sent to the contract. Future calls to transfer will add liquidity once it is >= minTokensBeforeSwap
            super._transfer(from, address(this), fees.liquidityTokens);
    }

    //Overrides the superclass implementation to handle custom logic
    //such as taking fees, burning tokens, and supplying liquidity to PancakeSwap
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        //If wallet is locked then...
        if(lockedWallets[from]) {
            //check that enough time has passed to allow transfers
            require(block.timestamp >= lockedWalletsUnlockTime);
        }

        //The team master wallet's tokens are locked forever
        require(from != teamMasterWallet);

        //Owner is not taxed
        if (from == owner() || to == owner()) {
            super._transfer(from, to, amount);
        } else {
            uint256 contractTokenBalance = balanceOf(address(this));

            bool overMinTokenBalance = contractTokenBalance >= (minTokensBeforeSwap.mul(10 ** decimals()));

            //Only swap and liquify if >= min balance set to do so,
            //and have not already swapped this blcok,
            //and the sender isn't a uniswap pair or lottery contract,
            //and fees are enabled
            if (
                overMinTokenBalance &&
                !inSwapAndLiquify &&
                block.number > swapAndLiquifyBlockNumber &&
                msg.sender != uniswapV2Pair &&
                msg.sender != address(lotteryContractA) &&
                msg.sender != address(lotteryContractB) &&
                feesEnabled
            ) {
                swapAndLiquify(contractTokenBalance);
            }

            //Fees must be enabled, and don't take fees when the contract is swapping tokens to add liquidity
            if(feesEnabled && !inSwapAndLiquify) {
                Fees memory fees = getFees(amount);
                amount = amount.sub(fees.totalFees);
                _payoutFees(from, fees);
            }

            //Perform the regular transfer to "to" parameter, finally
            super._transfer(from, to, amount);

            uint256 toBalance = balanceOf(to);
            uint256 fromBalance = balanceOf(from);

            //Call functions in the lottery contracts to tell them balances updated,
            //so they can keep track of eligible users
            _updateLotteryAddressBalances(lotteryContractA, to, toBalance, from, fromBalance);
            _updateLotteryAddressBalances(lotteryContractB, to, toBalance, from, fromBalance);
        }
    }

    //Calls addressBalancesUpdated for the given lottery, if it has been set
    //It makes sure that it doesn't pass in the PancakeSwap router address, pair
    //or lottery itself
    //because they are not eligible to win the lottery
    function _updateLotteryAddressBalances(
        Lottery lottery,
        address user1,
        uint256 balance1,
        address user2,
        uint256 balance2) private {
        if(address(lottery) == address(0x0)) {
            return;
        }

        //Don't allow router, pair, or the lottery itself to participate in the lottery
        if(user1 == address(uniswapV2Router) || user1 == address(uniswapV2Pair) || user1 == address(lottery)) {
            user1 = address(0x0);
        }

        if(user2 == address(uniswapV2Router) || user2 == address(uniswapV2Pair) || user2 == address(lottery)) {
            user2 = address(0x0);
        }

        lottery.addressBalancesUpdated(
            user1, balance1,
            user2, balance2);

    }

    function swapAndLiquify(uint256 contractTokenBalance)
        private lockTheSwap {

        swapAndLiquifyBlockNumber = block.number;

        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        if(swapTokensForEth(half)) {
            // how much ETH did we just swap into?
            uint256 newBalance = address(this).balance.sub(initialBalance);

            // add liquidity to uniswap
            addLiquidity(otherHalf, newBalance);

            emit SwapAndLiquify(half, newBalance, otherHalf);
        }
        else {
            emit SwapTokensFailed(half);
        }
    }

    function swapTokensForEth(uint256 tokenAmount)
        private returns (bool) {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        
        _approve(address(this), address(uniswapV2Router), tokenAmount);
    

        //If for whatever reason the swap cannot be made, return false without
        //failing the whole transaction
        try uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        ) {
            return true;
        } catch( bytes memory) {
            return false;
        }
        
        
        
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount)
        private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }


    receive() external payable {}


    function updateMinTokensBeforeSwap(uint256 _minTokensBeforeSwap)
        public onlyOwner {
        minTokensBeforeSwap = _minTokensBeforeSwap;
        emit MinTokensBeforeSwapUpdated(_minTokensBeforeSwap);
    }

    //Fees can only be turned on. Once they are on, they cannot be turned off
    function setFeesEnabled()
        public onlyOwner {
        require(!feesEnabled);
        feesEnabled = true;
        emit FeesEnabledUpdated(true);
    }


}