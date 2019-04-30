*** Settings ***
Documentation    Build ceph debian packages on debian stretch machine.
Suite Setup      Preflight
Suite Teardown   Cleanup
Library         OperatingSystem
Variables       props.py

*** Tasks ***
Test
    [Tags]    test
    ${vm} =     Set Variable    ceph1 
    ${rc} =     Run And Return Rc     echo ${vm}|grep -q admin
    Log     is vm admin: ${vm} ${rc}      console=True

Set Up Ceph Lab
    [Documentation]     Set up virtual machines for ceph lab.
    [Tags]    real
    FOR     ${vm}   IN  @{VMS}
        Log     Copy ${SRC_IMG} to ${DST_DIR}/${vm}.qcow2     console=True
        ${rc} =    Run And Return Rc    cp ${SRC_IMG} ${DST_DIR}/${vm}.qcow2
        Should Be Equal As Integers     ${rc}   0
        ${rc}   ${uuid} =   Run And Return Rc And Output
        ...     cat /proc/sys/kernel/random/uuid
        ${rc}   ${mac1} =    Run And Return Rc And Output
        ...     /data/kvm/scripts/macgen.sh
        ${rc}   ${mac2} =    Run And Return Rc And Output
        ...     /data/kvm/scripts/macgen.sh
        Create Interfaces File      ${IPS}[${vm}]
        Log     Run ${VM_MAN}     console=True
        ${rc} =     Run And Return Rc
        ...     ${VM_MAN} -f ${DST_DIR}/${vm}.qcow2
        Log     Create XML for ${vm}    console=True
        ${rc} =     Run And Return Rc     echo ${vm}|grep -q admin
        Run Keyword If  ${rc} == 0
        ...     Create XML  ${vm}   ${uuid}    ${mac1}   ${mac2}   admin.tpl
        ...     ELSE    
        ...     Create XML  ${vm}   ${uuid}    ${mac1}   ${mac2}   osd.tpl
        Log     Define VM     console=True
        ${rc} =     Run And Return Rc
        ...     virsh define /tmp/xml
        Should Be Equal As Integers     ${rc}   0
    END

*** Keywords ***
Preflight
    Comment     Run before Tasks.

Cleanup
    Comment     Clean up the debris.

Create Interfaces File
    [Arguments]     ${ips}
    ${rc} =     Run And Return Rc
    ...     sed -e 's/IP1/${ips}[0]/' -e 's/IP2/${ips}[1]/' data/interfaces.tpl > /tmp/interfaces

Create XML
    [Arguments]     ${vm}   ${uuid}     ${mac1}     ${mac2}     ${tpl}
    ${rc} =     Run And Return Rc
    ...     sed 's/NAME/${vm}/; s/UUID/${uuid}/; s/MAC1/${mac1}/; s/MAC2/${mac2}/' data/${tpl} > /tmp/xml
