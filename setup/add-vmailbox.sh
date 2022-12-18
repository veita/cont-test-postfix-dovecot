
M_USER=$1
M_DOMAIN=$2

# create user
useradd -m ${M_USER}

M_UID=$(id -u ${M_USER})
M_GID=$(id -g ${M_USER})

M_DIR=/var/mail/vhosts/${M_DOMAIN}/${M_USER}

mkdir -p ${M_DIR}
mkdir -p ${M_DIR}/.folder1/{cur,new,tmp}
touch ${M_DIR}/.folder1/maildirfolder

mkdir -p ${M_DIR}
mkdir -p ${M_DIR}/.folder2/{cur,new,tmp}
touch ${M_DIR}/.folder2/maildirfolder

mkdir -p ${M_DIR}
mkdir -p ${M_DIR}/.folder3/{cur,new,tmp}
touch ${M_DIR}/.folder3/maildirfolder

mkdir -p ${M_DIR}
mkdir -p ${M_DIR}/.folder3.folder3_1/{cur,new,tmp}
touch ${M_DIR}/.folder3.folder3_1/maildirfolder

chown -R ${M_UID}:${M_GID} ${M_DIR}
ln -s ${M_DIR} /home/${M_USER}/Maildir

echo "${M_USER}@${M_DOMAIN} ${M_DOMAIN}/${M_USER}/" >> /etc/postfix/vmailbox
echo "${M_USER}@${M_DOMAIN} ${M_UID}/" >> /etc/postfix/vuid
echo "${M_USER}@${M_DOMAIN} ${M_GID}/" >> /etc/postfix/vgid
echo "${M_USER}@${M_DOMAIN}:{PLAIN}secret:${M_UID}:${M_GID}::/home/${M_USER}" >> /etc/dovecot/users
