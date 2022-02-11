rawhide=36
koji-rpmfusion latest-pkg --all f${rawhide}-free > f${rawhide}_free
koji-rpmfusion latest-pkg --all f${rawhide}-nonfree > f${rawhide}_nonfree
dnf repoquery --disablerepo='*' --enablerepo=rpmfusion-free-rawhide --srpm | sort | grep src$ | sed 's/\(-[^-]\+\)\{2\}$//' | uniq > f${rawhide}_repofree.txt
dnf repoquery --disablerepo='*' --enablerepo=rpmfusion-nonfree-rawhide --srpm | sort | grep src$ | sed 's/\(-[^-]\+\)\{2\}$//' | uniq > f${rawhide}_repononfree.txt
cat f${rawhide}_free | sed 's/\(-[^-]\+\)\{2\} .*//' | sort > f${rawhide}_free2
cat f${rawhide}_nonfree | sed 's/\(-[^-]\+\)\{2\} .*//' | sort > f${rawhide}_nonfree2
diff f${rawhide}_free2 f${rawhide}_repofree.txt -up | vi -R -
diff f${rawhide}_nonfree2 f${rawhide}_repononfree.txt -up | vi -R -

