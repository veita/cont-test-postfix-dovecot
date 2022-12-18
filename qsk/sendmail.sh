#!/bin/bash

sendmail recipient@example.org <<EndOfMessage
From: sender@example.org
To: recipient@example.org
Subject: [TEST] Test from $(hostname) $(date --utc +%Y-%m-%dT%H:%M:%SZ)

Sent from $(hostname) $(date --utc +%Y-%m-%dT%H:%M:%SZ)

.
EndOfMessage
