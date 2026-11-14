# Lab TLS · Introdução à Criptografia (Encontro 15, 14/11/2026)

Ambiente pronto no navegador para os laboratórios do Material 15. Não instala nada no seu computador.

## Como abrir
1. Entre com a sua conta do GitHub (gratuita).
2. Abra https://codespaces.new/anetsev/lab-tls-cripto e clique em **Create codespace**.
3. Espere o terminal abrir (na primeira vez leva alguns minutos para montar o ambiente).

## Os laboratórios
| Lab | Slide | Onde fazer | Comando |
|---|---|---|---|
| A · o cadeado do navegador | 35 | no seu navegador (conferência no terminal) | `bash LAB_A.sh` |
| B · handshake com OpenSSL | 36 | aqui | `bash LAB_B.sh` |
| C · captura do handshake | 37 e 38 | aqui (ou no Wireshark do seu PC) | `bash LAB_C.sh` |
| D · sites com problema | 39 | aqui e no navegador | `bash LAB_D.sh` |

Para rodar todos em sequência: `bash lab.sh`

### Lab A
`bash LAB_A.sh` (ou `bash LAB_A.sh www.google.com`).
Mostra versão do TLS, grupo, cifra, emissor e validade: os mesmos dados que você anotou no navegador.

### Lab B
`bash LAB_B.sh` (ou `bash LAB_B.sh www.gov.br` para outro site).
Ache no resultado: Protocol version, Ciphersuite, Negotiated TLS1.3 group e Verification.
Este ambiente usa OpenSSL 3.5: o grupo deve aparecer como X25519MLKEM768 quando o site oferece.

### Lab C
`bash LAB_C.sh` (ou `bash LAB_C.sh www.google.com`).
Captura o acesso ao site e preenche a tabela do slide 38: SNI, suítes oferecidas, grupos,
suíte e versão escolhidas pelo servidor e se o certificado aparece. Serve de base para a Atividade 007.
O arquivo `.pcapng` gerado pode ser baixado (botão direito → Download) e aberto no Wireshark.

### Lab D
`bash LAB_D.sh`
Mostra, para cada site de teste do badssl.com, o erro que o OpenSSL encontrou e os dados do certificado.
Depois abra os mesmos endereços no navegador e compare com o aviso. Leia o aviso e volte: não clique em "continuar".

## Ao terminar
Pare o codespace (menu Codespaces → Stop) para não gastar a sua cota gratuita mensal.
Nada do que você faz aqui afeta o seu computador. Não digite senhas nem dados pessoais neste ambiente.
