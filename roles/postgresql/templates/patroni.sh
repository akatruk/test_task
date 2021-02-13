#!/bin/bash
export PATH=$PATH:/usr/pgsql-12/bin
/opt/patroni/patroni.py /etc/patroni/postgres.yml
