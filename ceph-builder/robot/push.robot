*** Settings ***
Documentation    Push ceph debian packages to iorchard mirror machine.
Suite Setup      Preflight
Suite Teardown   Cleanup
Library         OperatingSystem
Library         SSHLibrary
Variables       props.py

*** Tasks ***
Get Env
    [Tags]      test
    ${envs} =   Get Environment Variables
    #Log         ${envs}     console=True

Push To Local Mirror
    [Documentation]     Push ceph debian packages to the local mirror.
    Log         Scping deb files to ${REPO_DIR}     console=True
    Put File    ${DPKG_DIR}/*.deb  ${REPO_DIR}  mode=0644

    Log         Aptly repo add.     console=True
    ${rc} =     Execute Command
    ...     aptly repo add ${REPO_NAME} ${REPO_DIR}/*.deb
    ...     return_stdout=False     return_rc=True
    Should Be Equal     ${rc}       ${0}
    
*** Keywords ***
Preflight
    Get Environment Variable    REPO_PW
    Open Connection     ${REPO_SERVER}
    Login               ${REPO_UID}     %{REPO_PW}

Cleanup
    [Documentation]     Clean up the debris.
    Close Connection
    Remove Directory    ${DPKG_DIR}     recursive=True
