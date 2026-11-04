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
├── public/                    tudo o que vai ao ar
│   ├── assets/
│   │   ├── css/               folha de estilo única
│   │   ├── fonts/             IBM Plex Sans e Source Serif 4 (licença OFL)
│   │   ├── images/            logo, favicons e fotografias
│   │   └── js/                menu, carrosséis e utilidades
│   ├── index.html
│   ├── antecipacao-de-recebiveis.html
│   ├── corretora-seguros.html
│   ├── quem-somos.html
│   ├── 404.html
│   ├── robots.txt
│   ├── sitemap.xml
│   ├── _redirects             redirecionamentos
│   └── _headers               cabeçalhos de segurança
├── scripts/
│   ├── verificar-site.sh      trava antes de publicar
│   └── atualizar-versao.sh    versão ?v= do CSS e do JS
├── wrangler.jsonc             configuração de publicação na Cloudflare
└── README.md
```

- Os arquivos HTML ficam na raiz de `public/`.
- Os ativos compartilhados ficam em `public/assets/`. As fontes são servidas pelo próprio site: nenhuma visita envia dados ao Google.
- Os redirecionamentos ficam em `public/_redirects` e os cabeçalhos de segurança em `public/_headers`.

O CSS e o JavaScript são carregados com um sufixo de versão (`?v=`) igual à impressão digital do próprio arquivo, para invalidar o cache do navegador. **Ao alterar CSS ou JavaScript, rode `bash scripts/atualizar-versao.sh`**: ele atualiza as cinco páginas de uma vez.

## Experimento de vidro (04/11/2026)

Barras e botões em vidro translúcido, no estilo "Liquid Glass" do iOS 26, feito só com CSS (`backdrop-filter`). Está na **seção 14 do `styles.css`**. Para desfazer, apague a seção inteira e rode `bash scripts/atualizar-versao.sh`. Quem ativa "reduzir transparência" ou "aumentar contraste" no sistema recebe a versão sólida.

O logo (`bmc-logo.png`) passou a ter fundo transparente, para não aparecer como um retângulo sobre o vidro. Sobre fundo branco ele é idêntico ao anterior.

## Verificação antes de publicar

`scripts/verificar-site.sh` roda antes de cada publicação. Se encontrar um problema, a versão **não** vai ao ar. Ele confere:

- arquivos obrigatórios e configuração de publicação;
- nenhum arquivo interno dentro de `public/`;
- um `h1`, `title`, `description` e `lang` em cada página;
- links internos que existem e nenhum link `http://`;
- cabeçalho, rodapé e botão de WhatsApp iguais nas cinco páginas;
- um único telefone, e-mail e endereço da Área do Cliente;
- versão `?v=` do CSS e do JavaScript em dia;
- todo redirecionamento leva a uma página que existe;
- nenhuma chamada ao Google Fonts, e manifesto com o nome e a cor certos.

Para rodar localmente: `bash scripts/verificar-site.sh`.

## Publicação

A produção está na Cloudflare, no domínio oficial https://bmccapital.com.br.

**Cada commit na branch `main` é publicado automaticamente** pela Cloudflare (Workers Builds), em cerca de um minuto, **se passar na verificação**. A publicação automática foi ligada em 03/11/2026.

Configuração no painel (Worker → Configurações → Compilações):

| Campo | Valor |
|---|---|
| Comando de build | `bash scripts/verificar-site.sh` |
| Comando de implantação | `npx wrangler@4.157.0 deploy` (versão fixa) |

A configuração de publicação fica em `wrangler.jsonc`: o site só responde no domínio oficial (sem `workers.dev`). O domínio, o `www` e o redirecionamento `www` → domínio principal são gerenciados pelo painel da Cloudflare, não por este arquivo.

Depois de publicar, a Home (`/`) pode levar alguns minutos para mostrar a versão nova por causa do cache; as demais páginas atualizam em segundos.

Para voltar a uma versão anterior: no painel da Cloudflare, abra o Worker, vá em **Deployments** e use **Rollback**.

## Direitos

© 2026 BMC Capital Partners. Todos os direitos reservados.
