#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get update -qy
apt-get upgrade -qy

# add users
UID_CATCHALL=1000
useradd -m --uid ${UID_CATCHALL} catchall

mkdir -p /var/mail/vhosts/catchall
chown -R catchall:catchall /var/mail/vhosts/catchall
ln -s /var/mail/vhosts/catchall /home/catchall/Maildir

# install Postfix, Dovecot, and Mutt
debconf-set-selections <<< "postfix postfix/mailname string 'localhost'"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
apt-get install -qy postfix dovecot-imapd ripgrep screen mutt mc


# configure Postfix
cat << EOF > /etc/postfix/main.cf
smtpd_banner = $myhostname ESMTP $mail_name (Debian/GNU)
biff = no

append_dot_mydomain = no

readme_directory = no

# logging
maillog_file_prefixes=/services/log
maillog_file=/services/log/00-postfix.log

# TLS parameters
smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
smtpd_tls_security_level=may

smtp_tls_CApath=/etc/ssl/certs
smtp_tls_security_level=may
smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache

smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination
smtpd_peername_lookup = no
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
mydestination = 'localhost', $myhostname, localhost.localdomain, localhost
relayhost =
mynetworks = 0.0.0.0/0 [::]/0
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = all
inet_protocols = all

home_mailbox = Maildir/
smtputf8_enable = yes

# catchall configuration
virtual_minimum_uid = ${UID_CATCHALL}
virtual_uid_maps = hash:/etc/postfix/vuid static:${UID_CATCHALL}
virtual_gid_maps = hash:/etc/postfix/vgid static:${UID_CATCHALL}
virtual_mailbox_base = /var/mail/vhosts
virtual_mailbox_limit = 0
virtual_mailbox_domains = example.org, static:all
virtual_mailbox_maps = hash:/etc/postfix/vmailbox static:catchall/
EOF


# configure Dovecot
cat << EOF >> /etc/dovecot/users
catchall:{PLAIN}secret:1000:1000::/home/catchall
EOF

sed -i 's|mbox:~/mail:INBOX=/var/mail/%u|maildir:/var/mail/vhosts/%d/%n|g' \
  /etc/dovecot/conf.d/10-mail.conf

sed -i 's|#log_path = syslog|log_path = /services/log/01-dovecot.log|g' \
  /etc/dovecot/conf.d/10-logging.conf
sed -i 's|#auth_debug = no|auth_debug = yes|g' \
  /etc/dovecot/conf.d/10-logging.conf
sed -i 's|#mail_debug = no|mail_debug = yes|g' \
  /etc/dovecot/conf.d/10-logging.conf

sed -i 's|#disable_plaintext_auth = yes|disable_plaintext_auth = no|g' \
  /etc/dovecot/conf.d/10-auth.conf
sed -i 's|#!include auth-passwdfile.conf.ext|!include auth-passwdfile.conf.ext|g' \
  /etc/dovecot/conf.d/10-auth.conf


# add test users
source /setup/add-vmailbox.sh testuser01 example.org
source /setup/add-vmailbox.sh testuser02 example.org
source /setup/add-vmailbox.sh testuser03 example.org
source /setup/add-vmailbox.sh testuser04 example.org
source /setup/add-vmailbox.sh testuser05 example.org
source /setup/add-vmailbox.sh testuser06 example.org
source /setup/add-vmailbox.sh testuser07 example.org
source /setup/add-vmailbox.sh testuser08 example.org
source /setup/add-vmailbox.sh testuser09 example.org
source /setup/add-vmailbox.sh testuser10 example.org

postmap /etc/postfix/vmailbox
postmap /etc/postfix/vuid
postmap /etc/postfix/vgid


# global screen configuration
sed -i 's|#startup_message off|startup_message off|g' /etc/screenrc
echo 'shell /bin/bash' >> /etc/screenrc

# mutt configuration
cp /etc/skel/.muttrc /root

# cleanup
source /setup/cleanup-image.sh

