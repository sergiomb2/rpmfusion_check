# Edit rpmfusion_check.src.phase1.sh to customize the report

./rpmfusion_check.src.phase1.sh

# In rpmfusion_check.src.phase3.py we got some others options like check git commits via cgit web atom
# and use of rfpkg clone
pushd results
../rpmfusion_check.src.phase3.py > all_packages_added_and_retired.txt
tac all_packages_added_and_retired.txt > all_packages_added_and_retired.tac.txt
popd
