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

Não há build, dependências ou etapa de compilação: os arquivos da pasta `public/` são exatamente os que vão ao ar.

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
├── public/            tudo o que vai ao ar
│   ├── assets/
│   │   ├── css/       folha de estilo única
│   │   ├── images/    logo, favicons e fotografias
│   │   └── js/        menu, carrosséis e utilidades
│   ├── index.html
│   ├── antecipacao-de-recebiveis.html
│   ├── corretora-seguros.html
│   ├── quem-somos.html
│   ├── 404.html
│   ├── robots.txt
│   ├── sitemap.xml
│   └── _redirects
├── wrangler.jsonc     configuração de publicação na Cloudflare
└── README.md
```

- Os arquivos HTML ficam na raiz de `public/`.
- Os ativos compartilhados ficam em `public/assets/`.
- Os redirecionamentos ficam em `public/_redirects`.

O CSS e o JavaScript são carregados com um sufixo de versão (`?v=AAAAMMDD`) para invalidar o cache do navegador. **Ao alterar CSS ou JavaScript, atualize esse número nas cinco páginas HTML.**

## Publicação

A produção está na Cloudflare, no domínio oficial https://bmccapital.com.br.

**Cada commit na branch `main` é publicado automaticamente** pela Cloudflare (Workers Builds), em cerca de um minuto. Por isso, toda alteração deve ser validada antes de chegar à `main`. A publicação automática foi ligada em 03/11/2026.

A configuração de publicação fica em `wrangler.jsonc`. O domínio é gerenciado pelo painel da Cloudflare, não por este arquivo.

Para voltar a uma versão anterior: no painel da Cloudflare, abra o Worker, vá em **Deployments** e use **Rollback**.

## Direitos

© 2026 BMC Capital Partners. Todos os direitos reservados.
