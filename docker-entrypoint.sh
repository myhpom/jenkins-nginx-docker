#!/usr/bin/env bash
set -e

# update jenkins UID
if [[ ${UID_JENKINS} != 1000 ]]; then
    echo "INFO: set jenkins UID to ${UID_JENKINS}"
    usermod -u ${UID_JENKINS} jenkins
    # update ownership of directories
    chown -R jenkins /var/jenkins_home
    chown -R jenkins /usr/share/jenkins/ref
fi

# update jenkins GID
if [[ ${GID_JENKINS} != 1000 ]]; then
    echo "INFO: set jenkins GID to ${GID_JENKINS}"
    groupmod -g ${GID_JENKINS} jenkins
fi

# allow jenkins to run sudo docker
echo "jenkins ALL=(root) NOPASSWD: /usr/bin/docker" > /etc/sudoers.d/jenkins
chmod 0440 /etc/sudoers.d/jenkins

HOSTS=/etc/hosts
HOSTSD=/etc/hosts.d
if [ -d "$HOSTSD" ]; then
    for FILENAME in ${HOSTSD}/*.conf; do
        FIRST=$(head -n 1 "$FILENAME")
        if ! grep -xq "$FIRST" ${HOSTS}; then
            printf "\n" >> ${HOSTS}
            cat ${FILENAME} >> ${HOSTS}
            echo Concatenated ${FILENAME} to ${HOSTS}
        else
            echo ${FILENAME} already concatenated to ${HOSTS}
        fi
    done
fi

# run Jenkins as user jenkins
su jenkins -c 'cd $HOME; /usr/local/bin/jenkins.sh'
