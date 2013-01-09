#!/bin/bash


#Globals
#=========================================
NodesList=""
hostname=`hostname`


#Get the name of the computing nodes
#==========================================
function ComputingNodes ( )
{
	qhost | awk 'NR > 3' > trim_macs2.txt
 	NodesList=`cut -d ' ' --fields=1 trim_macs2.txt`
}


#Copy the installer over to the shared drive
#===========================================
function CopyInstaller ( )
{
	sudo cp bin/macs2_deploy.sh /mnt/galaxyData/tmp
}


#Execute the script on computing node
#===========================================
function Execute ( )
{
	#process the nodes 
	if [[ "$1" == dom* ]]; 
	then
		1="$1.compute-1.internal"
		#echo "Installing dependencies on $1. It may take a few minutes ..."
		sudo ssh $1 -o "StrictHostKeyChecking no" "bash -s" < /mnt/galaxyData/tmp/macs2_deploy_Ajen.sh
	elif [[ "$1" == "$hostname" ]]; then
		#echo "Installing dependencies on $1. It may take a few minutes ..."
		bash /mnt/galaxyData/tmp/macs2_deploy_Ajen.sh
	else
		#echo "Installing dependencies on $1. It may take a few minutes ..."
		sudo ssh $1 -o "StrictHostKeyChecking no" "bash -s" < /mnt/galaxyData/tmp/macs2_deploy_Ajen.sh
	fi 
}



#Function Calls
#============================================
ComputingNodes
CopyInstaller

#Calling Execution function. 
#All the dependencies will be installed on computing nodes at the same time.
for nodes in $NodesList; do
	Execute ${nodes} &
done

#Wait till the process to finish in parallel 
wait

echo "Done: All dependencies have been installed on computing nodes. You can start analizing your data ..."

