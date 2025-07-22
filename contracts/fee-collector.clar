(define-data-var collected-fees uint u0)

(define-public (withdraw-fees (recipient principal))
  (begin
    (try! (contract-call? .admin-and-pausing.ensure-admin))
    (let ((amount (var-get collected-fees)))
      (asserts! (> amount u0) ERR_FEE_WITHDRAWAL)
      (var-set collected-fees u0)
      (stx-transfer? amount (as-contract tx-sender) recipient)
      (ok amount)
    )
  )
)

(define-public (collect-fee (amount uint))
  (begin
    (var-set collected-fees (+ (var-get collected-fees) amount))
    (ok amount)
  )
)