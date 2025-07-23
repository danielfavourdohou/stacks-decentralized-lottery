;; Fee collection and withdrawal functionality

;; Data storage
(define-data-var collected-fees uint u0)

;; Withdraw collected fees (admin only)
(define-public (withdraw-fees (recipient principal))
  (begin
    (try! (contract-call? .admin-and-pausing ensure-admin))
    (let ((amount (var-get collected-fees)))
      (asserts! (> amount u0) (err u1006))
      (var-set collected-fees u0)
      (match (stx-transfer? amount (as-contract tx-sender) recipient)
        success (ok amount)
        error (err u1009)
      )
    )
  )
)

;; Collect fees from lottery operations
(define-public (collect-fee (amount uint))
  (begin
    (asserts! (> amount u0) (err u1003))
    (var-set collected-fees (+ (var-get collected-fees) amount))
    (ok amount)
  )
)

;; Get current collected fees amount
(define-read-only (get-collected-fees)
  (ok (var-get collected-fees))
)