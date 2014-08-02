#!/system/bin/sh

# disable autosmp 
# This can be re-enabled with echo 1
echo 1 > /sys/module/autosmp/parameters/enabled
# enable msm_hotplug
echo 0 > /sys/module/msm_hotplug/msm_enabled
# disable intelli_plug
echo 0 > /sys/module/intelli_plug/parameters/intelli_plug_active

# Set TCP westwood
if [ -e /proc/sys/net/ipv4/tcp_congestion_control ]; then
	echo "westwood" > /proc/sys/net/ipv4/tcp_congestion_control
	echo "[furnace] TCP set: westwood" | tee /dev/kmsg
else
	echo "[furnace] what" | tee /dev/kmsg
fi

# Set IOSched
if [ -e /sys/block/mmcblk0/queue/scheduler ]; then
	echo "fiops" > /sys/block/mmcblk0/queue/scheduler
	echo "[furnace] IOSched set: fiops" | tee /dev/kmsg
else
	echo "[furnace] D:" | tee /dev/kmsg
fi

# Sweep2Dim default
if [ -e /sys/android_touch/sweep2wake ]; then
	if [ -e /sys/android_touch/sweep2dim ]; then
		echo "0" > /sys/android_touch/sweep2wake
		echo "1" > /sys/android_touch/sweep2dim
		echo "73" > /sys/module/sweep2wake/parameters/down_kcal
		echo "73" > /sys/module/sweep2wake/parameters/up_kcal
		echo "[inception] sweep2dim configured!" | tee /dev/kmsg
	else
		echo "[inception] sweep2dim not found" | tee /dev/kmsg
	fi
else
	echo "[inception] sweep2wake not found" | tee /dev/kmsg
fi

# Set RGB KCAL
if [ -e /sys/devices/platform/kcal_ctrl.0/kcal ]; then
	sd_r=255
	sd_g=255
	sd_b=255
	kcal="$sd_r $sd_g $sd_b"
	echo "$kcal" > /sys/devices/platform/kcal_ctrl.0/kcal
	echo "1" > /sys/devices/platform/kcal_ctrl.0/kcal_ctrl
	echo "[inception] LCD_KCAL: red=[$sd_r], green=[$sd_g], blue=[$sd_b]" | tee /dev/kmsg
fi

# disable sysctl.conf to prevent ROM interference with tunables
$bb mount -o rw,remount /system;
$bb [ -e /system/etc/sysctl.conf ] && $bb mv -f /system/etc/sysctl.conf /system/etc/sysctl.conf.fkbak;

# disable the PowerHAL since there is a kernel-side touch boost implemented
$bb [ -e /system/lib/hw/power.msm8960.so.fkbak ] || $bb cp /system/lib/hw/power.msm8960.so /system/lib/hw/power.msm8960.so.fkbak;
$bb [ -e /system/lib/hw/power.msm8960.so ] && $bb rm -f /system/lib/hw/power.msm8960.so;

# create and set permissions for /system/etc/init.d if it doesn't already exist
if [ ! -e /system/etc/init.d ]; then
  $bb mkdir /system/etc/init.d;
  $bb chown -R root.root /system/etc/init.d;
  $bb chmod -R 755 /system/etc/init.d;
fi;
$bb mount -o ro,remount /system;

echo 20000 1300000:40000 1400000:20000 > /sys/devices/system/cpu/cpufreq/interactive/above_hispeed_delay
echo 85 1300000:90 1400000:70 > /sys/devices/system/cpu/cpufreq/interactive/target_loads
