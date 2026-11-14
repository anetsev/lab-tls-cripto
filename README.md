# Lab TLS · Introdução à Criptografia (Encontro 15, 14/11/2026)

Laboratório **individual**. Você vai digitar cada comando, entender a sintaxe e ler o resultado.
Cada laboratório gera prints para a **Atividade 008** (entrega pelo BB até 21/11/2026, às 23h59).

> Os arquivos `LAB_A.sh` a `LAB_D.sh` são o gabarito do professor. **Não use os `.sh`**: o objetivo é você digitar os comandos.

---

## Antes de começar

1. Abra https://codespaces.new/anetsev/lab-tls-cripto e clique em **Create codespace**.
2. O **terminal** fica na parte de baixo da tela. Se não aparecer: menu ☰ → Terminal → New Terminal.
3. Dicas do terminal:
   - **Colar:** Ctrl+Shift+V (no terminal do navegador, Ctrl+V pode não funcionar).
   - **Repetir o último comando:** seta para cima.
   - **Parar um comando que travou:** Ctrl+C.
   - **Limpar a tela:** `clear`.
4. **Print:** depois de cada comando pedido, tire um print em que apareçam o comando e o resultado
   (Windows: Win+Shift+S · macOS: Cmd+Shift+4).

Nada do que você faz aqui afeta o seu computador. Os comandos só **leem** informações públicas de sites.

---

## Lab A · o que o cadeado do navegador mostra (slide 37 · 7 min)

Primeiro, no **navegador**, abra https://www.gov.br e veja as informações de segurança
(Chrome/Edge: F12 → aba *Privacy and security* ou *Security*; Firefox: cadeado → Conexão segura → Mais informações).
Anote versão do TLS, troca de chave e cifra. **Print 1.**

Agora confira as mesmas informações pelo terminal.

### Comando A1 · a conexão

```bash
openssl s_client -connect www.gov.br:443 -servername www.gov.br -brief < /dev/null
```

| Parte | O que significa |
|---|---|
| `openssl` | a ferramenta de criptografia (a mesma biblioteca usada por muitos servidores) |
| `s_client` | "faça o papel de um cliente TLS", como o navegador |
| `-connect www.gov.br:443` | com qual servidor e porta conectar (443 é a porta do HTTPS) |
| `-servername www.gov.br` | o nome do site que vai no **SNI** do ClientHello (slide 17) |
| `-brief` | mostra só um resumo do handshake |
| `< /dev/null` | não manda nada depois do handshake, para o comando terminar sozinho |

**Procure no resultado:**
- `Protocol version` → a versão do TLS negociada.
- `Ciphersuite` → a cifra escolhida (slide 12).
- `Negotiated TLS1.3 group` → o grupo da troca de chaves (X25519MLKEM768 é o híbrido pós-quântico, slide 30).
- `Verification: OK` → o certificado passou nas verificações (slide 20).

### Comando A2 · o certificado

```bash
openssl s_client -connect www.gov.br:443 -servername www.gov.br < /dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -dates
```

| Parte | O que significa |
|---|---|
| `2>/dev/null` | esconde as mensagens de andamento, para sobrar só o certificado |
| `\|` | "pipe": a saída do primeiro comando vira a entrada do segundo |
| `openssl x509` | lê um certificado X.509 (Material 14) |
| `-noout` | não imprime o certificado inteiro em código |
| `-subject` / `-issuer` | de quem é o certificado / quem emitiu (a AC) |
| `-dates` | validade: `notBefore` (início) e `notAfter` (fim) |

**Print 2** (comandos A1 e A2). **Compare com o print 1:** os dados batem? Se o emissor fosse diferente, o que isso indicaria? (slide 29)

---

## Lab B · versões do TLS com OpenSSL (slide 38 · 10 min)

### Comando B1 · conexão normal

```bash
openssl s_client -connect www.google.com:443 -servername www.google.com -brief < /dev/null
```
Mesma sintaxe do A1, agora com o Google. Anote `Protocol version`, `Ciphersuite` e o grupo.

### Comando B2 · forçando o TLS 1.2

```bash
openssl s_client -connect www.google.com:443 -servername www.google.com -tls1_2 -brief < /dev/null
```

| Parte nova | O que significa |
|---|---|
| `-tls1_2` | o cliente só aceita TLS 1.2 |

**Compare o nome da `Ciphersuite` com o do B1.** No TLS 1.2 o nome mostra também a troca de chave e a assinatura
(ex.: `ECDHE-ECDSA-AES128-GCM-SHA256`). No 1.3 essas partes são negociadas à parte (slide 12).

### Comando B3 · tentando o TLS 1.0 (deve falhar)

```bash
openssl s_client -connect tls-v1-0.badssl.com:1010 -servername tls-v1-0.badssl.com -tls1 < /dev/null
```

| Parte nova | O que significa |
|---|---|
| `tls-v1-0.badssl.com:1010` | servidor de testes que só fala TLS 1.0, na porta 1010 |
| `-tls1` | o cliente pede TLS 1.0 |

**Leia o erro.** Quem recusou a conexão: o seu cliente ou o servidor? Por que isso é bom? (slide 9)

**Print 3** (B1, B2 e B3).

---

## Lab C · capturando o handshake com o tshark (slides 39 e 40 · 12 min)

O `tshark` é o Wireshark de linha de comando. Vamos capturar o acesso a um site e ler o ClientHello e o ServerHello.

### Comando C1 · descobrir a placa de rede

