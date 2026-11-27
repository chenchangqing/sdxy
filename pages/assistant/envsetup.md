# Environment Setup

## Resources

* [Pinecone Official Website](https://www.pinecone.io/)
* [uv](https://docs.astral.sh/uv/)
* [Documentation Helper](https://github.com/emarco177/documentation-helper/tree/main)
* [Fork](https://github.com/chenchangqing/documentation-helper)

## 同步上游分支

GitHub 创建 fork 时默认勾选 **Copy the main branch only**，所以 [chenchangqing/documentation-helper](https://github.com/chenchangqing/documentation-helper) 起初只有 `main`。上游 [emarco177/documentation-helper](https://github.com/emarco177/documentation-helper) 的课程分支不会自动跟过来，页面上的 Sync fork 也只更新默认分支。

两边的 `main` 都在 `49a0c71`。在本地仓库把上游分支拉下来，再推到自己的 fork。`main` 已经一致，不用重推。

```
git remote add upstream https://github.com/emarco177/documentation-helper.git
git fetch upstream

git push origin \
  refs/remotes/upstream/1-start-here:refs/heads/1-start-here \
  refs/remotes/upstream/1-start-here-ai-powered-ingestion-finish:refs/heads/1-start-here-ai-powered-ingestion-finish \
  refs/remotes/upstream/1-start-here-ingestion-finish:refs/heads/1-start-here-ingestion-finish \
  refs/remotes/upstream/1-start-here-manual-ingestion-finish:refs/heads/1-start-here-manual-ingestion-finish \
  refs/remotes/upstream/2-retrieval-qa:refs/heads/2-retrieval-qa \
  refs/remotes/upstream/2-retrieval-qa-finish:refs/heads/2-retrieval-qa-finish \
  refs/remotes/upstream/3-frontend:refs/heads/3-frontend \
  refs/remotes/upstream/3-frontend-finish:refs/heads/3-frontend-finish \
  refs/remotes/upstream/chore/remove-langchain-docs-ignore:refs/heads/chore/remove-langchain-docs-ignore \
  refs/remotes/upstream/uv/1-start-here:refs/heads/uv/1-start-here
```

同步后的分支：

* `1-start-here`
* `1-start-here-ai-powered-ingestion-finish`
* `1-start-here-ingestion-finish`
* `1-start-here-manual-ingestion-finish`
* `2-retrieval-qa`
* `2-retrieval-qa-finish`
* `3-frontend`
* `3-frontend-finish`
* `chore/remove-langchain-docs-ignore`
* `uv/1-start-here`

本地切换：

```
git switch 1-start-here
```

上游以后新增分支时，先 `git fetch upstream`，再按同样的 refspec 把新分支推到 `origin`。

## 安装 uv

官方安装脚本：

```
curl -LsSf https://astral.sh/uv/install.sh | sh
```

`uv` 和 `uvx` 会装到 `~/.local/bin`。安装末尾如果出现：

```
mkdir: /Users/admin/.config/fish/conf.d: Permission denied
ERROR: command failed: mkdir -p /Users/admin/.config/fish/conf.d
```

原因是 `~/.config/fish` 属于 root（之前用 root 跑过 conda 初始化），当前用户无法在里面建 `conf.d`。二进制本身已经装好，失败的只是 fish 的 PATH 配置。

把 root 拥有的目录挪走，用当前用户重建，保留原来的 `config.fish`，再跑一次安装脚本：

```
cp ~/.config/fish/config.fish /tmp/config.fish.backup
mv ~/.config/fish ~/.config/fish.root-owned
mkdir -p ~/.config/fish/conf.d
cp /tmp/config.fish.backup ~/.config/fish/config.fish
curl -LsSf https://astral.sh/uv/install.sh | sh
```

`~/.zshrc` 末尾已经有 `source $HOME/.local/bin/env`。新开终端，或在当前终端执行：

```
source $HOME/.local/bin/env
uv --version
```

当前版本是 `uv 0.13.10`。Homebrew 里还有一份 `uv`，加载 env 之后优先使用 `~/.local/bin/uv`。

root 拥有的旧目录需要本机密码才能删：

```
sudo rm -rf ~/.config/fish.root-owned
```

## 切出个人分支

课程改动不直接提交到同步下来的 `uv/1-start-here`。从它切出 `uv/1-start-here-ccq`：

```
git switch uv/1-start-here
git switch -c uv/1-start-here-ccq
```

当前在 `uv/1-start-here-ccq`，起点是 `cdb03af`（与 `origin/uv/1-start-here` 相同）。这个分支还只在本地。要推到自己的 fork：

```
git push -u origin uv/1-start-here-ccq
```

## 同步依赖并配置 .env

在 `uv/1-start-here-ccq` 上安装依赖：

```
uv sync
```

`uv` 下载了 CPython 3.13.18，在项目里创建 `.venv`，并装好 210 个包。`.venv` 已被 `.gitignore` 忽略。

用 VS Code 打开环境变量文件：

```
code .env
```

当前终端找不到 `code`。VS Code 装在 `~/Installers/Visual Studio Code.app`，用完整路径打开：

```
"$HOME/Installers/Visual Studio Code.app/Contents/Resources/app/bin/code" .env
```

`.env` 内容：

```
OPENAI_API_KEY=sk-yourt-openai-key
PINECONE_API_KEY=<与 langchain 项目相同>
ZHIPU_API_KEY=<与 langchain 项目相同>
```

`.gitignore` 已忽略 `.env`，这些 key 不会进 git。

## 创建智谱索引

课程截图里的 `langchain-docs` 是 OpenAI `text-embedding-3-small`，维度 **1536**。智谱 `embedding-3` 只支持 **256 / 512 / 1024 / 2048**，不能写入同一个索引。这里只建智谱索引，不动 `langchain-docs`。

`create_index.py` 参考 `langchain/create_index.py`，固定为智谱：索引名 `langchain-docs-zhipu`，维度 **1024**，`cosine`，serverless，`aws` / `us-east-1`。已存在同名索引时会先删再重建。

核心代码：

```
ZHIPU_MODEL = "embedding-3"
ZHIPU_DIMENSION = 1024
INDEX_NAME = "langchain-docs-zhipu"


def zhipu_embeddings() -> ZhipuAIEmbeddings:
    # ZhipuAIEmbeddings reads ZHIPUAI_API_KEY. This project stores ZHIPU_API_KEY.
    return ZhipuAIEmbeddings(
        model=ZHIPU_MODEL,
        dimensions=ZHIPU_DIMENSION,
        api_key=os.environ["ZHIPU_API_KEY"],
    )


if __name__ == "__main__":
    vector = zhipu_embeddings().embed_query("langchain documentation")
    print(f"Zhipu {ZHIPU_MODEL} dimension: {len(vector)}")
    if len(vector) != ZHIPU_DIMENSION:
        raise SystemExit(
            f"expected {ZHIPU_DIMENSION} dimensions, got {len(vector)}"
        )

    pc = Pinecone(api_key=os.environ["PINECONE_API_KEY"])

    if pc.has_index(INDEX_NAME):
        print(f"Index '{INDEX_NAME}' found, deleting...")
        pc.delete_index(INDEX_NAME)

    pc.create_index(
        name=INDEX_NAME,
        vector_type="dense",
        dimension=ZHIPU_DIMENSION,
        metric="cosine",
        spec=ServerlessSpec(cloud="aws", region="us-east-1"),
    )
    print(f"Index '{INDEX_NAME}' created")
    print(pc.describe_index(INDEX_NAME))
```

先用 `ZHIPU_API_KEY` 请求一次 `embedding-3`，确认向量长度是 1024，再用 `PINECONE_API_KEY` 删除并重建同名索引。

```
uv run python create_index.py
```

`PINECONE_API_KEY` 与 `langchain` 项目相同，已经写入 `.env`。`create_index.py` 通过 `load_dotenv()` 读取它。

```
Index 'langchain-docs-zhipu' created
{'deletion_protection': 'disabled',
 'dimension': 1024,
 'host': 'langchain-docs-zhipu-b1ykucr.svc.aped-4627-b74a.pinecone.io',
 'metric': 'cosine',
 'name': 'langchain-docs-zhipu',
 'spec': {'serverless': {'cloud': 'aws', 'region': 'us-east-1'}},
 'status': {'ready': True, 'state': 'Ready'},
 'tags': None,
 'vector_type': 'dense'}
```

## 使用智谱 Key

`ZHIPU_API_KEY` 写在 `.env` 里，值与 `langchain` 项目相同。`ZhipuAIEmbeddings` 自动读取的环境变量是 `ZHIPUAI_API_KEY`，所以构造时把 `ZHIPU_API_KEY` 传给 `api_key`。

调用前先装智谱 SDK：

```
uv add zhipuai
```

装上 `zhipuai==2.1.5.20250825`。`create_index.py` 在创建 Pinecone 索引前用这个 key 请求一次 `embedding-3`，确认维度是 1024：

```
Zhipu embedding-3 dimension: 1024
```

## 点击 Run 失败

直接点 `create_index.py` 的 Run，用的是终端里的 `(base)` Anaconda，不是项目的 `.venv`。Anaconda 里没有 `pinecone` 和 `langchain_community`，导入就会失败。`uv run python create_index.py` 能过，是因为 `uv` 会使用 `.venv`。第 33 行的 `PINECONE_API_KEY` 没有问题。

在项目里新增 `.vscode/settings.json`，和 `langchain` 项目一样，把解释器和 Code Runner 都指到 `.venv`：

```
{
  "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python",
  "code-runner.executorMap": {
    "python": "$workspaceRoot/.venv/bin/python -u $fullFileName"
  }
}
```

如果窗口底部的解释器仍显示 `base`，用 Python: Select Interpreter 选 `documentation-helper/.venv/bin/python`，再点 Run。

[uv/1-start-here-ccq](https://github.com/chenchangqing/documentation-helper/tree/uv/1-start-here-ccq)

26.11.27