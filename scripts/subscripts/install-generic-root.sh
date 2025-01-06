mkdir -p /etc/cron.d
echo "PATH=\"/usr/bin:/bin:/usr/sbin:/sbin\"

*/5 * * * * root /sbin/zfs-auto-snapshot -q -g --label=frequent --keep=24 //
00 * * * * root /sbin/zfs-auto-snapshot -q -g --label=hourly --keep=24 //
59 23 * * * root /sbin/zfs-auto-snapshot -q -g --label=daily --keep=14 //
59 23 * * 0 root /sbin/zfs-auto-snapshot -q -g --label=weekly --keep=4 //
00 00 1 * * root /sbin/zfs-auto-snapshot -q -g --label=monthly --keep=18 //" > /etc/cron.d/zfs-auto-snapshot
