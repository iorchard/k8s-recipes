*** Settings ***
Documentation    Tear down ceph cluster on a lab.
Suite Setup      Preflight
Suite Teardown   Cleanup
Library         OperatingSystem
Library         Process
Variables       props.py

*** Tasks ***
Tear Down Ceph Lab
    [Documentation]     Tear down virtual machines for ceph lab.
    [Tags]    teardown
    FOR     ${vm}   IN  @{VMS}
        Log     Stop ${vm} and wait for at most 60 seconds.     console=True
        Run     virsh shutdown ${vm}
        Wait Until Keyword Succeeds     60s     5s  Check VM State  ${vm}

        Log     Undefine ${vm}     console=True
        Run     virsh undefine ${vm}
        
        Log     Remove ${vm}     console=True
        Remove File     ${DST_DIR}/${vm}.qcow2
        Run Keyword If  "${ROLES}[${vm}]" == "worker"
        ...     Remove File   ${DST_DIR}/${vm}-*.qcow2
    END

*** Keywords ***
Preflight
    Comment     Run before Tasks.

Cleanup
    Comment     Clean up the debris.

Check VM State
    [Arguments]     ${v}
    ${o} =      Run     virsh domstate ${v}
    Should Contain      ${o}    shut

