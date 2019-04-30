*** Settings ***
Documentation    Build ceph debian packages on debian stretch machine.
Suite Setup      Preflight
Suite Teardown   Cleanup
Library         OperatingSystem
Variables       props.py

*** Tasks ***
Build 
    [Documentation]     Build ceph.
    ${rc}   ${output} =     Run And Return Rc And Output
    ...     docker image ls ${DOCKER_IMG} -q
    Run Keyword If  "${output}" == ""   Build Docker Image

    ${rc} =     Run And Return Rc
    ...     docker run --rm -v ${DPKG_DIR}:/debs ${DOCKER_IMG} ${VER} >/dev/null 2>&1
    Should Be Equal As Integers     ${rc}       0

*** Keywords ***
Cleanup
    [Documentation]     Clean up the debris.
    Run     for img in $(docker image ls -q);do docker rmi $img;done

Preflight
    [Documentation]     Preflight before building.
    Check If Resources Are Enough To Build
    Check If Docker Is Installed

Build Docker Image
    [Documentation]     Build docker image to build ceph deb packages.
    Run     docker build -t ceph-builder .
    ${rc}   ${output} =     Run And Return Rc And Output
    ...     docker image ls ${DOCKER_IMG} -q
    Should Not Be Empty     ${output} 

Check If Docker Is Installed
    [Documentation]     Check if docker is installed on the build machine.
    ${rc} =     Run And Return Rc   docker info
    Should Be Equal As Integers     ${rc}   0

Check If Resources Are Enough To Build
    [Documentation]     Check if cpu/ram/disk are enough to build ceph.
    ${output} =     Run     grep ^processor /proc/cpuinfo | wc -l
    Should Be True  ${output} > 7  msg=CPU cores should be at least 8.
    ${output} =     Run     grep ^MemTotal: /proc/meminfo | awk '{print $2}'
    Should Be True  ${output} > (23*1024*1024)  
    ...     msg=Memory should be at least 24 GiB.
    ${output} =     Run
    ...     echo $(($(stat -f --format="%a*%S" .)/(1024*1024*1024)))
    Should Be True  ${output} >= 90
    ...     msg=Free disk space should be at least 90GiB.
