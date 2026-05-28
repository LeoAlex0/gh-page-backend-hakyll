# zLeoAlex 的 Hakyll 博客

这是一个使用 Hakyll + Nix 构建的静态博客。当前功能包括文章归档、标签/分类页、RSS/Atom feed、代码高亮、代码块行号与复制按钮、按需 MathJax、按需 GeoGebra、Giscus 评论区和本地命令部署。

## 常用命令

进入开发环境：

```sh
nix develop
```

构建站点：

```sh
hakyll-site build
```

本地预览：

```sh
hakyll-site watch
```

清理缓存和输出：

```sh
hakyll-site clean
```

也可以不进入开发环境，直接通过 flake 执行：

```sh
nix run . build
nix run . watch
nix run . clean
```

## VSCode / HLS

仓库根目录提供了 `cabal.project` 和 `hie.yaml`，HLS 会把 `ssg/src` 识别为 `ssg:exe:hakyll-site` 组件，因此 `Site.*` 模块可以互相跳转和诊断。

建议从 Nix 开发环境启动 VSCode，或配合 direnv 让编辑器继承 `nix develop` 的 PATH：

```sh
nix develop
code .
```

## 部署

部署由 Hakyll 自己的 `deploy` 命令触发：

```sh
hakyll-site deploy
```

`ssg/src/Main.hs` 中的 `deployCommand` 指向 `scripts/deploy.sh`。脚本默认会把 `dist/` 推送到：

- 仓库：`git@github.com:LeoAlex0/LeoAlex0.github.io.git`
- 分支：`master`

可以用环境变量覆盖默认值：

```sh
DEPLOY_REPO=git@github.com:you/you.github.io.git \
DEPLOY_BRANCH=main \
hakyll-site deploy
```

GitHub Actions 只做构建检查，不再自动发布。

脚本会先构建站点，再推送结果。如果只是测试推送脚本，可以设置 `DEPLOY_SKIP_BUILD=true` 跳过构建。

## Giscus

评论开关使用 Markdown front matter 的统一标准：需要 Giscus 的 Markdown 写 `comments: true`；不需要评论就不要写 `comments` 字段。不要写 `comments: false`，模板只判断字段是否存在。

```yaml
comments: true
```

现有文章都显式写了 `comments: true`；`src/pages/about.md` 和 `src/pages/whoami.md` 不声明 `comments`，因此不会加载评论区。

Giscus 配置在 `ssg/src/Site/Config.hs`。当前评论仓库是 `LeoAlex0/blog-comments`，并使用同一组翻译共享的稳定 term 作为 discussion 映射方式。Giscus 的界面语言跟随页面右上角的全局语言开关。

首次启用时需要完成 GitHub 侧配置：

1. 在 `LeoAlex0/blog-comments` 开启 Discussions。
2. 安装 Giscus GitHub App，并授权给 `LeoAlex0/blog-comments`。
3. 访问 <https://giscus.app/zh-CN> 生成配置，或请求 `https://giscus.app/api/discussions/categories?repo=LeoAlex0%2Fblog-comments` 获取 `categoryID`。
4. 把得到的分类 ID 写入 `ssg/src/Site/Config.hs` 的 `giscusCategoryID`。

如果 `giscusCategoryID` 为空，前端不会加载 Giscus，这样本地构建和预览仍然可用。

## 语言

页面默认语言是 `zh-CN`。每篇文章或页面都可以通过 Markdown front matter 声明语言：

```yaml
lang: en
```

`lang` 会用于对应内容块的 `lang` 标记。全站语言开关目前支持 `zh-CN` 和 `en`，会保存在浏览器本地，并统一影响导航、首页、归档页、页面内容、文章内容、代码复制按钮和 Giscus 界面语言。某篇文章没有对应语言版本时，正文会回退到默认语言。

可以为同一篇文章或页面准备多个语言版本。默认语言版本负责生成页面，其他语言版本作为同页内容被合并进去：

