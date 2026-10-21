# Site BMC Capital Partners

Site institucional da BMC Capital Partners.

- **Atividade principal:** antecipação de recebíveis
- **Atividade secundária:** corretora de seguros
- **Site oficial:** https://bmccapital.com.br

Este repositório guarda o código-fonte da versão publicada, para histórico e recuperação.

## Tecnologias

- HTML
- CSS
- JavaScript sem framework
- Cloudflare Worker servindo ativos estáticos

Não há build, dependências ou etapa de compilação: os arquivos do repositório são exatamente os que vão ao ar.

## Páginas

| Página | URL |
|---|---|
| Home | `/` |
| Antecipação de Recebíveis | `/antecipacao-de-recebiveis` |
| Seguros | `/corretora-seguros` |
| A BMC | `/quem-somos` |
| Página não encontrada | `404.html` (status HTTP 404) |

As URLs são servidas **sem a extensão `.html`**.

## Estrutura

```text
.
├── assets/
│   ├── css/       folha de estilo única
│   ├── images/    logo, favicons e fotografias
│   └── js/        menu, carrosséis e utilidades
├── index.html
├── antecipacao-de-recebiveis.html
├── corretora-seguros.html
├── quem-somos.html
├── 404.html
├── robots.txt
├── sitemap.xml
└── _redirects
```

- Os arquivos HTML ficam na raiz.
- Os ativos compartilhados ficam em `assets/`.
- Os redirecionamentos ficam em `_redirects`.

O CSS e o JavaScript são carregados com um sufixo de versão (`?v=AAAAMMDD`) para invalidar o cache do navegador. **Ao alterar CSS ou JavaScript, atualize esse número nas cinco páginas HTML.**

## Publicação

A produção atual está na Cloudflare, no domínio oficial https://bmccapital.com.br, servida por um Worker da Cloudflare.

Este repositório **não** está conectado a nenhuma implantação automática. Alterações futuras devem ser validadas antes de qualquer publicação.

## Direitos

© 2026 BMC Capital Partners. Todos os direitos reservados.
