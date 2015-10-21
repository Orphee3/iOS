NORM="\033[0m"
GREEN="\033[32m"
DOCPATH="/Users/$USER/Desktop/orpheeDoc"
SRCPATH="/Users/$USER/Desktop/Orphee"

echo -e "generating documentation for module: MIDIToolbox...\n"
jazzy -o $DOCPATH/miditools -c -a "Massil Yataghene, Jeromin Lebon" -g https://github.com/Orphee3/iOS -x -workspace,Orphee.xcworkspace/,-scheme,MIDIToolbox --min-acl internal -e $SRCPATH/MIDIToolbox/ByteBuffer.swift,$SRCPATH/MIDIToolbox/ByteOrder.swift;
echo -e "\t\t\t\t$GREEN OK $NORM"
echo -e "generating documentation for module: FileManagement...\n"
jazzy -o $DOCPATH/filemgt -c -a "Massil Yataghene, Jeromin Lebon" -g https://github.com/Orphee3/iOS -x -workspace,Orphee.xcworkspace/,-scheme,FileManagement --min-acl internal
echo -e "\t\t\t\t$GREEN OK $NORM"
echo -e "generating documentation for module: Orphee...\n"
jazzy -o $DOCPATH/orphee -c -a "Massil Yataghene, Jeromin Lebon" -g https://github.com/Orphee3/iOS -x -workspace,Orphee.xcworkspace/,-scheme,Orphee --min-acl internal;
echo -e "\t\t\t\t$GREEN OK $NORM"