```text
src/posts/sample/index.md       -> /post/sample.html
src/posts/sample/index.en.md    -> 合并进 /post/sample.html
src/pages/about.md              -> /about/
src/pages/about.en.md           -> 合并进 /about/
```

非默认语言版本需要在 front matter 中显式声明对应的 `lang`。同一篇目录式文章的多个语言版本可以共用文章目录里的图片和其他资源。构建结果只输出默认语言页面，其他语言作为同页内容由全局语言开关切换。

首页、归档、标签、分类和 feed 只收录默认语言版本，避免同一篇文章以多个语言版本重复出现。首页和导航等模板文案通过 `data-i18n-en` 提供英文文本；文章和普通页面通过同名 Markdown 文件提供翻译。同一组翻译只输出一个页面，并共享同一个 Giscus discussion，避免评论区按语言版本分裂。

## 文章结构

文章采用目录式组织：

```text
src/posts/
  2026-05-22-sample-post/
    index.md
    figure.png
```

`index.md` 是文章正文。同目录下可以放只给这篇文章使用的图片或其他资源。资源会发布到：

```text
/post/<slug>/<filename>
```

例如：

```markdown
![示意图](/post/sample-post/figure.png)
```

文章本身仍发布为：

```text
/post/<slug>.html
```

如果目录名带日期前缀，例如 `2026-05-22-sample-post`，发布时会自动去掉日期，得到 `/post/sample-post.html`。

## Math

MathJax 和 Mermaid 数学公式的 KaTeX 默认不加载。需要数学公式的文章，在 front matter 中声明：

```yaml
math: true
```

支持 `$...$`、`$$...$$`、`\(...\)` 和 `\[...\]`。没有声明 `math: true` 的页面不会加载 MathJax 脚本和 KaTeX 样式，以减少前端开销。

## GeoGebra

需要 GeoGebra 的文章声明：

```yaml
geogebra: true
```

如果文章里也有数学公式，仍然需要额外声明：

```yaml
math: true
```

正文中使用普通 Markdown 链接语法引用同目录的 `.geogebra` 文件：

```markdown
[GeoGebra：拖动点 P，观察焦点连线。](ellipse-focus-demo.geogebra)
```

对应的 `ellipse-focus-demo.geogebra` 写成 JSON：

```json
{
  "appName": "classic",
  "height": 460,
  "animation": true,
  "animationObjects": ["P"],
  "view": {
    "xMin": -6,
    "xMax": 6,
    "yMin": -4,
    "yMax": 4
  },
  "commands": [
    "A=(-3,0)",
    "B=(3,0)",
    "c=Ellipse[A,B,4.2]",
    "P=Point[c]"
  ]
}
```

构建时会把独立成段的 `.geogebra` 链接转换成 GeoGebra applet。这样 VSCode Markdown Preview 会显示一个普通链接，不会尝试把 `.geogebra` 当作图片解码。

GeoGebra 的界面语言由全站语言开关统一控制，不在 `.geogebra` 文件里单独声明。

三维演示可以把 `appName` 设置为 `3d`，并在 `commands` 里使用 `Surface`、`Curve`、`Segment` 等三维对象命令。

建议在 JSON 里使用 `Ellipse[A,B,4.2]` 这种方括号形式写英文命令，避免 GeoGebra 在中文界面下按本地化命令解析而报“未定义指令”。

## RSS / Atom

站点会生成两个 feed：

- `/rss.xml`
- `/atom.xml`

模板中已经声明了 `<link rel="alternate">`，读者可以用常见 RSS 阅读器订阅。构建时会从文章快照生成 feed 内容。

## 主要文件

- `ssg/src/Main.hs`：Hakyll 入口
- `ssg/src/Site/`：构建规则、路由、上下文、Pandoc 转换和 feed
- `src/templates/`：页面模板
- `src/css/default.css`：主样式和暗色模式
- `src/css/code.css`：代码高亮 token 样式
- `src/js/script.js`：主题切换、代码复制、GeoGebra 和 Giscus 初始化
- `scripts/deploy.sh`：`hakyll-site deploy` 调用的发布脚本
