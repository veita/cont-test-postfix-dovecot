#!/bin/bash

M_USER=${1:-testuser01}

sendmail ${M_USER}@example.org <<EndOfMessage
From: sender@example.org
To: ${M_USER}@example.org
Subject: [TEST] Test from $(hostname) $(date --utc +%Y-%m-%dT%H:%M:%SZ)

Sent from $(hostname) $(date --utc +%Y-%m-%dT%H:%M:%SZ)

.
EndOfMessage

