#!/bin/bash
[[ -n $DEBUG ]] && set -x
set -eu

########################################################################################################################

my_cache_cleaner_schedule="${SERVICES_RENDERING_SERVICE_CACHE_CLEANER_SCHEDULE:-0 0 * * 0}"

########################################################################################################################
cron_file=schedule
echo "${my_cache_cleaner_schedule} /usr/local/bin/php $RS_ROOT/func/classes.new/Helper/cacheCleaner.php > /proc/1/fd/1 2>/proc/1/fd/2" > "$cron_file"
chmod 644 "$cron_file"

echo "Loading crontab file: $cron_file"
cat "$cron_file"

crontab -u appuser "$cron_file"

echo "Starting cron..."
exec cron -f