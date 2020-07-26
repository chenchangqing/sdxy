gitbook build
git checkout master
git add .
git commit -m 'build'
git push -u origin master
git checkout gh-pages
git pull origin gh-pages
#rm -rf !(_book|node_modules)
cp -r _book/* .
git add .
git commit -m 'build'
git push -u origin gh-pages
rm -r -f _book
git checkout master
echo "提交OK"
