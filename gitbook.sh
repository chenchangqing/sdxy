if [ ! -n "$0" ] ;then
    git add .
	git commit -m 'no comment'
	git push -u origin develop
else
	git add .
	git commit -m '$0'
	git push -u origin develop
fi

# git checkout master
# git fetch origin
# git rebase origin/develop
# git push -u origin master
# gitbook build
# git checkout gh-pages
# git pull origin gh-pages
# rm -rf !(_book|.git|.gitignore|ignore|node_modules)
# cp -r _book/* .
# git add .
# git commit -m 'build gh-pages'
# git push -u origin gh-pages
# rm -r -f _book
# echo "提交OK"