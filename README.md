# Lab TLS · Introdução à Criptografia (Encontro 15, 14/11/2026)

Ambiente pronto no navegador para os laboratórios do Material 15. Não instala nada no seu computador.

## Como abrir
1. Entre com a sua conta do GitHub (gratuita).
2. Clique em **Code → Codespaces → Create codespace on main**.
3. Espere o terminal abrir (na primeira vez leva alguns minutos para montar o ambiente).

## Lab B · OpenSSL
```bash
bash lab.sh              # usa www.google.com
bash lab.sh www.gov.br   # ou outro site
```
Ache no resultado: Protocol version, Ciphersuite, Negotiated TLS1.3 group e Verification.
Este ambiente usa OpenSSL 3.5: o grupo deve aparecer como X25519MLKEM768 quando o site oferece.

## Lab C · captura com tshark (o Wireshark do terminal)
```bash
bash captura.sh              # usa www.gov.br
bash captura.sh www.google.com
```
Mostra os campos do ClientHello e do ServerHello: nome do site (SNI), suítes, versão e grupo.
O arquivo `captura.pcapng` pode ser baixado (botão direito → Download) e aberto no Wireshark.

## Comandos soltos, se preferir digitar
```bash
openssl s_client -connect www.google.com:443 -servername www.google.com -brief < /dev/null
openssl s_client -connect www.google.com:443 -tls1_2 -brief < /dev/null
openssl s_client -connect tls-v1-0.badssl.com:1010 -tls1 < /dev/null
```

## Ao terminar
Pare o codespace (menu Codespaces → Stop) para não gastar a sua cota gratuita mensal.
Nada do que você faz aqui afeta o seu computador. Não digite senhas nem dados pessoais neste ambiente.
