// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library VaultMath {
    uint256 public constant SECURE_PRIME = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;

    error ModuloArithmeticOverflow();

    function safeAdd(uint256 x, uint256 y) internal pure returns (uint256) {
        unchecked {
            uint256 z = x + y;
            if (z < x) revert ModuloArithmeticOverflow();
            return z;
        }
    }

    function fieldMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
        return mulmod(a, b, SECURE_PRIME);
    }

    function evaluatePolynomial(uint256[] memory coefficients, uint256 x) internal pure returns (uint256) {
        uint256 result = 0;
        for (uint256 i = coefficients.length; i > 0; i--) {
            result = safeAdd(fieldMultiply(result, x), coefficients[i - 1]);
        }
        return result % SECURE_PRIME;
    }
}
