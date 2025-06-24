;; PropertyVault - Real Estate Tokenization Contract
;; A smart contract for fractional real estate ownership and trading

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_PROPERTY_NOT_FOUND (err u101))
(define-constant ERR_INSUFFICIENT_SHARES (err u102))
(define-constant ERR_PROPERTY_ALREADY_EXISTS (err u103))
(define-constant ERR_INVALID_AMOUNT (err u104))
(define-constant ERR_TRANSFER_FAILED (err u105))
(define-constant ERR_OVERFLOW (err u106))
(define-constant ERR_INVALID_PRINCIPAL (err u107))

;; Data Variables
(define-data-var property-counter uint u0)

;; Data Maps
(define-map properties
  { property-id: uint }
  {
    owner: principal,
    address: (string-ascii 256),
    total-shares: uint,
    share-price: uint,
    is-active: bool,
    created-at: uint
  }
)

(define-map property-shares
  { property-id: uint, holder: principal }
  { shares: uint }
)

(define-map user-properties
  { user: principal, property-id: uint }
  { shares: uint }
)

;; Read-only functions
(define-read-only (get-property (property-id uint))
  (map-get? properties { property-id: property-id })
)

(define-read-only (get-user-shares (property-id uint) (user principal))
  (default-to 
    { shares: u0 }
    (map-get? property-shares { property-id: property-id, holder: user })
  )
)

(define-read-only (get-property-counter)
  (var-get property-counter)
)

(define-read-only (calculate-share-value (property-id uint) (share-count uint))
  (match (get-property property-id)
    property-data 
      (let ((price (get share-price property-data)))
        (if (and (> share-count u0) (> price u0))
          (ok (* price share-count))
          (ok u0)))
    ERR_PROPERTY_NOT_FOUND
  )
)

;; Public functions
(define-public (create-property 
  (property-address (string-ascii 256))
  (total-shares uint)
  (share-price uint)
)
  (let 
    (
      (current-counter (var-get property-counter))
      (new-property-id (+ current-counter u1))
      (validated-address property-address)
    )
    (asserts! (> total-shares u0) ERR_INVALID_AMOUNT)
    (asserts! (> share-price u0) ERR_INVALID_AMOUNT)
    (asserts! (< current-counter u4294967295) ERR_OVERFLOW)
    (asserts! (> (len validated-address) u0) ERR_INVALID_AMOUNT)
    
    (map-set properties
      { property-id: new-property-id }
      {
        owner: tx-sender,
        address: validated-address,
        total-shares: total-shares,
        share-price: share-price,
        is-active: true,
        created-at: stacks-block-height
      }
    )
    
    ;; Give all initial shares to property creator
    (map-set property-shares
      { property-id: new-property-id, holder: tx-sender }
      { shares: total-shares }
    )
    
    (map-set user-properties
      { user: tx-sender, property-id: new-property-id }
      { shares: total-shares }
    )
    
    (var-set property-counter new-property-id)
    (ok new-property-id)
  )
)

(define-public (transfer-shares 
  (property-id uint)
  (recipient principal)
  (shares uint)
)
  (let
    (
      (sender-data (get-user-shares property-id tx-sender))
      (sender-shares (get shares sender-data))
      (recipient-data (get-user-shares property-id recipient))
      (recipient-shares (get shares recipient-data))
      (new-sender-shares (- sender-shares shares))
      (new-recipient-shares (+ recipient-shares shares))
    )
    (asserts! (not (is-eq tx-sender recipient)) ERR_INVALID_PRINCIPAL)
    (asserts! (>= sender-shares shares) ERR_INSUFFICIENT_SHARES)
    (asserts! (> shares u0) ERR_INVALID_AMOUNT)
    (asserts! (is-some (get-property property-id)) ERR_PROPERTY_NOT_FOUND)
    (asserts! (>= new-recipient-shares recipient-shares) ERR_OVERFLOW)
    
    ;; Update sender shares
    (map-set property-shares
      { property-id: property-id, holder: tx-sender }
      { shares: new-sender-shares }
    )
    
    ;; Update recipient shares
    (map-set property-shares
      { property-id: property-id, holder: recipient }
      { shares: new-recipient-shares }
    )
    
    ;; Update user-properties maps
    (map-set user-properties
      { user: tx-sender, property-id: property-id }
      { shares: new-sender-shares }
    )
    
    (map-set user-properties
      { user: recipient, property-id: property-id }
      { shares: new-recipient-shares }
    )
    
    (ok true)
  )
)

(define-public (update-share-price 
  (property-id uint)
  (new-price uint)
)
  (let
    (
      (property-data (unwrap! (get-property property-id) ERR_PROPERTY_NOT_FOUND))
    )
    (asserts! (is-eq tx-sender (get owner property-data)) ERR_UNAUTHORIZED)
    (asserts! (> new-price u0) ERR_INVALID_AMOUNT)
    
    (map-set properties
      { property-id: property-id }
      (merge property-data { share-price: new-price })
    )
    
    (ok true)
  )
)

(define-public (deactivate-property (property-id uint))
  (let
    (
      (property-data (unwrap! (get-property property-id) ERR_PROPERTY_NOT_FOUND))
    )
    (asserts! (is-eq tx-sender (get owner property-data)) ERR_UNAUTHORIZED)
    
    (map-set properties
      { property-id: property-id }
      (merge property-data { is-active: false })
    )
    
    (ok true)
  )
)