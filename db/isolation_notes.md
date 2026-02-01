# Isolation level e concorrenza

## Scelte principali

- `sp_request_ride`: `READ COMMITTED` + lock su riga cliente (`SELECT ... FOR UPDATE`).
  Motivo: impedire richieste attive concorrenti dello stesso cliente senza bloccare letture non correlate.

- `sp_accept_ride`: `READ COMMITTED` + lock su riga tassista e richiesta (`SELECT ... FOR UPDATE`).
  Motivo: prevenire due accettazioni concorrenti e garantire che un tassista abbia una sola corsa attiva.

- `sp_start_ride` / `sp_complete_ride` / cancellazioni: `READ COMMITTED` + lock sulla richiesta.
  Motivo: garantire transizione di stato atomica con rilevamento conflitti su righe specifiche.

- report manager: lettura coerente a livello `READ COMMITTED` (default), nessun lock sulle righe operative.

## Note
Le transazioni usano handler con rollback e `SIGNAL SQLSTATE` per errori applicativi.