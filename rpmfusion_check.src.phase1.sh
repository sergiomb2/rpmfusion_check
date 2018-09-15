versions=$(seq 8 27)
versions=$(seq 26 28)
branches=29
rawhide=30
refresh="--refresh"
repo="-source"
pac=src
#repo=
#pac=x86_64.rpm

for version in $versions ; do
    echo repoquery $(printf %02d $version)
    dnf repoquery $refresh --releasever=$version --disablerepo='*' \
        --enablerepo=rpmfusion-{,non}free{,-updates,-updates-testing}$repo \
        --available --quiet --qf "%{name} %{repoid}" | \
        sed "s|\(-[^-]\+\)\{2\}.$pac||; s| rpmfusion-free.*| rpmfusion-free|; s| rpmfusion-nonfree.*| rpmfusion-nonfree|" | \
        sort | uniq > rpmfusion_$(printf %02d $version).txt
done
# branched
for version in $branches ; do
    echo repoquery branched $(printf %02d $version)
    dnf repoquery $refresh --releasever=$version --disablerepo='*' \
        --enablerepo=rpmfusion-{,non}free{,-updates-testing}$repo --available --quiet --qf "%{name} %{repoid}" | \
        sed "s|\(-[^-]\+\)\{2\}.$pac||; s| rpmfusion-free.*| rpmfusion-free|; s| rpmfusion-nonfree.*| rpmfusion-nonfree|" | \
        sort | uniq > rpmfusion_$(printf %02d $version).txt
done

echo repoquery rawhide
dnf repoquery $refresh --disablerepo='*' --enablerepo=rpmfusion-{non,}free-rawhide$repo \
--available --quiet --qf "%{name} %{repoid}" | \
sed "s|\(-[^-]\+\)\{2\}.$pac||; s| rpmfusion-free.*| rpmfusion-free|; s| rpmfusion-nonfree.*| rpmfusion-nonfree|" | \
 sort | uniq > rpmfusion_$rawhide.txt

