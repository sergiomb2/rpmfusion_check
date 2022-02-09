allversions=$(seq 8 35)
versions=$(seq 33 35)
branched=""
rawhide=36
do_rawhide=""
#refresh="--refresh --forcearch=i686"
#refresh="--refresh"
refresh=
repo="-source"
#repo=
workdir="results"

pushd $workdir
for version in $versions ; do
    echo repoquery $(printf %02d $version)
    dnf repoquery $refresh --releasever=$version --disablerepo='*' \
        --enablerepo=rpmfusion-{,non}free{,-updates,-updates-testing,-tainted}$repo \
        --available --quiet --qf "%{name} %{repoid}" | \
        sed "s| rpmfusion-free.*| rpmfusion-free|; s| rpmfusion-nonfree.*| rpmfusion-nonfree|" | \
        sort | uniq > rpmfusion_$(printf %02d $version).txt
done
# branched

if [ -z $branched ]
then
echo "no branched repo"
else
for version in $branched ; do
    echo repoquery branched $(printf %02d $version)
    dnf repoquery $refresh --releasever=$version --disablerepo='*' \
        --enablerepo=rpmfusion-{,non}free{,-updates-testing-tainted}$repo --available --quiet --qf "%{name} %{repoid}" | \
        sed "s| rpmfusion-free.*| rpmfusion-free|; s| rpmfusion-nonfree.*| rpmfusion-nonfree|" | \
        sort | uniq > rpmfusion_$(printf %02d $version).txt
done
fi

if [ -z $do_rawhide ]
then
echo "no rawhide workaround tained repo"
rm rpmfusion_$rawhide.txt
else
echo repoquery rawhide
dnf repoquery $refresh --disablerepo='*' --enablerepo=rpmfusion-{non,}free-rawhide$repo \
--available --quiet --qf "%{name} %{repoid}" | \
sed "s| rpmfusion-free.*| rpmfusion-free|; s| rpmfusion-nonfree.*| rpmfusion-nonfree|" | \
 sort | uniq > rpmfusion_$rawhide.txt
fi

echo "phase 2"
#clear rpmfusion_all.txt
rm -f rpmfusion_all.txt
rm -f rpmfusion_all_sorted.txt
rm -f rpmfusion_all_all.txt

for n0 in $allversions ; do
    n1=$((n0+1))
    n0=$(printf %02d $n0)
    n1=$(printf %02d $n1)
    echo "diff rpmfusion_${n0}.txt rpmfusion_${n1}.txt >> rpmfusion_all.txt"
    diff rpmfusion_${n0}.txt rpmfusion_${n1}.txt -up | tail -n+3 | grep -P "^[+|-]" | \
        sort -k1.2,1 -k2,2 | sed "s|$| ${n0}_${n1}|" >> rpmfusion_all.txt
    # sort -k2,2 -k1.2,1 (sort by repo)
    #${n0}_${n1}.diff
    #echo "${n0}_${n1}.diff >> rpmfusion_all.txt"
    #cat ${n0}_${n1}.diff >> rpmfusion_all.txt
done
#sort --key=1.2,1.2 rpmfusion_all.txt > rpmfusion_all_sorted.txt
popd
cat $workdir/rpmfusion_[0-9][0-9].txt | sort | uniq > rpmfusion_all_all.txt
