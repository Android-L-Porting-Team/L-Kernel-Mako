#!/system/bin/sh
bb=busybox
echo "[defcon] Welcome to Ultimate Kernel Series" | tee /dev/kmsg
# Disable mpdecision & thermald
	stop thermald
	stop mpdecision
	echo 1 > /sys/module/msm_thermal/parameters/enabled
	echo "[defcon] thermald & mpdecision disabled" | tee /dev/kmsg
	echo "[defcon] Intelli-Thermal Enabled!" | tee /dev/kmsg

	# Test's max temp to 65 before throttling kicks in
	# echo "65" > /sys/module/msm_thermal/parameters/temp_threshold

# MSM_Hotplug options
	echo "1" > /sys/module/msm_hotplug/suspend_max_cpus
	echo "1026000" > /sys/module/msm_hotplug/suspend_max_freq

# Set default hotplug here:
	echo 1 > /sys/module/autosmp/parameters/enabled
	echo 0 > /sys/module/msm_hotplug/msm_enabled
	echo 0 > /sys/module/intelli_plug/parameters/intelli_plug_active
	echo "[defcon] hotplug options set!" | tee /dev/kmsg

# Tweak AutoSMP Hotplug
	echo "972000" > /sys/kernel/autosmp/conf/cpufreq_down
	echo "1242000" > /sys/kernel/autosmp/conf/cpufreq_up
	echo 3 > /sys/kernel/autosmp/conf/cycle_down
	echo 1 > /sys/kernel/autosmp/conf/cycle_up
	echo 4 > /sys/kernel/autosmp/conf/max_cpus
	echo 1 > /sys/kernel/autosmp/conf/min_cpus
	echo "100" > /sys/kernel/autosmp/conf/delay
	echo 1 > /sys/kernel/autosmp/conf/scroff_single_core
	echo "[defcon] autosmp fully optimized!" | tee /dev/kmsg

# Set TCP westwood
	echo "westwood" > /proc/sys/net/ipv4/tcp_congestion_control
	echo "[defcon] TCP set: westwood" | tee /dev/kmsg

# Set IntelliActive as default:	
	echo "intelliactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
	echo "intelliactive" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
	echo "intelliactive" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
	echo "intelliactive" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
	echo "81000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
	echo "81000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
	echo "81000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
	echo "81000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
	echo 0 > /sys/devices/system/cpu/cpufreq/intelliactive/boost
	echo "[defcon] Intelli-Active Enabled with BOOST!" | tee /dev/kmsg

# Set Power Save Settings
	echo 1 > /sys/module/pm_8x60/modes/cpu0/wfi/suspend_enabled
	echo 1 > /sys/module/pm_8x60/modes/cpu0/power_collapse/suspend_enabled
	echo 1 > /sys/module/pm_8x60/modes/cpu1/power_collapse/suspend_enabled
	echo 1 > /sys/module/pm_8x60/modes/cpu2/power_collapse/suspend_enabled
	echo 1 > /sys/module/pm_8x60/modes/cpu3/power_collapse/suspend_enabled
	echo 1 > /sys/module/pm_8x60/modes/cpu0/standalone_power_collapse/suspend_enabled
	echo 1 > /sys/module/pm_8x60/modes/cpu1/standalone_power_collapse/suspend_enabled
	echo 1 > /sys/module/pm_8x60/modes/cpu2/standalone_power_collapse/suspend_enabled
	echo 1 > /sys/module/pm_8x60/modes/cpu3/standalone_power_collapse/suspend_enabled
	echo "[defcon] Power saving modes Enabled" | tee /dev/kmsg

# Set IOSched
	echo "fiops" > /sys/block/mmcblk0/queue/scheduler
	echo "[defcon] IOSched set: fiops" | tee /dev/kmsg

# Sweep2Dim default
	echo "0" > /sys/android_touch/sweep2wake
	echo "1" > /sys/android_touch/sweep2dim
	echo "73" > /sys/module/sweep2wake/parameters/down_kcal
	echo "73" > /sys/module/sweep2wake/parameters/up_kcal
	echo "[defcon] sweep2dim enabled!" | tee /dev/kmsg

# Set RGB KCAL
if [ -e /sys/devices/platform/kcal_ctrl.0/kcal ]; then
	sd_r=255
	sd_g=255
	sd_b=255
	kcal="$sd_r $sd_g $sd_b"
	echo "$kcal" > /sys/devices/platform/kcal_ctrl.0/kcal
	echo "1" > /sys/devices/platform/kcal_ctrl.0/kcal_ctrl
	echo "[defcon] LCD_KCAL: red=[$sd_r], green=[$sd_g], blue=[$sd_b]" | tee /dev/kmsg
fi

# disable sysctl.conf to prevent ROM interference with tunables
	$bb mount -o rw,remount /system;
	$bb [ -e /system/etc/sysctl.conf ] && $bb mv -f /system/etc/sysctl.conf /system/etc/sysctl.conf.fkbak;

# disable the PowerHAL since there is a kernel-side touch boost implemented
	$bb [ -e /system/lib/hw/power.msm8960.so.fkbak ] || $bb cp /system/lib/hw/power.msm8960.so /system/lib/hw/power.msm8960.so.fkbak;
	$bb [ -e /system/lib/hw/power.msm8960.so ] && $bb rm -f /system/lib/hw/power.msm8960.so;

# create and set permissions for /system/etc/init.d if it doesn't already exist
	$bb mkdir /system/etc/init.d;
	$bb chown -R root.root /system/etc/init.d;
	$bb chmod -R 775 /system/etc/init.d;
	$bb mount -o ro,remount /system;
	echo "[defcon] init.d permissions set" | tee /dev/kmsg

# Interactive Options
	echo 20000 1300000:40000 1400000:20000 > /sys/devices/system/cpu/cpufreq/interactive/above_hispeed_delay
	echo 85 1300000:90 1400000:70 > /sys/devices/system/cpu/cpufreq/interactive/target_loads

# GPU Max Clock
	echo "400000000" > /sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/max_gpuclk
	echo "[defcon] GPU Max Clock Set" | tee /dev/kmsg


