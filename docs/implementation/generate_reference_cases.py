"""Generate independent reference positions for Phase 17 validation cases.

Uses Skyfield (MIT) with the NASA JPL DE421 ephemeris, downloaded once
from the JPL site by Skyfield itself. Nothing here is copied from the
Dart engine: positions are apparent geocentric ecliptic longitudes,
ascendant is recomputed from Skyfield GMST with the standard formula,
and rise/set times come from skyfield.almanac.

Run: ~/workspace/dharm-guru-team/skyfield-venv/bin/python
         docs/implementation/generate_reference_cases.py
Output: docs/implementation/reference_cases.json (checked in).
"""

import json
import math

from skyfield.api import load, load_file
from skyfield import almanac

EPH = load_file(
    "/home/hatch/workspace/dharm-guru-team/ephemeris/de421.bsp"
)
TS = load.timescale()
EARTH = EPH["earth"]
BODIES = {
    "Sun": EPH["sun"],
    "Moon": EPH["moon"],
    "Mercury": EPH["mercury"],
    "Venus": EPH["venus"],
    "Mars": EPH["mars"],
    "Jupiter": EPH["jupiter barycenter"],
    "Saturn": EPH["saturn barycenter"],
}


def ecliptic_lon(body, t):
    lat, lon, _ = EARTH.at(t).observe(body).apparent().ecliptic_latlon()
    return lon.degrees % 360.0


def ascendant(t, latitude, longitude):
    """Standard ascendant from GMST, independent of the Dart code."""
    gmst = t.gmst  # hours
    lst = (gmst * 15.0 + longitude) % 360.0
    eps = 23.4393 - 3.563e-7 * (t.tt - 2451543.5)
    lst_r = math.radians(lst)
    lat_r = math.radians(latitude)
    eps_r = math.radians(eps)
    # Ecliptic north pole in equatorial coords.
    nx, ny, nz = 0.0, -math.sin(eps_r), math.cos(eps_r)
    # Zenith in equatorial coords.
    zx = math.cos(lat_r) * math.cos(lst_r)
    zy = math.cos(lat_r) * math.sin(lst_r)
    zz = math.sin(lat_r)
    dx = ny * zz - nz * zy
    dy = nz * zx
    dz = -ny * zx
    xe = dx
    ye = dy * math.cos(eps_r) + dz * math.sin(eps_r)
    lon = math.degrees(math.atan2(ye, xe)) % 360.0
    ra = math.degrees(math.atan2(dy, dx)) % 360.0
    ha = (lst - ra) % 360.0
    if ha > 180.0:
        ha -= 360.0
    if ha > 0:
        lon = (lon + 180.0) % 360.0
    return lon


def case(name, y, mo, d, h, mi, lat, lon, note=""):
    t = TS.utc(y, mo, d, h, mi)
    t1 = TS.utc(y, mo, d, h, mi) + 1.0 / 24.0
    positions = {}
    motion = {}
    for pname, body in BODIES.items():
        positions[pname] = round(ecliptic_lon(body, t), 4)
        nxt = ecliptic_lon(body, t1)
        delta = (nxt - positions[pname] + 180.0) % 360.0 - 180.0
        motion[pname] = round(delta * 24.0, 4)  # degrees per day
    out = {
        "name": name,
        "utc": "%04d-%02d-%02d %02d:%02d" % (y, mo, d, h, mi),
        "latitude": lat,
        "longitude": lon,
        "note": note,
        "tropical_longitudes": positions,
        "degrees_per_day": motion,
        "ascendant_tropical": round(ascendant(t, lat, lon), 4),
    }
    # Rise and set on the UTC date of the instant.
    t0 = TS.utc(y, mo, d)
    t1d = TS.utc(y, mo, d) + 1
    from skyfield.api import Topos
    topo = Topos(latitude_degrees=lat, longitude_degrees=lon)
    f = almanac.sunrise_sunset(EPH, topo)
    times, events = almanac.find_discrete(t0, t1d, f)
    out["sun_rise_set_utc"] = [
        {"event": "sunrise" if e else "sunset", "utc": str(tt.utc_iso())}
        for tt, e in zip(times, events)
    ]
    f2 = almanac.risings_and_settings(EPH, EPH["moon"], topo)
    times2, events2 = almanac.find_discrete(t0, t1d, f2)
    out["moon_rise_set_utc"] = [
        {"event": "moonrise" if e else "moonset", "utc": str(tt.utc_iso())}
        for tt, e in zip(times2, events2)
    ]
    return out


CASES = [
    case("canonical", 1998, 3, 14, 0, 55, 26.9124, 75.7873,
         "14 Mar 1998 06:25 IST Jaipur, Lagna Kumbha"),
    case("leap_2000", 2000, 2, 29, 6, 30, 28.6139, 77.2090,
         "29 Feb 2000 12:00 IST Delhi, leap day"),
    case("leap_2024_midnight", 2024, 2, 29, 18, 29, 19.0760, 72.8777,
         "29 Feb 2024 23:59 IST Mumbai, leap day near midnight"),
    case("sydney_south", 2005, 6, 14, 22, 30, -33.8688, 151.2093,
         "15 Jun 2005 08:30 AEST Sydney, southern hemisphere winter"),
    case("newyork_dst_first", 2010, 11, 7, 5, 30, 40.7128, -74.0060,
         "7 Nov 2010 01:30 EDT New York, DST fall back first hour"),
    case("newyork_dst_second", 2010, 11, 7, 6, 30, 40.7128, -74.0060,
         "7 Nov 2010 01:30 EST New York, DST fall back second hour"),
    case("london_bst", 2026, 3, 29, 1, 30, 51.5074, -0.1278,
         "29 Mar 2026 01:30 UTC London, BST starts 01:00 UTC"),
    case("midnight_kolkata", 2014, 12, 31, 18, 30, 22.5726, 88.3639,
         "1 Jan 2015 00:00 IST Kolkata, midnight birth"),
    case("jupiter_retrograde", 2025, 12, 1, 12, 0, 26.9124, 75.7873,
         "1 Dec 2025 12:00 UTC Jaipur, Jupiter retrograde"),
    case("saturn_retrograde", 2025, 8, 1, 12, 0, 26.9124, 75.7873,
         "1 Aug 2025 12:00 UTC Jaipur, Saturn retrograde"),
    case("new_moon_dec_2026", 2026, 12, 8, 6, 30, 26.9124, 75.7873,
         "8 Dec 2026 12:00 IST Jaipur, new moon Amavasya"),
    case("full_moon_dec_2026", 2026, 12, 23, 6, 30, 26.9124, 75.7873,
         "23 Dec 2026 12:00 IST Jaipur, full moon Purnima"),
]

if __name__ == "__main__":
    data = {
        "source": "Skyfield 1.55 with JPL DE421, apparent geocentric "
                  "ecliptic longitudes, GMST ascendant, "
                  "skyfield.almanac rise/set",
        "cases": CASES,
    }
    with open("docs/implementation/reference_cases.json", "w") as fh:
        json.dump(data, fh, indent=2)
    for c in CASES:
        print(c["name"], c["utc"], "Sun", c["tropical_longitudes"]["Sun"],
              "Moon", c["tropical_longitudes"]["Moon"],
              "Jup/day", c["degrees_per_day"]["Jupiter"],
              "Sat/day", c["degrees_per_day"]["Saturn"],
              "Asc", c["ascendant_tropical"])
