# Ambiente do Lab TLS - Introdução à Criptografia (SENAC-RS, 2026-2)
# Debian 13 (trixie) traz OpenSSL 3.5, que já negocia o grupo pós-quântico X25519MLKEM768.
FROM debian:trixie
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      openssl ca-certificates curl tshark less git \
 && rm -rf /var/lib/apt/lists/*
