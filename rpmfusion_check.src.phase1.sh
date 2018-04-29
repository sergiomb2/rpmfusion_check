versions=$(seq 8 27)
versions=$(seq 26 28)
rawhide=29
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
#dnf repoquery --releasever=27 --arch=src --disablerepo='*' \
#    --enablerepo=rpmfusion-{non,}free --available --quiet --qf "%{name} %{repoid}" | \
#    sed 's|\(-[^-]\+\)\{2\||' | sort | uniq > rpmfusion_26.txt

echo repoquery rawhide
dnf repoquery $refresh --arch=src --disablerepo='*' --enablerepo=rpmfusion-{non,}free-rawhide-source \
--available --quiet --qf "%{name} %{repoid}" | \
sed 's|\(-[^-]\+\)\{2\}.src||; s| rpmfusion-free.*| rpmfusion-free|; s| rpmfusion-nonfree.*| rpmfusion-nonfree|' | sort |
uniq > rpmfusion_$rawhide.txt

