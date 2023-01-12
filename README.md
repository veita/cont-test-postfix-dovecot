# Postfix/Dovecot container with catch-all account and predefined test users

Build a Debian container image with Postfix and Dovecot using Podman/Buildah.

Postfix will deliver all mail to the predefined `catchall` mailbox, except
mails sent to `testuser${NN}@example.org` where `${NN}` is in the range from
`01`, `02`, ..., `10`.

Emails sent to the following recipient addresses will be rejected
* `reject-451@rejected.domain` rejected with code 451
* `reject-554@rejected.domain` rejected with code 554

User names for IMAP access are `catchall` and `testuser${NN}@example.org` with
password `secret` respectively.


## Run the image build

To build the image run

```bash
./build-container.sh
```

## Run the container

Exposed ports are
*  25 SMTP
* 465 SMTPS
* 587 SUBMIT
* 143 IMAP
* 993 IMAPS

Example: Run the container with Postfix listening on port 10025 for SMTP
connections and Dovecot listening on port 10143 for IMAP connections.

```bash
alias podman=docker

podman run --name test-mail --hostname test-mail -p 10025:25 -p 10143:143 --detach localhost/test-postfix-dovecot:latest
```


## Safety

Do not run `setup.sh` in your host system.

