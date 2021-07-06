# rebase使用

### 查看日志

git log --oneline -10

### 拉取远程

git fetch team

### 基变

git rebase team/feature/v3.7.0

git rebase --continue

git rebase -i cea405e6f 

### 强推

git push origin feature/v3.7.0 -f

git reflog

git cherry-pick a89dbd17f