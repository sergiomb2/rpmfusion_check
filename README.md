# rpmfusion_check

- runme_added_retired.sh (check packages added and retired in rpmfusion repos) , principal results are  
  https://raw.githubusercontent.com/sergiomb2/rpmfusion_check/master/results/all_packages_added_and_retired.tac.txt and 
  https://raw.githubusercontent.com/sergiomb2/rpmfusion_check/master/results/all_packages_added_and_retired.txt 

- In rpmfusion_check.src.phase3.py we got some others options like check git commits via cgit web, atom and use of rfpkg clone

- runme.sh (check is repos, mirrors and package are updated as expect) is more or less obsolete
 
- query all repos in rpmfusion via cgit:
```
./rpmfusion_check.cgit.py  | grep /tree/ | sed -e 's/.*free\///; s/\.git.*//' > rpmfusion_link_list.txt 
./rpmfusion_check.cgit2.py
```
