#!/system/bin/sh
set -eu
usage() { echo "usage: $0 status | governor NAME | set PARAM VALUE | measure NAME SECONDS" >&2; exit 2; }
ROOT=${0%/*}
POLICY_GLOB=/sys/devices/system/cpu/cpufreq/policy*
policy_paths() { for policy in $POLICY_GLOB; do [ -d "$policy" ] && printf '%s\n' "$policy"; done; }
status() {
  for policy in $(policy_paths); do printf '%s governor=%s min=%s max=%s available=%s\n' "${policy##*/}" "$(cat "$policy/scaling_governor")" "$(cat "$policy/scaling_min_freq")" "$(cat "$policy/scaling_max_freq")" "$(cat "$policy/scaling_available_governors")"; done
  for path in /sys/module/ged/parameters/simple_gpu_enabled /sys/module/ged/parameters/simple_gpu_up_threshold /sys/module/ged/parameters/simple_gpu_hold_ms /sys/module/ged/parameters/mali_boost_level /sys/module/mtk_bus_boost/parameters/enabled /sys/module/mtk_bus_boost/parameters/boost_opp /sys/module/mtk_bus_boost/parameters/duration_ms; do [ -r "$path" ] && printf '%s=%s\n' "$path" "$(cat "$path")"; done
}
set_governor() {
  name=$1; case "$name" in schedutil|lucretiperf|lucretibalance|lucretibattery) ;; *) echo "unsupported governor: $name" >&2; exit 1 ;; esac
  for policy in $(policy_paths); do case " $(cat "$policy/scaling_available_governors") " in *" $name "*) printf '%s\n' "$name" > "$policy/scaling_governor" ;; *) echo "$name unavailable for ${policy##*/}" >&2; exit 1 ;; esac; done
}
set_param() {
  case "$1" in simple_gpu_enabled) path=/sys/module/ged/parameters/simple_gpu_enabled ;; simple_gpu_up_threshold) path=/sys/module/ged/parameters/simple_gpu_up_threshold ;; simple_gpu_hold_ms) path=/sys/module/ged/parameters/simple_gpu_hold_ms ;; mali_boost_level) path=/sys/module/ged/parameters/mali_boost_level ;; bus_boost_enabled) path=/sys/module/mtk_bus_boost/parameters/enabled ;; bus_boost_opp) path=/sys/module/mtk_bus_boost/parameters/boost_opp ;; bus_boost_duration_ms) path=/sys/module/mtk_bus_boost/parameters/duration_ms ;; *) echo "unsupported parameter: $1" >&2; exit 1 ;; esac
  [ -w "$path" ] || { echo "parameter unavailable: $1" >&2; exit 1; }; case "$2" in ''|*[!0-9]*) echo "parameter value must be numeric" >&2; exit 1 ;; esac; printf '%s\n' "$2" > "$path"
}
[ "$#" -ge 1 ] || usage
case "$1" in status) [ "$#" -eq 1 ] || usage; status ;; governor) [ "$#" -eq 2 ] || usage; set_governor "$2" ;; set) [ "$#" -eq 3 ] || usage; set_param "$2" "$3" ;; measure) [ "$#" -eq 3 ] || usage; exec "$ROOT/measure_governor.sh" "$2" "$3" ;; *) usage ;; esac
