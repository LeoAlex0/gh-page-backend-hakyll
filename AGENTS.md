# Project Instructions

Hakyll + Nix 静态博客（zLeoAlex 个人博客）。

## Project Type: Hakyll Static Site Generator

- 构建工具：Nix（`flake.nix`）+ Cabal（`ssg/ssg.cabal`）
- 语言：Haskell（SSG） + Markdown / HTML / CSS / JS（内容与模板）
- 测试/验证：`nix build .#website --no-link`
- 本地预览：`nix develop` → `hakyll-site watch`

### Documentation
详见 `README.md`。

### Version Control
Git。`.gitignore` 排除了 `dist-newstyle/`、`ssg/_cache/`、`ssg/dist-newstyle/`。

## Agent Guidance

- **Never edit:** `dist-newstyle/`、`ssg/_cache/`、`ssg/dist-newstyle/`（构建产物与缓存目录）
- **Never edit:** `flake.lock`（由 Nix 管理）
- **Build verification:** `nix build .#website --no-link --print-build-logs`
- **Read-only surface:** 所有内容可读；仅对 `src/` 和 `ssg/src/` 进行写入
- **Content patterns:**
  - 文章：`src/posts/<slug>/index.md`（主语言）+ 可选 `index.en.md`（英文翻译）
  - 页面：`src/pages/<name>.md` + 可选 `<name>.en.md`
  - 模板：`src/templates/`
  - 静态资源：`src/css/`、`src/js/`、`src/images/`、`src/robots.txt`、`src/_config.yaml`
- **Front matter conventions:**
  - `math: true` — 按需加载 MathJax / Mermaid（KaTeX）
  - `mermaid: true` — 按需加载 Mermaid
  - `geogebra: true` — 按需加载 GeoGebra applet
  - `comments: true` — 启用 Giscus 评论区（不要写 `comments: false`）
  - `lang: en` — 标记非默认语言版本（默认 `zh-CN`）
  - `preview: <N>` — 首页预览截取 N 字符
- **Article resources:** 与 `index.md` 同目录，引用路径为 `/post/<slug>/<filename>`
- **Date-slug:** 目录名可带日期前缀（如 `2026-05-28-sample`），发布时自动去日期→`/post/sample.html`
- **Bilingual pages:** 只输出默认语言版本页面；其他语言内容由前端语言开关切换；同一组翻译共享 Giscus discussion

## Architecture

### Entry Points
- `ssg/src/Main.hs` — Hakyll 入口，调用 `siteConfig` + `siteRules`
- `flake.nix` — 定义 `nix develop` / `nix build` / `nix run`

### Key Modules (`ssg/src/Site/`)
| 文件 | 职责 |
|------|------|
| `Config.hs` | Hakyll 配置（站点 URL、Giscus ID、feed 元数据、deploy 命令） |
| `Rules.hs` | 构建规则：文章/页面编译、标签索引、RSS/Atom、sitemap、静态文件复制 |
| `Routes.hs` | 路由模式与 URL 生成（文章 slug、页面路径、资源路由） |
| `Context.hs` | Hakyll 模板上下文（站点元数据、双语 header、preview 截断） |
| `Pandoc.hs` | 自定义 Pandoc 编译器（代码行号、复制按钮、MathJax/Mermaid 注入） |
| `Feed.hs` | RSS / Atom feed 生成 |
| `GeoGebra.hs` | `.geogebra` 资源编译器（JSON → HTML applet） |

### Data Flow
1. `Main.hs` 启动 Hakyll，加载 `Config` 和 `Rules`
2. `Rules` 用 `Pattern` 匹配 `src/` 下的 Markdown 文件
3. `Pandoc` 将 Markdown 编译为 HTML，`Context` 注入模板变量
4. 模板（`src/templates/`）包裹内容 → 输出到 `dist/`
5. `Feed` 从文章快照生成 `rss.xml` / `atom.xml`
6. CI（GitHub Actions）在 `main` 分支 PR/push 时运行 `nix build` 检查构建

### Static Files (direct copy from `src/` to `dist/`)
`favicon.ico`, `robots.txt`, `_config.yaml`, `imgs/*`, `js/*`, `fonts/*`

## Cache Stability

- **Frequently-rebuilt files:** `dist/`（构建输出）、`ssg/_cache/`（Hakyll 缓存） — 每次构建可能变化
- **Stable scaffolding:** `AGENTS.md`、`README.md`、`flake.nix`、`ssg/ssg.cabal`、`hie.yaml`、`cabal.project`、`src/templates/`
- **Append, don't reorder:** 新增博客文章放在 `src/posts/` 末尾；不要重新排列已有内容文件

## Guidelines

- 文章采用目录式组织，每篇文章一个子目录
- 修改 SSG 代码后运行 `nix build .#website` 验证
- 在 `nix develop` 环境下编辑 Haskell 代码以获取 HLS 支持
- 部署前阅读 `README.md` 的「部署」节
