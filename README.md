# PropertyVault 🏠

A decentralized real estate tokenization platform built on Stacks blockchain that enables fractional property ownership and seamless share trading.

## Overview

PropertyVault revolutionizes real estate investment by allowing property owners to tokenize their assets into tradeable shares, making real estate investment accessible to everyone regardless of capital constraints.

## Features

- **Property Tokenization**: Convert real estate into digital shares
- **Fractional Ownership**: Own portions of properties with any budget
- **Secure Trading**: Transfer shares between users with blockchain security
- **Price Management**: Property owners can update share valuations
- **Ownership Tracking**: Transparent record of all property stakes

## Smart Contract Functions

### Read-Only Functions
- `get-property(property-id)` - Retrieve property details
- `get-user-shares(property-id, user)` - Get user's shares in a property
- `get-property-counter()` - Get total number of properties
- `calculate-share-value(property-id, shares)` - Calculate monetary value of shares

### Public Functions
- `create-property(address, total-shares, share-price)` - Tokenize a new property
- `transfer-shares(property-id, recipient, shares)` - Transfer shares to another user
- `update-share-price(property-id, new-price)` - Update property share price
- `deactivate-property(property-id)` - Deactivate a property listing

## Getting Started

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet for testing

### Installation
```bash
git clone <repository-url>
cd property-vault
clarinet check
```

### Testing
```bash
clarinet test
```

## Usage Example

```clarity
;; Create a property with 1000 shares at 100 STX each
(contract-call? .property-vault create-property "123 Main St, New York" u1000 u100)

;; Transfer 50 shares to another user
(contract-call? .property-vault transfer-shares u1 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 u50)
```

## Contract Architecture

The contract uses three main data structures:
- `properties`: Core property information and metadata
- `property-shares`: Individual user share holdings
- `user-properties`: User-centric share tracking

## Security Features

- Ownership validation for sensitive operations
- Share balance verification before transfers
- Input validation for all parameters
- Secure principal-based access control

## License

MIT License - see LICENSE file for details

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `clarinet check` to validate
5. Submit a pull request

## Roadmap

- [ ] Integration with STX payments for share purchases
- [ ] Property rental yield distribution
- [ ] Multi-signature property management
- [ ] Property valuation oracles
- [ ] Mobile app interface

---

Built with ❤️ on Stacks blockchain