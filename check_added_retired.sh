# Edit rpmfusion_check.src.phase1.sh and rpmfusion_check.src.phase2.sh
# to customize the report

./rpmfusion_check.src.phase1.sh
./rpmfusion_check.src.phase2.sh

# In rpmfusion_check.src.phase3.py we got some others options like check git commits via cgit web atom
# and use of rfpkg clone
./rpmfusion_check.src.phase3.py > all_packages_added_and_retired.txt

