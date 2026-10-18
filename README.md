# sasaOrange 个人博客

个人博客的站点仓库：文章、配置和部署都在这里。页面本身由
[sasaOrange-blog-hugo](https://github.com/TruE-aL/sasaOrange-blog-hugo) 这个主题渲染，
主题以 submodule 挂在 `themes/ruri`。

写作只需要动 `content/`；改外观去主题仓库。

## 两个仓库各管什么

| 仓库 | 部署到 | 放什么 |
| --- | --- | --- |
| **本仓库** `sasaOrange-blog-hugo-personalsite` | Cloudflare Pages | 你的文章、配置、图片 |
| `sasaOrange-blog-hugo` | [GitHub Pages](https://true-a-l.github.io/sasaOrange-blog-hugo/) | 主题源码 + 通用示例 `exampleSite` |

两边各跑各的 GitHub Actions，互不干扰：主题仓库只更新演示站，不会动你的博客；你写文章也不会触发主题仓库。

主题更新后，主题仓库的 `bump-site.yml` 会自动把本仓库 `themes/ruri` 的指针推到最新提交，随后本仓库的部署自动重跑。所以正常情况下**你不需要手动升级主题**。

## 目录

```
config/_default/
  hugo.toml      站点地址、标题、语言
  params.yaml    作者、首页文案、菜单、评论、分页
content/
  posts/         文章，文件名带语言后缀：xxx.zh-cn.md
  about/         关于页，每种语言一个 index.<lang>.md
  archives/      归档页标题
  culture/       文艺栏目（书影音），分类页按需填
static/images/   头图等静态图片
scripts/build.sh 构建：hugo -> pagefind
```

## 本地写作

```sh
git clone --recursive https://github.com/TruE-aL/sasaOrange-blog-hugo-personalsite.git
cd sasaOrange-blog-hugo-personalsite

# 已经克隆过、但 themes/ruri 是空的：
git submodule update --init --recursive

# 预览（Hugo 自带服务器，热更新）
hugo server

# 完整构建（含搜索索引）
bash scripts/build.sh
```

`hugo server` 不会生成 Pagefind 索引，所以本地预览时搜索是空的；
要验证搜索，跑 `scripts/build.sh` 再 `python3 -m http.server 8080 --directory public`。

## 更新主题

一般不用管：主题仓库有提交后，它的 `bump-site.yml` 会自动来改这里的指针。

想手动升到主题最新版：

```sh
git submodule update --remote themes/ruri
git commit -am "chore: 升级主题"
```

推上去后 GitHub Actions 自动重新构建部署。想钉回某个提交版本：

```sh
cd themes/ruri && git checkout <commit-sha> && cd ../..
git add themes/ruri && git commit -m "chore: 主题回退到 <sha>"
```

## 写一篇新文章

在 `content/posts/` 新建 `my-post.zh-cn.md`：

```yaml
---
title: "标题"
date: 2026-10-18T10:00:00+08:00
description: "摘要，会出现在卡片和 SEO 里"
tags: [随笔]
categories: [Journal]
---
```

文件名后缀决定语言：`.zh-cn`、`.zh-tw`、`.en`、`.ja`。只写中文就只放 `.zh-cn`，
其他语言不写也不会出现空页面。

## 部署

推到 `main` 就自动部署，不需要手动操作：

| 触发 | 结果 |
| --- | --- |
| push 到 `main` | 部署生产环境到 `sasaorange-blog-hugo.pages.dev` |
| 开 / 更新 PR | 部署预览环境，并在 PR 里回帖预览地址 |
| 手动触发 | 同 push 到 main |

需要的两个仓库密钥：

- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`

换自定义域名的话，改 `config/_default/hugo.toml` 里的 `baseURL`，再到
Cloudflare Pages 加域名即可。
