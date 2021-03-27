versions=$(seq 8 28)
versions=$(seq 28 33)
branched=34
rawhide=35
#refresh="--refresh --forcearch=i686"
#refresh="--refresh"
refresh=
repo="-source"
#repo=

for version in $versions ; do
    echo repoquery $(printf %02d $version)
    dnf repoquery $refresh --releasever=$version --disablerepo='*' \
        --enablerepo=rpmfusion-{,non}free{,-updates,-updates-testing}$repo \
        --available --quiet --qf "%{name} %{repoid}" | \
        sed "s| rpmfusion-free.*| rpmfusion-free|; s| rpmfusion-nonfree.*| rpmfusion-nonfree|" | \
        sort | uniq > rpmfusion_$(printf %02d $version).txt
done
# branched
for version in $branched ; do
    echo repoquery branched $(printf %02d $version)
    dnf repoquery $refresh --releasever=$version --disablerepo='*' \
        --enablerepo=rpmfusion-{,non}free{,-updates-testing}$repo --available --quiet --qf "%{name} %{repoid}" | \
        sed "s| rpmfusion-free.*| rpmfusion-free|; s| rpmfusion-nonfree.*| rpmfusion-nonfree|" | \
        sort | uniq > rpmfusion_$(printf %02d $version).txt
done

echo repoquery rawhide
dnf repoquery $refresh --disablerepo='*' --enablerepo=rpmfusion-{non,}free-rawhide$repo \
--available --quiet --qf "%{name} %{repoid}" | \
sed "s| rpmfusion-free.*| rpmfusion-free|; s| rpmfusion-nonfree.*| rpmfusion-nonfree|" | \
 sort | uniq > rpmfusion_$rawhide.txt

