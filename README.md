# Bitcoin Yield Aggregator Smart Contract

![Stacks Blockchain](https://img.shields.io/badge/Stacks-Blockchain-blue)
![Clarity](https://img.shields.io/badge/Language-Clarity-orange)

A secure and efficient smart contract for managing Bitcoin yield across multiple DeFi protocols on the Stacks blockchain.

## Overview

The Bitcoin Yield Aggregator is a sophisticated smart contract built on the Stacks blockchain using the Clarity language. It enables users to deposit Bitcoin into various yield-generating protocols, track yield accrual over time, and withdraw their principal along with earned interest.

This contract implements a comprehensive system for protocol management, deposit tracking, yield calculation, and risk mitigation through protocol diversification.

## Features

### Multi-Protocol Yield Aggregation

- Support for up to 5 different yield-generating protocols
- Each protocol has customizable APY rates and allocation limits
- Protocol diversification to mitigate risk exposure

### Secure Deposit Management

- User deposits tracked with timestamps (block height)
- Protocol-specific allocation limits to prevent overexposure
- Comprehensive input validation for all operations

### Time-Based Yield Calculation

- Yield calculated based on block height differences
- Protocol-specific APY rates applied to user deposits
- Simplified annual yield model with block-based time tracking

### Risk Management

- Protocol deactivation capability for risk mitigation
- Maximum allocation percentages for each protocol
- Owner-controlled protocol management

### Robust Security

- Comprehensive input validation for all operations
- Proper error handling with descriptive error codes
- Authorization checks for privileged operations

## Technical Architecture

### Storage Maps

#### Protocol Management

```clarity
(define-map supported-protocols
    {protocol-id: uint}
    {
        name: (string-ascii 50),
        base-apy: uint,
        max-allocation-percentage: uint,
        active: bool
    }
)

(define-data-var total-protocols uint u0)
```

#### User Deposits and Protocol Balances

```clarity
(define-map user-deposits
    {user: principal, protocol-id: uint}
    {
        amount: uint,
        deposit-time: uint
    }
)

(define-map protocol-total-deposits
    {protocol-id: uint}
    {total-deposit: uint}
)
```

### Constants and Configuration

```clarity
(define-constant CONTRACT-OWNER tx-sender)
(define-constant MAX-PROTOCOLS u5)
(define-constant MAX-ALLOCATION-PERCENTAGE u100)
(define-constant BASE-DENOMINATION u1000000)
(define-constant MAX-PROTOCOL-NAME-LENGTH u50)
(define-constant MAX-BASE-APY u10000)  ;; 100%
(define-constant MAX-DEPOSIT-AMOUNT u1000000000)  ;; Reasonable max deposit
```

### Error Codes

```clarity
(define-constant ERR-UNAUTHORIZED (err u1))
(define-constant ERR-INSUFFICIENT-FUNDS (err u2))
(define-constant ERR-INVALID-PROTOCOL (err u3))
(define-constant ERR-WITHDRAWAL-FAILED (err u4))
(define-constant ERR-DEPOSIT-FAILED (err u5))
(define-constant ERR-PROTOCOL-LIMIT-REACHED (err u6))
(define-constant ERR-INVALID-INPUT (err u7))
```

## Core Functions

### Protocol Management

#### Adding a Protocol

```clarity
(define-public (add-protocol
    (protocol-id uint)
    (name (string-ascii 50))
    (base-apy uint)
    (max-allocation-percentage uint)
)
```

- Adds a new yield-generating protocol to the contract
- Requires owner authorization
- Validates all input parameters
- Enforces protocol limits

#### Deactivating a Protocol

```clarity
(define-public (deactivate-protocol (protocol-id uint))
```

- Deactivates an existing protocol (risk management)
- Requires owner authorization
- Updates protocol status while preserving data

### User Operations

#### Depositing Funds

```clarity
(define-public (deposit
    (protocol-id uint)
    (amount uint)
)
```

- Allows users to deposit funds into a specific protocol
- Validates protocol existence and status
- Enforces protocol allocation limits
- Records deposit amount and timestamp

#### Calculating Yield

```clarity
(define-read-only (calculate-yield
    (protocol-id uint)
    (user principal)
)
```

- Calculates the current yield for a user's deposit
- Based on time elapsed (in blocks) since deposit
- Uses protocol-specific APY rates
- Read-only function for yield estimation

#### Withdrawing Funds

```clarity
(define-public (withdraw
    (protocol-id uint)
    (amount uint)
)
```

- Allows users to withdraw their deposits with accrued yield
- Validates user has sufficient funds
- Calculates and includes earned yield
- Updates user and protocol balances

## Initialization

The contract initializes with two default protocols:

1. "Stacks Core Protocol" with 5% APY and 20% max allocation
2. "Bitcoin Yield Plus" with 7.5% APY and 30% max allocation

```clarity
(define-public (initialize-protocols)
    (begin
        (try! (add-protocol u1 "Stacks Core Protocol" u500 u20))
        (try! (add-protocol u2 "Bitcoin Yield Plus" u750 u30))
        (ok true)
    )
)
```

## Security Considerations

### Input Validation

The contract implements comprehensive input validation for all operations:

- Protocol ID validation
- Protocol name validation
- APY rate validation
- Allocation percentage validation
- Deposit amount validation

### Authorization

- Owner-only functions for protocol management
- User-specific deposit tracking
- Proper authorization checks for all privileged operations

### Error Handling

- Descriptive error codes for all failure scenarios
- Proper unwrapping of optional values with fallback errors
- Consistent error reporting across all functions

## Implementation Details

### APY Calculation

- APY rates are stored as integers with a base denomination of 1,000,000
- For example, 5% APY is stored as 500,000
- Yield calculation uses block height differences for time tracking
- Assumes approximately 52,596 blocks per year

### Allocation Limits

- Each protocol has a maximum allocation percentage
- Prevents overexposure to any single protocol
- Enforced during deposit operations

## Usage Examples

### Adding a New Protocol (Owner Only)

```clarity
(add-protocol u3 "Bitcoin Lightning Yield" u600 u25)
```

This adds a new protocol with ID 3, named "Bitcoin Lightning Yield", with 6% APY and a 25% maximum allocation.

### Depositing Funds

```clarity
(deposit u1 u1000000)
```

This deposits 1 BTC (represented as 1,000,000 units) into protocol ID 1.

### Checking Yield

```clarity
(calculate-yield u1 tx-sender)
```

This calculates the current yield for the user's deposit in protocol ID 1.

### Withdrawing Funds

```clarity
(withdraw u1 u500000)
```

This withdraws 0.5 BTC (plus accrued yield) from protocol ID 1.

## Limitations and Future Improvements

### Current Limitations

- Simplified yield model based on block height
- No compound interest calculation
- Limited to 5 protocols maximum
- No partial withdrawals with yield recalculation

### Potential Enhancements

- Compound interest calculation
- Dynamic APY rates based on market conditions
- Protocol risk scoring and automatic rebalancing
- Integration with external price oracles
- Multi-asset support beyond Bitcoin

## Acknowledgments

- Stacks Foundation
- Clarity Language Documentation
- Bitcoin DeFi Community
