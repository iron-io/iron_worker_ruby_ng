To sync examples with repo:
1. install git@github.com:apenwarr/git-subtree.git
2. split ng examples into separate branch 
```
git clone git@github.com:iron-io/iron_worker_examples.git iw_examples
cd iw_examples
git subtree split --prefix ruby_ng --annotate="(split)" -b ruby_ng_split
cd -
```
3. merge them into iron_worker_ng subtree
```
git clone git@github.com:iron-io/iron_worker_ruby_ng.git iw
cd iw
git remote add iw_examples ../iw_examples
git fetch iw_examples
git subtree merge -P examples --squash iw_examples/ruby_ng_split -m 'Updating examples subtree'
git push origin master
cd -
```