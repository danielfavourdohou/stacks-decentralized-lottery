# Decentralized Lottery Protocol

A permissionless, on‑chain lottery protocol built for the Stacks blockchain using Clarity smart contracts. Players purchase numbered NFT tickets with STX, and every configurable interval a pseudo‑random draw selects winners and automatically distributes 90% of the accumulated pool to them, while 10% is reserved as protocol fees. Fully modularized across 7+ contracts, this project includes comprehensive clarinet tests, an error‑free `clarinet check`, and a detailed README guiding deployment, configuration, and usage.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Key Features](#key-features)
3. [Prerequisites](#prerequisites)
4. [Installation & Setup](#installation--setup)
5. [Configuration](#configuration)
6. [Usage](#usage)

   * [Buying Tickets](#buying-tickets)
   * [Triggering a Draw](#triggering-a-draw)
   * [Querying Contract Views](#querying-contract-views)
7. [File Structure](#file-structure)
8. [Testing](#testing)
9. [Pull Request Guide](#pull-request-guide)
10. [Future Improvements](#future-improvements)
11. [License](#license)

---

## Project Overview

The Decentralized Lottery Protocol empowers users to participate in a transparent lottery system directly on Stacks. Leveraging Clarity smart contracts and NFT standards, the system mints a unique ticket NFT for each STX purchase and stores state on-chain. At every pre-defined block interval, the protocol performs a pseudo-random draw based on block hashes and ticket data to select winners fairly and autonomously. Winnings are disbursed instantly, and fees accumulate in a treasury contract for admin withdrawal.

This repository provides:

* Modular Clarity smart contracts (7+ files)
* Clear admin controls (pricing, intervals, pausing)
* Pseudo-random draw logic
* NFT ticket minting per SIP-009
* Comprehensive clarinet tests and CI-ready setup
* A detailed, end-to-end README for developers and users

---

## Key Features

* **Permissionless Ticket Sales:** Users mint ticket NFTs by sending a fixed STX price.
* **Automated Draws:** Anyone can trigger a draw at the configured block height; the protocol uses on-chain data for randomness.
* **Fair Payouts:** 90% of the pool goes to winners; 10% fees are reserved in the treasury.
* **Modular Design:** Seven dedicated contracts handle core logic, randomness, NFT tickets, admin controls, fee management, views, and shared utilities.
* **Pause & Emergency Controls:** Admins can pause sales or draws instantly if needed.
* **Comprehensive Testing:** clarinet tests cover all main flows and edge cases, ensuring `clarinet check` passes with zero errors.

---

## Prerequisites

* **Node.js & npm** (for clarinet)
* **clarinet** CLI installed globally
* **Stacks CLI** (if interacting with a local Stacks node)
* A running **local Stacks node** for testing (optional but recommended)

---

## Installation & Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/<your-org>/stacks-decentralized-lottery.git
   cd stacks-decentralized-lottery
   ```

2. **Install clarinet** (if not already installed)

   ```bash
   npm install -g @hirosystems/clarinet
   ```

3. **Run `clarinet check`** to compile all contracts and ensure no errors

   ```bash
   clarinet check
   ```

4. **Configure local environment** variables (if needed) by duplicating `.env.example` to `.env` and updating values.

---

## Configuration

Edit the following parameters in `admin-and-pausing.clar` or via the deployment script before deployment:

* `TICKET-PRICE-STX`: Price per ticket in micro-STX.
* `DRAW-INTERVAL-BLOCKS`: Number of blocks between draws.
* `PROTOCOL-FEE-BPS`: Basis points (out of 10,000) reserved as fees.

You can also update contract addresses in `deploy.sh` (if provided) to point to your specific deployment environment.

---

## Usage

### Buying Tickets

Users can call the `buy-ticket` function in `lottery-core.clar`:

```bash
clarinet run buy-ticket --sender principal1 --amount 5_000_000  # purchases 5 STX worth of tickets
```

This mints one ticket NFT per `TICKET-PRICE-STX`.

### Triggering a Draw

Once the blockchain reaches `CURRENT-BLOCK + DRAW-INTERVAL-BLOCKS`, call:

```bash
clarinet run draw-lottery --sender principal1
```

This selects a random winner and distributes the jackpot.

### Querying Contract Views

Read-only queries provide insight into the protocol state:

```bash
clarinet query get-total-tickets --contract views --sender principal1
clarinet query get-next-draw-block --contract views --sender principal1
clarinet query get-recent-winners --contract views --sender principal1
```

---

## File Structure

```
├── contracts/
│   ├── lottery-core.clar        # Ticket sales & draw logic
│   ├── ticket-nft.clar          # SIP-009 NFT implementation
│   ├── randomness.clar          # Pseudo-random number utils
│   ├── admin-and-pausing.clar   # Admin settings & pause controls
│   ├── fee-collector.clar       # Fee accumulation & withdrawal
│   ├── views.clar               # Read-only getters
│   ├── errors.clar              # Error codes & messages
│   └── utils.clar               # Shared macros & types
│
├── tests/
│   ├── purchase-tests.ts       # Ticket purchase & NFT minting
│   ├── draw-tests.ts           # Draw and payout validation
│   ├── admin-tests.ts          # Admin flows & pause/unpause
│   └── edge-case-tests.ts      # No tickets, invalid draws
│
├── README.md
├── PULL_REQUEST.md
├── deploy.sh                   # Deployment script example
└── clarinet.toml
```

---

## Testing

Run all tests with:

```bash
clarinet test
```

You should see 100% pass rate and no warnings. Ensure tests cover:

* Successful ticket minting on STX receipt
* Correct NFT token ID management
* Random draw consistency and fairness
* Proper STX distribution to winners and fee contract
* Admin-only access control
* Pause state behavior

---

## Pull Request Guide

Use `PULL_REQUEST.md` as a template for your PR. Ensure your PR includes:

1. **Title:** Add Decentralized Lottery Protocol
2. **Summary:** High-level overview of the feature
3. **Changes:** List of new files and key functions
4. **Tests:** Description of test coverage and results
5. **Checklist:**

   * `clarinet check` passes
   * All tests green
   * README updated
6. **Next Steps:** Suggestions for future enhancements

---

## Future Improvements

* **Verifiable Randomness:** Integrate a secure VRF Oracle for on-chain randomness.
* **Multi-Winner Draws:** Support selecting multiple winners per draw.
* **Cross-Chain Lottery:** Enable ticket purchases via wrapped assets from other chains.
* **UI Dashboard:** Build a frontend for easier user interaction.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
