*** Settings ***
Documentation    Update iorchard mirror.
Suite Setup      Preflight
Suite Teardown   Cleanup
Library         OperatingSystem
Library         SSHLibrary
Variables       props.py

*** Tasks ***
Update Local Mirror
    [Documentation]     Update the local mirror.

    Log     Create snapshots of mirrors and a repo.    console=True
    ${rc} =     Execute Command
    ...     aptly snapshot create debian9-${DATETIME} from mirror debian9
    ...     return_stdout=False     return_rc=True
    Should Be Equal     ${rc}       ${0}
    ${rc} =     Execute Command
    ...     aptly snapshot create debian9-updates-${DATETIME} from mirror debian9-updates
    ...     return_stdout=False     return_rc=True
    Should Be Equal     ${rc}       ${0}
    ${rc} =     Execute Command
    ...     aptly snapshot create debian9-security-${DATETIME} from mirror debian9-security
    ...     return_stdout=False     return_rc=True
    Should Be Equal     ${rc}       ${0}
    ${rc} =     Execute Command
    ...     aptly snapshot create iorchard-${DATETIME} from repo iorchard-repo
    ...     return_stdout=False     return_rc=True
    Should Be Equal     ${rc}       ${0}

    Log     Merge snapshots of mirrors and a repo.    console=True
    ${rc} =     Execute Command
    ...     aptly snapshot merge iorchard-all-${DATETIME} debian9-${DATETIME} debian9-updates-${DATETIME} debian9-security-${DATETIME} iorchard-${DATETIME}
    ...     return_stdout=False     return_rc=True
    Should Be Equal     ${rc}       ${0}

    Log     Publish the merged snapshot.    console=True
    Write
    ...     aptly publish switch stretch filesystem:debianrepo:debian iorchard-all-${DATETIME}
    ${output} =     Read Until  Enter passphrase:
    Write   %{REPO_PW}
    Set Client Configuration    timeout=1800
    Read Until      ${REPO_UID}@${REPO_SERVER}

    ${rc} =     Execute Command     aptly publish list|grep -q ${DATETIME}
    ...     return_stdout=False     return_rc=True
    Should Be Equal     ${rc}       ${0}
    
*** Keywords ***
Preflight
    Get Environment Variable    REPO_PW
    Open Connection     ${REPO_SERVER}
    Login               ${REPO_UID}     %{REPO_PW}

Cleanup
    [Documentation]     Clean up the debris.
    Comment             Clean up the debris.
    ${rc} =     Execute Command
    ...     for snap in $(aptly snapshot list -raw |grep -v ${DATETIME}|sort -r);do aptly snapshot drop $snap;done 
    ...     return_stdout=False     return_rc=True
    Should Be Equal     ${rc}       ${0}

    ${rc} =     Execute Command     aptly db cleanup
    Should Be Equal     ${rc}       ${0}

    Close Connection
