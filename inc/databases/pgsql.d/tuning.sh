#!/bin/sh

CONFFILE="$PGDATA"/postgresql.conf

echo 'shared_buffers = 1GB'         >> $CONFFILE
echo 'work_mem = 128MB'             >> $CONFFILE
echo 'maintenance_work_mem = 256MB' >> $CONFFILE
echo 'effective_cache_size = 2GB '  >> $CONFFILE
echo 'synchronous_commit = off'     >> $CONFFILE
