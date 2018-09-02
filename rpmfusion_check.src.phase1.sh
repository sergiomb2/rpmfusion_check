versions=$(seq 8 27)
versions=$(seq 24 28)
rawhide=30
#refresh="--refresh"

for version in $versions ; do
    echo repoquery $(printf %02d $version)
    dnf repoquery $refresh --releasever=$version --arch=src --disablerepo='*' \
        --enablerepo=rpmfusion-{,non}free{,-updates,-updates-testing}-source \
        --available --quiet --qf "%{name} %{repoid}" | \
        sed 's|\(-[^-]\+\)\{2\}.src||; s| rpmfusion-free.*| rpmfusion-free|; s| rpmfusion-nonfree.*| rpmfusion-nonfree|' | \
        sort | uniq > rpmfusion_$(printf %02d $version).txt
done
# branched
version=29
echo repoquery $(printf %02d $version)
dnf repoquery $refresh --releasever=$version --arch=src --disablerepo='*' \
    --enablerepo=rpmfusion-{,non}free{,-updates-testing}-source --available --quiet --qf "%{name} %{repoid}" | \
    sed 's|\(-[^-]\+\)\{2\}.src||; s| rpmfusion-free.*| rpmfusion-free|; s| rpmfusion-nonfree.*| rpmfusion-nonfree|' | \
    sort | uniq > rpmfusion_$(printf %02d $version).txt

echo repoquery rawhide
dnf repoquery $refresh --arch=src --disablerepo='*' --enablerepo=rpmfusion-{non,}free-rawhide-source \
--available --quiet --qf "%{name} %{repoid}" | \
sed 's|\(-[^-]\+\)\{2\}.src||; s| rpmfusion-free.*| rpmfusion-free|; s| rpmfusion-nonfree.*| rpmfusion-nonfree|' | sort |
uniq > rpmfusion_$rawhide.txt

