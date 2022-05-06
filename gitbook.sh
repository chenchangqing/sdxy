if [ "$*" ]
then
    git add .
	git commit -m "$*"
	git push -u origin develop
else
    git add .
	git commit -m 'no comment'
	git push -u origin develop
fi

git checkout master
git fetch origin
git rebase origin/develop
git push -u origin master
gitbook build
git checkout gh-pages
git pull origin gh-pages
rm -rf !(_book|.git|.gitignore|ignore|node_modules)
cp -r _book/* .
git add .
git commit -m 'build gh-pages'
git push -u origin gh-pages
rm -r -f _book
git chekout develop
echo "提交OK"