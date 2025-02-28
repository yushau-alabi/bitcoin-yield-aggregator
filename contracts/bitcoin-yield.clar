;; Bitcoin Yield Aggregator

;; A secure and efficient smart contract for managing Bitcoin yield
;; across multiple DeFi protocols on the Stacks blockchain.
;;
;; This contract enables users to:
;;  - Deposit Bitcoin into various yield-generating protocols
;;  - Track and calculate yield accrual over time
;;  - Withdraw principal and earnings with proper validation
;;  - Benefit from risk management through protocol diversification


;; Error Codes
(define-constant ERR-UNAUTHORIZED (err u1))
(define-constant ERR-INSUFFICIENT-FUNDS (err u2))
(define-constant ERR-INVALID-PROTOCOL (err u3))
(define-constant ERR-WITHDRAWAL-FAILED (err u4))
(define-constant ERR-DEPOSIT-FAILED (err u5))
(define-constant ERR-PROTOCOL-LIMIT-REACHED (err u6))
(define-constant ERR-INVALID-INPUT (err u7))

;; Storage: Protocol Management
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

;; Storage: User Deposits and Protocol Balances
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

;; Constants and Configuration
(define-constant CONTRACT-OWNER tx-sender)
(define-constant MAX-PROTOCOLS u5)
(define-constant MAX-ALLOCATION-PERCENTAGE u100)
(define-constant BASE-DENOMINATION u1000000)
(define-constant MAX-PROTOCOL-NAME-LENGTH u50)
(define-constant MAX-BASE-APY u10000)  ;; 100%
(define-constant MAX-DEPOSIT-AMOUNT u1000000000)  ;; Reasonable max deposit

;; Input Validation Functions
(define-private (is-valid-protocol-id (protocol-id uint))
    (and (> protocol-id u0) (<= protocol-id MAX-PROTOCOLS))
)

(define-private (is-valid-protocol-name (name (string-ascii 50)))
    (and 
        (> (len name) u0) 
        (<= (len name) MAX-PROTOCOL-NAME-LENGTH)
    )
)

(define-private (is-valid-base-apy (base-apy uint))
    (<= base-apy MAX-BASE-APY)
)

(define-private (is-valid-allocation-percentage (percentage uint))
    (and (> percentage u0) (<= percentage MAX-ALLOCATION-PERCENTAGE))
)

(define-private (is-valid-deposit-amount (amount uint))
    (and (> amount u0) (<= amount MAX-DEPOSIT-AMOUNT))
)

;; Authorization Check
(define-private (is-contract-owner (sender principal))
    (is-eq sender CONTRACT-OWNER)
)