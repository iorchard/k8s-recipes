*** Settings ***
Documentation    Build ceph cluster for a lab.
Suite Setup      Preflight
Suite Teardown   Cleanup
Library         OperatingSystem
Library         Process
Variables       props.py

*** Variables ***
${DEB_IMG}      debian-${DEB_VER}-openstack-${DEB_ARCH}.qcow2
${VM_MAN}       ${CURDIR}/scripts/vm_man.sh

*** Tasks ***
Test
    [Tags]    test
    ${vm} =     Set Variable    ceph1 
    ${rc} =     Run And Return Rc     echo ${vm}|grep -q admin
    Run Keyword If  os.path.exists("${SRC_DIR}/${DEB_IMG}") == False  Log     Not exists    console=True

Get And Verify Debian Image
    [Documentation]     Get debian openstack image.
    [Tags]  getimg
    Log     Get debian image from ${DEB_IMG_URL}/   console=True
    ${rc} =   Run Keyword If  os.path.exists("${SRC_DIR}/${DEB_IMG}") == False
    ...     Run And Return Rc
    ...     wget -qO ${SRC_DIR}/${DEB_IMG} ${DEB_IMG_URL}/${DEB_IMG}
    ${rc} =     Run And Return Rc
    ...     wget -qO ${SRC_DIR}/SHA256SUMS ${DEB_IMG_URL}/SHA256SUMS
    Should Be Equal As Integers     ${rc}   0
    ...     msg="Fail to get SHA256SUMS."
    ${rc} =     Run And Return Rc
    ...     wget -qO ${SRC_DIR}/SHA256SUMS.sign ${DEB_IMG_URL}/SHA256SUMS.sign
    Should Be Equal As Integers     ${rc}   0
    ...     msg="Fail to get SHA256SUMS.sign."

    Log     Verify SHA checksum with signature.   console=True
    ${rc} =     Run And Return Rc
    ...     gpg --verify ${SRC_DIR}/SHA256SUMS.sign ${SRC_DIR}/SHA256SUMS
    Should Be Equal As Integers     ${rc}   0
    ...     msg="Fail to verify GPG SHA256SUMS."

    Log     Verify debian image with SHA checksum.   console=True
    ${result} =     Run Process
    ...     grep ${DEB_IMG}\$ ${SRC_DIR}/SHA256SUMS|sha256sum --check --quiet -
    ...     shell=yes   cwd=${SRC_DIR}
    Run Keyword If  ${result.rc} != 0   Remove File     ${SRC_DIR}/${DEB_IMG}
    Should Be Equal As Integers     ${result.rc}   0
    ...     msg="Fail to verify SHA checksum for ${DEB_IMG}."

Set Up Ceph Lab
    [Documentation]     Set up virtual machines for ceph lab.
    [Tags]    setup
    FOR     ${vm}   IN  @{VMS}
        Log     Copy ${SRC_DIR}/${DEB_IMG} to ${DST_DIR}/${vm}.qcow2     
        ...     console=True
        Copy File   ${SRC_DIR}/${DEB_IMG}   ${DST_DIR}/${vm}.qcow2
        ${rc}   ${uuid} =   Run And Return Rc And Output
        ...     cat /proc/sys/kernel/random/uuid
        ${rc}   ${mac1} =    Run And Return Rc And Output
        ...     /data/kvm/scripts/macgen.sh
        ${rc}   ${mac2} =    Run And Return Rc And Output
        ...     /data/kvm/scripts/macgen.sh
        Create Interfaces File      ${IPS}[${vm}]

        Log     Run ${VM_MAN}     console=True
        ${rc} =     Run And Return Rc
        ...     ${VM_MAN} -f ${DST_DIR}/${vm}.qcow2 -u ${USERID}
        Should Be Equal As Integers     ${rc}   0   msg="vm_man failed."

        Log     Create XML for ${vm}    console=True
        Run Keyword If  "${ROLES}[${vm}]" != "worker"
        ...     Create XML  ${vm}   ${uuid}    ${mac1}   ${mac2}   admin.tpl
        ...     ELSE
        ...     Create XML  ${vm}   ${uuid}    ${mac1}   ${mac2}   osd.tpl

        Log     Define VM     console=True
        ${rc} =     Run And Return Rc
        ...     virsh define ${TEMPDIR}/xml
        Should Be Equal As Integers     ${rc}   0
    END

Start Ceph Lab
    [Documentation]     Start virtual machines for ceph lab.
    [Tags]    start
    FOR     ${vm}   IN  @{VMS}
        Log     Start ${vm}     console=True
        ${rc} =     Run And Return Rc     virsh start ${vm}
        Should Be Equal As Integers     ${rc}   0
    END

*** Keywords ***
Preflight
    Comment     Run before Tasks.
    Log     Set up GPG keyring      console=True
    ${rc} =     Run And Return Rc
    ...     gpg --list-keys ${DEB_KEYID} || gpg --keyserver ${DEB_KEYSERVER} --recv-keys ${DEB_KEYID}
    Should Be Equal As Integers     ${rc}   0

Cleanup
    Comment     Clean up the debris.
    Log     Remove temporary files.
    Remove File     ${SRC_DIR}/SHA256SUM*
    Remove Files     ${TEMPDIR}/xml     ${TEMPDIR}/interfaces

Create Interfaces File
    [Arguments]     ${ips}
    ${rc} =     Run And Return Rc
    ...     sed -e 's/IP1/${ips}[0]/' -e 's/IP2/${ips}[1]/' data/interfaces.tpl > ${TEMPDIR}/interfaces
    Should Be Equal As Integers     ${rc}   0

Create XML
    [Documentation]     Create XML.
    [Arguments]     ${vm}   ${uuid}     ${mac1}     ${mac2}     ${tpl}
    ${rc} =     Run And Return Rc
    ...     sed 's/NAME/${vm}/; s/UUID/${uuid}/; s/MAC1/${mac1}/; s/MAC2/${mac2}/' data/${tpl} > ${TEMPDIR}/xml
    Should Be Equal As Integers     ${rc}   0

    Run Keyword If      '${tpl}' == 'osd.tpl'   Create OSD Disks    ${vm}

Create OSD Disks
    [Documentation]     Create OSD disks.
    [Arguments]     ${vm}

    FOR     ${drv}  IN      b   c   d   e   f
        ${rc} =     Run And Return Rc
        ...     qemu-img create -f qcow2 ${DST_DIR}/${vm}-${drv}.qcow2 ${SIZE}G
        Should Be Equal As Integers     ${rc}   0
    END
