#!/usr/bin/env bash
# ==============================================================================
# GitBook 一键构建与双端发布脚本 (gitbook.sh)
# ==============================================================================
#
# 【一、日常使用说明】
#   1. 一键提交源码、构建静态网页并发布至 Gitee + GitHub Pages (www.1221.site)：
#      ./gitbook.sh "本次修改的 commit 备注"
#
#   2. 若发布时 GitHub 网络连接超时，网络恢复后无需重新 build，直接快速补推：
#      ./gitbook.sh --push
#
#   3. 查看本使用说明：
#      ./gitbook.sh --help
#
# 【二、本地常用 GitBook 命令】
#   - 本地预览（默认 http://localhost:4000）：gitbook serve
#   - 指定端口预览：gitbook serve --port 8080
#   - 仅生成静态网页（输出到 _book/）：gitbook build
#   - 安装 book.json 中的插件：gitbook install
#
# 【三、新增文档流程】
#   1. 在 pages/<分类目录>/ 下新建 .md 文件（图片放入对应分类的 images/ 目录）
#   2. 在 SUMMARY.md 中添加章节链接
#   3. 若新增了分类目录，检查 .bookignore 确保未被忽略
#   4. 执行 ./gitbook.sh "新增 xxx 文档" 完成发布
#
# 【四、远程仓库与自定义域名说明】
#   - origin (Gitee) : https://gitee.com/chenchangqing/sdxy.git
#   - github (GitHub): git@github.com:chenchangqing/sdxy.git (使用 SSH 免密推送)
#     （新环境添加命令：git remote add github git@github.com:chenchangqing/sdxy.git）
#   - 自定义域名：www.1221.site（DNS A 记录指向 GitHub Pages IP 185.199.109.153，
#     脚本会自动在 gh-pages 分支生成并保留 CNAME 文件）
#
# 【五、常见问题排查】
#   - 报错 Cannot find module './lib/cheerio' (或插件子依赖缺失)：
#     原因：node_modules 中存在残缺空目录，gitbook install 内置的 npm@3.9.2 跳过了已存在
#     package.json 的包。
#     解决：执行 rm -rf node_modules && gitbook install，或从 ~/.npm/<包名>/<版本>/package.tgz 解压恢复。
# ==============================================================================

set -e

# 查看帮助说明
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    sed -n '2,40p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
fi

# 如果传入 --push 参数，仅执行远程分支补推（跳过耗时的 gitbook build）
if [ "$1" = "--push" ]; then
    echo "🚀 正在补推本地 develop / master / gh-pages 分支到远程..."
    git push -u origin develop master gh-pages -f && echo "✅ Gitee (origin) 推送成功" || echo "⚠️ Gitee (origin) 推送失败"
    GIT_SSH_COMMAND="ssh -o ConnectTimeout=10" git push github develop master gh-pages -f && echo "✅ GitHub (github) 推送成功" || echo "⚠️ GitHub (github) 推送失败，请检查网络或代理后重试: ./gitbook.sh --push"
    exit 0
fi

COMMIT_MSG="${*:-no comment}"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# 0. 分支安全检查：确保在 develop 分支进行源码提交
if [ "$CURRENT_BRANCH" = "gh-pages" ]; then
    echo "❌ 错误：当前处于 gh-pages（静态网页）分支，请勿在此分支直接发布！"
    echo "👉 请先执行: git checkout develop"
    exit 1
elif [ "$CURRENT_BRANCH" != "develop" ]; then
    echo "⚠️ 当前处于 $CURRENT_BRANCH 分支，正在自动切换到 develop 分支..."
    if [ -n "$(git status --porcelain)" ]; then
        git stash push -u -m "auto-stash-before-switch-to-develop"
        git checkout develop
        git stash pop
    else
        git checkout develop
    fi
fi

# 1. 提交 develop 分支
git add .
if ! git diff --cached --quiet; then
    git commit -m "$COMMIT_MSG"
else
    echo "ℹ️ develop 分支无新增修改，继续执行同步与构建..."
fi

# 2. 同步 master 分支并构建静态站点
git checkout master
git pull origin master || echo "⚠️ 无法连接 Gitee 拉取 master，使用本地分支继续..."
git rebase develop

rm -rf _book
gitbook build
if [ ! -f "_book/index.html" ]; then
    echo "❌ 错误：gitbook build 构建失败，未生成 _book/index.html，已中止发布！"
    git checkout develop
    exit 1
fi

# 3. 切换到 gh-pages 分支，更新静态文件并绑定自定义域名 CNAME
git checkout gh-pages
if [ "$(git rev-parse --abbrev-ref HEAD)" != "gh-pages" ]; then
    echo "❌ 错误：切换到 gh-pages 分支失败，已中止清理操作以保护源码！"
    exit 1
fi
git pull origin gh-pages || echo "⚠️ 无法连接 Gitee 拉取 gh-pages，使用本地分支继续..."
shopt -s extglob
# 保留忽略的文件及自定义域名配置 CNAME
rm -rf !(_book|.git|.gitignore|ignore|node_modules|book.pdf|ads.txt|CNAME)
cp -r _book/* .
echo "www.1221.site" > CNAME
git add .
if ! git diff --cached --quiet; then
    git commit -m "build gh-pages: $COMMIT_MSG"
fi

# 4. 清理临时目录并立即切回 develop 分支（确保无论后续网络推送是否成功，本地始终回到 develop）
rm -r -f _book
git checkout develop
echo "✅ 本地构建完成，已切回 develop 分支。开始推送远程仓库..."

# 5. 统一推送到 Gitee (origin) 和 GitHub (github)，网络失败不中断脚本
ORIGIN_OK=0
GITHUB_OK=0

echo "📤 正在推送至 Gitee (origin)..."
if git push -u origin develop && git push -u origin master -f && git push -u origin gh-pages; then
    ORIGIN_OK=1
    echo "✅ Gitee (origin) 推送成功！"
else
    echo "⚠️ Gitee (origin) 推送失败！"
fi

echo "📤 正在推送至 GitHub (github)..."
if GIT_SSH_COMMAND="ssh -o ConnectTimeout=10" git push github develop master gh-pages -f; then
    GITHUB_OK=1
    echo "✅ GitHub Pages (www.1221.site) 推送成功！"
else
    echo "⚠️ GitHub 连接超时或推送失败（本地及 Gitee 不受影响）。"
    echo "👉 网络恢复后无需重新 build，直接执行以下命令即可补推："
    echo "   ./gitbook.sh --push"
fi

if [ "$ORIGIN_OK" -eq 1 ] && [ "$GITHUB_OK" -eq 1 ]; then
    echo "🎉 全部提交并发布至 Gitee & GitHub Pages (www.1221.site) OK！"
fi
