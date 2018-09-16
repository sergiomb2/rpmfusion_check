# rpmfusion_check

- runme.sh (check is repos, mirrors and package are updated as expect)
- runme2.sh (check packages added and retired in repos)

- In rpmfusion_check.src.phase3.py we got some others options like check git commits via cgit web atom and use of rfpkg clone

- query all repos in rpmfusion via cgit:

     `./rpmfusion_check.cgit.py  | grep /tree/ | sed -e 's/.*free\///; s/\.git.*//' > rpmfusion_link_list.txt
     ./rpmfusion_check.cgit2.py`
