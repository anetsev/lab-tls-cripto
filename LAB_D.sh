#!/usr/bin/env bash
# LAB D (slide 39) · sites com problema de propósito (badssl.com, mantido para testes)
# Para cada site: o que o OpenSSL diz e o que o certificado mostra.
for h in expired.badssl.com wrong.host.badssl.com self-signed.badssl.com untrusted-root.badssl.com; do
  printf '\n==================== https://%s ====================\n' "$h"
  SAIDA=$(openssl s_client -connect "$h:443" -servername "$h" -verify_hostname "$h" -verify_return_error -showcerts < /dev/null 2>&1)
  echo "O que o OpenSSL diz:"
  echo "$SAIDA" | grep -m1 -E "verify error|Verification error" | sed 's/^/   /' || true
  echo "$SAIDA" | grep -q -E "verify error|Verification error" || echo "   (sem erro de verificação)"
  echo "O que o certificado mostra:"
  openssl s_client -connect "$h:443" -servername "$h" < /dev/null 2>/dev/null \
    | openssl x509 -noout -subject -issuer -dates -ext subjectAltName 2>/dev/null | sed 's/^/   /'
done
echo
echo "Para cada site, responda: qual verificação do slide 20 falhou?"
echo "(validade · nome no SAN · cadeia até uma raiz confiável · raiz conhecida)"
echo "Depois abra os mesmos endereços no navegador e compare com o aviso que ele mostra."
