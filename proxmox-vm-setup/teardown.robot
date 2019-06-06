*** Settings ***
Documentation    Tear down VMs for a lab.
Suite Setup      Preflight
Suite Teardown   Cleanup
Library         OperatingSystem
Library         Process
Variables       props.py

*** Tasks ***
Tear Down Taco Lab
    [Documentation]        Tear down VMs for a Lab.
    [Tags]        teardown

    FOR        ${index}    IN    @{VMS}
        Log        ${ID}: Stop the VM.        console=True
        Run     sudo qm stop ${ID}
        Wait Until Keyword Succeeds        60s        10s
		...		Check VM state    ${ID}
        Log        ${ID}: Destroy the VM.    console=True
        ${rc} =        Run And Return Rc    sudo qm destroy ${ID}
        Should Be Equal As Integers        ${rc}    0

        ${ID} =        Evaluate    ${ID} + 1
    END

*** Keywords ***
Preflight
    Comment     Run before Tasks.

Cleanup
    Comment     Clean up the debris.
    Log     Remove temporary files.

Check VM State
    [Arguments]        ${id}
    ${rc}    ${o} =        Run And Return Rc And Output    sudo qm status ${id}
    Run Keyword If    ${rc} == 0        Should Contain    ${o}    stopped
