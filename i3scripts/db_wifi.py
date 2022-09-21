#!python
import datetime
import json
import requests
import subprocess
import sys
import time


# curl -s --insecure 'https://iceportal.de/api1/rs/tripInfo/trip' | jq -r ".trip.stops[].station.name"
# give notification if arrival within next x minutes for the following stops:
notification_minutes = 5
notification_stops = [
    "Basel SBB",
    "Berlin",
    "Bern",
    "Crailsheim",
    "Heidelberg Hbf",
    "Karlsruhe Hbf",
    "Mannheim Hbf",
    "Stuttgart Hbf",
]


def find_place_from_gps(lat, lng):
    info = requests.get(f"https://nominatim.openstreetmap.org/reverse?lat={lat}&lon={lng}&format=json").json()
    if 'address' in info:
        if 'city' in info['address']:
            return "close to " + info['address']['city']
        elif 'town' in info['address']:
            return "close to " + info['address']['town']
        elif 'village' in info['address']:
            return "close to " + info['address']['village']
        elif 'municipality' in info['address']:
            return "close to " + info['address']['municipality']
    # handle errors
    from pprint import pformat
    print(pformat(info), file=sys.stderr)
    return ""


# x = subprocess.call("curl -s --insecure --max-time 1 https://portal.imice.de/api1/rs/tripInfo/trip".split(" "),
#                     stdout=sys.stdout, stderr=sys.stderr)
# # stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
# time.sleep(1)
# print(x)

if subprocess.call("curl -s --insecure --max-time 1 https://portal.imice.de/api1/rs/tripInfo/trip".split(" "),
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL) == 0:
    base = 'https://iceportal.de/api1/rs/'

    try:
        # SSL certificate is not verified
        data_status = requests.get(
            base + 'status',
        ).json()
        data_trip = requests.get(
            base + 'tripInfo/trip',
        ).json()
    except json.decoder.JSONDecodeError as e:
        print("[connected to ICE: error with json]")
        raise e
    except requests.exceptions.ConnectionError as e:
        print("[connected to ICE: error connecting to portal]")
        raise e

    def nextstopinfo(stop_eva):
        for stop in data_trip['trip']['stops']:
            if stop['station']['evaNr'] == stop_eva:
                scheduledArrival = int(stop['timetable']['scheduledArrivalTime']) / 1000

                arrivalDelay = stop['timetable']['arrivalDelay']
                arrivalDelay = 0 if arrivalDelay == '' else float(arrivalDelay)
                time_to_arrival = (scheduledArrival + 60 * arrivalDelay) - time.time()
                minutes_to_arrival = time_to_arrival / 60

                if stop['station']['name'] in notification_stops and minutes_to_arrival < notification_minutes:
                    if subprocess.run(["dunstctl", "is-paused"], capture_output=True).stdout == b'true\n':
                        print("resuming dunstify", file=sys.stderr)
                        subprocess.run(['/home/julgoe/myConfigFiles/i3scripts/dunstToggle.sh', 'resume'],)
                    else:
                        print("dunstify already running", file=sys.stderr)

                    subprocess.run(["dunstify",
                                    "-r", "7777",  # to replace old ones
                                    "Stop in {} in {:.0f} minutes".format(
                                        stop['station']['name'],
                                        minutes_to_arrival,
                                    ),
                                    ])

                scheduledArrival_date = datetime.datetime.fromtimestamp(scheduledArrival)
                return ", next: {} at {}{} on track {}".format(
                    stop['station']['name'],
                    scheduledArrival_date.strftime('%H:%M'),
                    stop['timetable']['arrivalDelay'],
                    stop['track']['actual'],
                )
        return

    # print("", file=sys.stderr)
    # print(find_place_from_gps(data_status['latitude'], data_status['longitude']), file=sys.stderr)
    # print("", file=sys.stderr)

    print(" [{}, {} class{}{}]".format(
        f"{data_status['speed']}km/h" if data_status['gpsStatus'] != "INVALID" else "no GPS",
        "2." if data_status["wagonClass"] == "SECOND" else "1.",
        (nextstopinfo(data_trip['trip']['stopInfo']['actualNext'])
         if (data_trip['trip']['stopInfo'] is not None and
             data_trip['trip']['stopInfo']['actualNext'] != '') else ''),
        (", " + find_place_from_gps(data_status['latitude'], data_status['longitude'])
         if data_status['gpsStatus'] != 'VALID' else ""),
    ))

elif subprocess.call("ping -c 1 -W 0.5 www.wifi-bahn.de".split(" "),
                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL) == 0:
    url = 'https://www.wifi-bahn.de/schedule.jason'

    try:
        data = requests.get(url, verify=False).json()
    except json.decoder.JSONDecodeError:
        print("[connected to db: error with json]")
        sys.exit()
    except requests.exceptions.ConnectionError:
        print("[connected to db: error connecting to portal]")
        sys.exit()

    def nextstopinfo(nextstop_id):
        for stop in data['stations']:
            if stop['id'] == nextstop_id:
                scheduledArrival = int(stop['approach'])
                scheduledArrival_date = datetime.datetime.fromtimestamp(scheduledArrival)
                return "next: {} at {}{} on track {}".format(
                    stop['name'],
                    scheduledArrival_date.strftime('%H:%M'),
                    f"({stop['delay']})" if stop['delay'] != 0 else "",
                    stop['track'],
                )
        return

    # current place info:
    current_state = "(no data/in station)"
    if 'stateInformation' in data:
        current_state = nextstopinfo(data['stateInformation']['nextStation']['id'])
    elif 'lat' in data and 'lng' in data:
        current_state = find_place_from_gps(data['lat'], data['lng'])

    print(" [{}, {}]".format(
        f"{float(data['speed']) * 3.6:.0f}km/h",
        current_state,
    ))
else:
    print("No known api host reachable")
