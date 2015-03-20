NORM="\033[0m"
GREEN="\033[32m"

echo -e "generating documentation...\n"
jazzy -c -a "Massil Yataghene, Jeromin Lebon" -g https://github.com/Orphee3/iOS -x -workspace,Orphee.xcworkspace/,-scheme,Orphee;
echo -e "\t\t\t\t$GREEN OK $NORM"

echo -en "\ncopying documentation...\t"
cp -rf docs/* ~/Desktop/orpheeDoc;
echo -e "$GREEN OK $NORM"

echo -ne "cleaning...\t\t\t"
rm -rf build docs;
echo -e "$GREEN OK $NORM\n"