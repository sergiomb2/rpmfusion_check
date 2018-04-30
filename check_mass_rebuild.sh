koji-rpmfusion latest-pkg --all f28-free > f28_free
koji-rpmfusion latest-pkg --all f28-nonfree > f28_nonfree
dnf repoquery --disablerepo='*' --enablerepo=rpmfusion-free-rawhide --srpm | sort | grep src$ | sed 's/\(-[^-]\+\)\{2\}$//' | uniq > f28_repofree.txt
dnf repoquery --disablerepo='*' --enablerepo=rpmfusion-nonfree-rawhide --srpm | sort | grep src$ | sed 's/\(-[^-]\+\)\{2\}$//' | uniq > f28_repononfree.txt
cat f28_free | sed 's/\(-[^-]\+\)\{2\} .*//' | sort > f28_free2
cat f28_nonfree | sed 's/\(-[^-]\+\)\{2\} .*//' | sort > f28_nonfree2
diff f28_free2 f28_repofree.txt -up | vir
diff f28_nonfree2 f28_repononfree.txt -up | vir

