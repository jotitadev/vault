#!/bin/bash

UNSEAL_KEY="Q0dqdU6ApQvAg+srRmrZliF3pinmm6whxlftO1Truro="
NONCE="7b78a78d-ee0d-b5a3-9982-f45470362c9d"
OTP="wYNGxXuqC8MIsSdR28Ut0ZqnCMP0"

echo "$UNSEAL_KEY" | kubectl exec -n vault -i vault-0 -- vault operator generate-root -nonce="$NONCE" -otp="$OTP" -