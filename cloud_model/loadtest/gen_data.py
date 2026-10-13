import sys, json, numpy as np, pandas as pd
CONT = ["tap_duration","swipe_velocity","touch_pressure","tap_interval_avg","accel_variance","gyro_variance","battery_level","brightness_level","screen_on_time","time_of_day_sin","time_of_day_cos","wifi_id_hash","gps_latitude","gps_longitude","device_orientation","touch_area","touch_event_count","app_usage_time"]
BIN = ["accel_variance_missing","gyro_variance_missing","charging_state","wifi_info_missing","gps_location_missing","day_of_week_mon","day_of_week_tue","day_of_week_wed","day_of_week_thu","day_of_week_fri","day_of_week_sat","day_of_week_sun"]
def rows(n, seed, anomalous=False):
    r = np.random.default_rng(seed)
    d = pd.DataFrame(r.normal(0, 1, (n, len(CONT))) * (4 if anomalous else 1) + (5 if anomalous else 0), columns=CONT)
    for b in BIN: d[b] = r.integers(0, 2, n)
    return d
if __name__ == "__main__":
    n, out = int(sys.argv[1]), sys.argv[2]
    rows(n, 1).to_csv(out, index=False)