```bash
ip -br link
```
Mostra as interfaces de rede. Use a que **não** é `lo` (normalmente `eth0`).

### Comando C2 · iniciar a captura

```bash
tshark -i eth0 -f "tcp port 443" -w captura.pcapng -a duration:15 &
```

| Parte | O que significa |
|---|---|
| `-i eth0` | em qual interface capturar |
| `-f "tcp port 443"` | **filtro de captura**: só guarda tráfego HTTPS |
| `-w captura.pcapng` | grava os pacotes neste arquivo (o mesmo formato do Wireshark) |
| `-a duration:15` | para sozinho depois de 15 segundos |
| `&` | roda em segundo plano, para você poder digitar o próximo comando |

Se aparecer erro de permissão, repita com `sudo` no início.

### Comando C3 · gerar o tráfego (digite logo em seguida, antes dos 15 s)

```bash
curl -s -o /dev/null https://www.gov.br
```

| Parte | O que significa |
|---|---|
| `curl` | um cliente HTTP de terminal: faz o mesmo pedido que o navegador |
| `-s` | silencioso, sem barra de progresso |
| `-o /dev/null` | descarta a página: só interessa o handshake |

Espere a captura terminar (aparece uma mensagem com o número de pacotes; aperte Enter).

### Comando C4 · listar só o ClientHello e o ServerHello

```bash
tshark -r captura.pcapng -Y "tls.handshake.type == 1 || tls.handshake.type == 2"
```

| Parte | O que significa |
|---|---|
| `-r captura.pcapng` | lê o arquivo gravado (em vez de capturar) |
| `-Y "..."` | **filtro de exibição**, o mesmo da barra do Wireshark |
| `tls.handshake.type == 1` | ClientHello · `== 2` é o ServerHello |

### Comando C5 · os campos da tabela do slide 40

```bash
tshark -r captura.pcapng -Y "tls.handshake.type == 1" -T fields -e tls.handshake.extensions_server_name -e tls.handshake.extensions_key_share_group
tshark -r captura.pcapng -Y "tls.handshake.type == 2" -T fields -e tls.handshake.ciphersuite -e tls.handshake.extensions.supported_version -e tls.record.version
```

| Parte | O que significa |
|---|---|
| `-T fields` | em vez do pacote inteiro, mostra só os campos pedidos |
| `-e <campo>` | cada campo que você quer ver |
| `extensions_server_name` | o **SNI**: o nome do site, em claro |
| `extensions_key_share_group` | os grupos da troca de chaves (0x11ec = X25519MLKEM768, 0x001d = x25519) |
| `ciphersuite` | a suíte escolhida pelo servidor (0x1301 = TLS_AES_128_GCM_SHA256, 0x1302 = TLS_AES_256_GCM_SHA384) |
| `supported_version` | a versão **real** (0x0304 = TLS 1.3) |
| `tls.record.version` | a versão no cabeçalho do pacote (0x0303 = "TLS 1.2"): a **pegadinha** do slide 40 |

Se o tshark responder que algum campo não é válido, apague aquele `-e ...` e rode de novo.

### Comando C6 · o certificado aparece?

```bash
tshark -r captura.pcapng -Y "tls.handshake.type == 11"
```
O tipo 11 é a mensagem *Certificate*. Se não aparecer nada, é porque no TLS 1.3 ela vai **cifrada** (slide 19).

### Opcional · ver tudo do ClientHello

```bash
tshark -r captura.pcapng -Y "tls.handshake.type == 1" -O tls | less
```
`-O tls` detalha só a parte TLS. Use as setas para rolar e `q` para sair.

**Print 4** (C4, C5 e C6). O arquivo `captura.pcapng` pode ser baixado (botão direito no arquivo → Download) e aberto no Wireshark.

---

## Lab D · certificados com problema de propósito (slide 41 · 8 min)

O badssl.com é um site de **testes** com certificados quebrados de propósito.
No **navegador**, abra um destes endereços, **leia o aviso e volte** (não clique em continuar). **Print 6.**

Agora veja o que o OpenSSL diz. Faça para cada um dos quatro sites, trocando o nome nos dois lugares:

```bash
openssl s_client -connect expired.badssl.com:443 -servername expired.badssl.com -verify_hostname expired.badssl.com -verify_return_error -brief < /dev/null
```

| Parte nova | O que significa |
|---|---|
| `-verify_hostname <nome>` | confere se o nome está no certificado (SAN), como faz o navegador |
| `-verify_return_error` | se alguma verificação falhar, interrompe e mostra o erro |

Sites: `expired.badssl.com` · `wrong.host.badssl.com` · `self-signed.badssl.com` · `untrusted-root.badssl.com`

Para ver o certificado de um deles:

```bash
openssl s_client -connect expired.badssl.com:443 -servername expired.badssl.com < /dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -dates -ext subjectAltName
```
`-ext subjectAltName` mostra os nomes que o certificado cobre.

Preencha:

| Site | Erro do OpenSSL | Qual verificação falhou? (slide 20) |
|---|---|---|
| expired | | |
| wrong.host | | |
| self-signed | | |
| untrusted-root | | |

**Print 5** (os quatro comandos).

---

## Ao terminar

1. Junte os 6 prints, a tabela e as respostas da **Atividade 008** num Word ou PDF e envie pelo BB.
2. **Pare o codespace:** botão **Codespaces** no canto inferior esquerdo → *Stop Current Codespace*.
   Assim você não gasta a sua cota gratuita mensal.

Não digite senhas nem dados pessoais neste ambiente.
