*** Settings ***
Documentation    Build taco cluster for a lab.
Suite Setup      Preflight
Suite Teardown   Cleanup
Library         OperatingSystem
Library         Process
Library         SSHLibrary
Variables       props.py

*** Variables ***
${TMPL}      CentOS-${VER}-${ARCH}-GenericCloud.qcow2

*** Tasks ***
Test
	[Tags]		test
	FOR		${vm}	IN	@{VMS}
		Log		${ID} 	console=True
		${ID} =		Evaluate	${ID} + 1
	END

Check Template 
	[Documentation]		Check a template VM and Build it if necessary
	[Tags]		template
	Log		Check if ${TMPL} exists.	console=True
	Run Keyword If	os.path.exists("${IMG_DIR}/${TMPL}") == False
	...		Build Template

Create Taco Lab
	[Documentation]		Create and start VM for TACO Lab.
	[Tags]		create

	FOR		${vm}	IN	@{VMS}
		Log		${vm}: Clone from ${TMPL}.	console=True
		${rc} =		Run And Return Rc
		...		sudo qm clone ${TMPL_ID} ${ID} -name ${vm} -pool ${POOL}
		Should Be Equal As Integers		${rc}	0

		Log		${vm}: Set config.	console=True
		${rc} =		Run And Return Rc
		...		sudo qm set ${ID} -memory ${MEMORY} -cores ${CORES} -sshkeys ${SSHKEY}.pub -cpu cputype=host -ipconfig0 ip=${IPS}[${vm}][0]/24,gw=${GW} -ipconfig1 ip=${IPS}[${vm}][1]/24 -nameserver ${NAMESERVER}
		Should Be Equal As Integers		${rc}	0

		Log		${vm}: Resize disk to ${RESIZE}G.	console=True
		${rc} =		Run And Return Rc
		...		sudo qm resize ${ID} scsi0 ${RESIZE}G
		Should Be Equal As Integers		${rc}	0

		Log		${vm}: Get disk path to resize the partition.	console=True
		${rc}	${disk_path} =		Run And Return Rc And Output
		...		sudo pvesm path ${STORAGE}:vm-${ID}-disk-1
		Should Be Equal As Integers		${rc}	0

		Log		${vm}: Resize the root partition to 100%.	console=True
		${rc} =		Run And Return Rc
		...		sudo parted ${disk_path} resizepart 1 100%
		Should Be Equal As Integers		${rc}	0

		Log		${vm}: Delete device map.	console=True
		${rc} =		Run And Return Rc
		...		sudo kpartx -dv ${disk_path}
		Should Be Equal As Integers		${rc}	0

		Log		${vm}: Add osd disks if the VM role is storage.	console=True
		Run Keyword If	'storage' in ${ROLES}[${vm}]
		...		Create OSD Disks	${vm}	${ID}

		Log		${vm}: Start the VM.	console=True
		${rc} =		Run And Return Rc
		...		sudo qm start ${ID}
		Should Be Equal As Integers		${rc}	0

		Log		${vm}: Add VM IP in /etc/hosts.	console=True
		${rc} =		Run And Return Rc
		...		grep -q "${IPS}[${vm}][0].*${vm}" /etc/hosts
		Run Keyword If	${rc} != 0		Run 
		...		echo "${IPS}[${vm}][0] ${vm}"|sudo tee -a /etc/hosts

		${ID} =		Evaluate	${ID} + 1
	END

Landing
	[Documentation]		Set up VM for TACO Lab.
	[Tags]		setup

	FOR		${vm}	IN	@{VMS}
		Open Connection		${vm}
		Login With Public Key	${UID}	${SSHKEY}.pub

		Log		${vm}: Remove cloud-init package.	console=True
		${output} =		Execute Command		sudo yum remove cloud-init

		Log		${vm}: Set timezone.	console=True
		${output} =		Execute Command		sudo timedatectl set-timezone ${TIMEZONE}

		Close Connection
	END

*** Keywords ***
Preflight
    Comment     Run before Tasks.
	${rc} =		Run And Return Rc	ls -ld ${IMG_DIR}
	Run Keyword If	${rc} != 0		Create Directory	${IMG_DIR}
	${rc} =		Run And Return Rc	ls ${SSHKEY}
	Run Keyword If	${rc} != 0		Run		ssh-keygen -t rsa -N '' -f ${SSHKEY}

Cleanup
    Comment     Clean up the debris.
    Log     Remove temporary files.

Build Template
	Log		Get an image from ${IMG_URL}/${TMPL}.	console=True
	${rc} =		Run And Return Rc
	...		wget -qO ${IMG_DIR}/${TMPL}.xz ${IMG_URL}/${TMPL}.xz
	Should Be Equal As Integers		${rc}	0
	
	Log		Uncompress the image.	console=True
	${rc} =		Run And Return Rc
	...		xz --decompress ${IMG_DIR}/${TMPL}.xz
	Should Be Equal As Integers		${rc}	0

	Log		Create a VM.	console=True
	${rc} =		Run And Return Rc
	...		sudo qm create ${TMPL_ID} -name ${TMPL_NAME} -pool ${POOL} -memory 16 -net0 virtio,bridge=${VMBR0} -net1 virtio,bridge=${VMBR1}
	Should Be Equal As Integers		${rc}	0

	Log		Import the downloaded image into a VM.	console=True
	${rc} =		Run And Return Rc
	...		sudo qm importdisk ${TMPL_ID} ${IMG_DIR}/${TMPL} ${STORAGE}
	Should Be Equal As Integers		${rc}	0

	Log		Set up configuration for a VM.		console=True
	${rc} =		Run And Return Rc
	...		sudo qm set ${TMPL_ID} -scsihw virtio-scsi-pci -scsi0 ${STORAGE}:vm-${TMPL_ID}-disk-1 -ide2 ${STORAGE}:cloudinit -boot c -bootdisk scsi0 -serial0 socket -vga serial0
	Should Be Equal As Integers		${rc}	0

	Log		Make VM a template.		console=True
	${rc} =		Run And Return Rc
	...		sudo qm template ${TMPL_ID}
	Should Be Equal As Integers		${rc}	0

Create OSD Disks
	[Arguments]		${vm}	${id}
	${end} =	Evaluate	${OSD_NUM} + 1
	FOR		${index}	IN RANGE	1	${end}
		${diskid} =		Evaluate	${index} + 1
		${rc} =		Run And Return Rc
		...		sudo lvcreate -V ${OSD_SIZE}G -n vm-${id}-disk-${diskid} --thinpool ${THINPOOL}
		Should Be Equal As Integers		${rc}	0

		${rc} =		Run And Return Rc
		...		sudo qm set ${id} -scsihw virtio-scsi-pci -scsi${index} ${STORAGE}:vm-${id}-disk-${diskid}
		Should Be Equal As Integers		${rc}	0
	END

