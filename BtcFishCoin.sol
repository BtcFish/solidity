pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BtcFishCoin is ERC20 {

  string public constant NAME = "BtcFish Coin";
  string public constant SYMBOL = "BFC";

  bytes32 private domainSeparator;
  bytes32 private constant PERMIT_TYPEHASH = keccak256("Permit(address holder,address spender,uint256 value,uint256 nonce,uint256 deadline)");
  mapping(address => uint) private nonces;

  constructor(uint256 initialSupply) public ERC20(NAME, SYMBOL) {
        _mint(msg.sender, initialSupply);

        uint chainid = block.chainid;
        domainSeparator = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(NAME)),
                keccak256(bytes("1")),
                chainid,
                address(this)
            )
        );
  }

  function decimals() public view virtual override returns (uint8) {
      return 9;
  }

  function burn(uint256 amount) external {
      _burn(msg.sender, amount);
  }

  function getNonce() external view returns (uint) {
      return nonces[msg.sender];
  }

  function _permit(address holder, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) internal {
        require(deadline >= block.timestamp, "BtcFish: EXPIRED");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                keccak256(abi.encode(PERMIT_TYPEHASH, holder, spender, value, nonces[holder], deadline))
            )
        );
        nonces[holder] += 1;
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == holder, "BtcFish: INVALID_SIGNATURE");
    }

    function permitAndApprove(address holder, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        _permit(holder, spender, value, deadline, v, r, s);
        _approve(holder, spender, value);
    }

    function permitAndTransfer(address holder, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        _permit(holder, spender, value, deadline, v, r, s);
        _transfer(holder, spender, value);
    }
}
