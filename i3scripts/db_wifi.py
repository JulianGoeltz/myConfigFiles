#!python
import datetime
import json
import os
import os.path as osp
import requests
import subprocess
import sys
import time


# curl -s --insecure 'https://iceportal.de/api1/rs/tripInfo/trip' | jq -r ".trip.stops[].station.name"
# give notification if arrival within next x minutes for the following stops:
notification_minutes = 5
notification_stops = '  '.join([
    "Basel SBB",
    "Berlin",
    "Bern",
    "Crailsheim",
    "Heidelberg Hbf",
    "Heilbronn",
    "Karlsruhe Hbf",
    "Mannheim Hbf",
    "Paris",
    "Schwäbisch Hall",
    "Schwäbisch Hall-Hessental",
    "Stuttgart Hbf",
])


def possibly_notify(station, minutes_to_arrival):
    # print("'" + station + "'", file=sys.stderr)
    # print("'" + notification_stops + "'", file=sys.stderr)
    if station in notification_stops and minutes_to_arrival < notification_minutes:
        # check if notifications have been paused
        notfication_filename = '/tmp/db_wifi_stop_notifs'
        if not (osp.isfile(notfication_filename) and \
                (time.time() - os.stat(notfication_filename).st_mtime) < (notification_minutes + 10) * 60):
            if subprocess.run(["dunstctl", "is-paused"], capture_output=True).stdout == b'true\n':
                print("resuming dunstify", file=sys.stderr)
                subprocess.run(['/home/julgoe/myConfigFiles/i3scripts/dunstToggle.sh', 'resume'],)
            else:
                print("dunstify already running", file=sys.stderr)

            subprocess.run(["dunstify",
                            "-r", "7777",  # to replace old ones
                            "Stop in {} in {:.0f} minutes".format(
                                station,
                                minutes_to_arrival,
                            ),
                            ])


def find_place_from_gps(lat, lng):
    try:
        url = f"https://nominatim.openstreetmap.org/reverse?lat={lat}&lon={lng}&format=json"
        reponse = requests.get(url, headers={'User-Agent': 'locateMyTrain / 0.1'})
        reponse.raise_for_status()  # raises exception when not a 2xx response
        info = reponse.json()
    except json.decoder.JSONDecodeError as e:
        print("[OSM error with json]")
        # print(url, file=sys.stderr)
        # print(plain, file=sys.stderr)
        raise e
    except requests.exceptions.ConnectionError as e:
        print("[OSM connection error]")
        raise e
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

if len(sys.argv) > 1 and sys.argv[1] == "OEBB":
    try:
        trip_status = requests.get(
            f'https://railnet.oebb.at/assets/media/fis/combined.json?_time={int(time.time() * 1000)}'
        ).json()
    except json.decoder.JSONDecodeError as e:
        print("[connected to OEBB: error with json]")
        raise e
    except requests.exceptions.ConnectionError as e:
        print("[connected to OEBB: error connecting to portal]")
        raise e

    speed = trip_status['latestStatus']['speed']
    next_stop = trip_status['nextStation']['name']['de']
    next_stop_time = trip_status['nextStation']['arrival']['forecast']

    print(" [{} {} {}]".format(
        f"{speed}km/h",
        next_stop, next_stop_time,
    ))
elif len(sys.argv) > 1 and sys.argv[1] == "Portaleregionale FNM":
    # base ip address can be found with wireshark
    base = "http://192.168.10.197/PortaleRegionale/"

    try:
        data = requests.get(
            base + "map.getData.action",
        ).json()
    except json.decoder.JSONDecodeError as e:
        print("[connected to trenitalia: error with json]")
        raise e
    except requests.exceptions.ConnectionError as e:
        print("[connected to trenitalia: error connecting to portal]")
        raise e

    print(" [{}, {}, {}]".format(
        f"{float(data['infos']['speed']):.0f}km/h",
        f"next {data['nextStation']}",
        f"to {data['infos']['stazioneArrivo']}",
    ))

elif len(sys.argv) > 1 and "Frecciaross" in sys.argv[1]:
    # base ip address can be found with wireshark
    base = "https://d6o.frecciaplay.it/PortaleFrecce/infoViaggioActionJson"

    try:
        data = requests.get(
            base, verify=False
        ).json()
    except json.decoder.JSONDecodeError as e:
        print("[connected to trenitalia: error with json]")
        raise e
    except requests.exceptions.ConnectionError as e:
        print("[connected to trenitalia: error connecting to portal]")
        raise e

    speed = data['speed']
    next_stop = data['prossimaStazione']
    next_stop_time = data['eta']

    print(" [{}; next {} at {} ({})]".format(
        f"{speed}km/h",
        next_stop, next_stop_time,
        data['delay2']
    ))

elif subprocess.call("curl -s --insecure --max-time 1 https://wifi.sncf".split(" "),
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL) == 0:
    base = 'https://wifi.sncf/router/api/train/'
    try:
        # SSL certificate is not verified
        data_gps = requests.get(
            base + 'gps',
        ).json()
        data_details = requests.get(
            base + 'details',
        ).json()
    except json.decoder.JSONDecodeError as e:
        print("[connected to SNCF: error with json]")
        raise e
    except requests.exceptions.ConnectionError as e:
        print("[connected to SNCF: error connecting to portal]")
        raise e

    # get next station
    now = datetime.datetime.now()
    next_stop = None
    for stop in data_details['stops']:
        print(f"looking at {stop['label']}", file=sys.stderr)
        stop_timestamp = time.mktime(
            time.strptime(stop['realDate'], '%Y-%m-%dT%H:%M:%S.%fZ')
        ) + 2 * 60 * 60  # two hours off
        if stop_timestamp > time.time():
            next_stop = stop['label']
            expected_arrival = datetime.datetime.fromtimestamp(stop_timestamp).strftime('%H:%M')
            # scheduledArrival_date.
            minutes_to_arrival = (stop_timestamp - time.time()) / 60
            print(f'next is {next_stop} in {minutes_to_arrival}', file=sys.stderr)
            possibly_notify(next_stop, minutes_to_arrival)
            break

    print(" [{}, {}]".format(
        f"{float(data_gps['speed']) * 3.6:.0f}km/h",
        (f"next: {next_stop} at {expected_arrival}" if next_stop is not None else ''),
    ))

elif (
    # if in the ICE, this works
    subprocess.call("curl -s --insecure --max-time 1 https://portal.imice.de/api1/rs/tripInfo/trip".split(" "),
                    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL) == 0
    # # when connected via wifi-sharing hotspot
    # or
    # subprocess.call("curl -s --insecure --max-time 1 https://iceportal.de/api1/rs/status".split(" "),
    #                 stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL) == 0
):
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

                possibly_notify(stop['station']['name'], minutes_to_arrival)

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

    url_stat = 'https://zugportal.de/@prd/zupo-travel-information/api/public/ri/journey'
    try:
        data_stat = requests.get(url_stat, verify=False).json()
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
    else:
        for stop in data_stat['stops']:
            try:
                if (
                    ("departureTime" in stop and stop["departureTime"]["timeType"] == "REAL")
                    or
                    ("arrivalTime" in stop and stop["arrivalTime"]["timeType"] == "REAL")
                ):
                    continue
            except:
                print(stop, file=sys.stderr)
                raise
            scheduledArrival = int(stop["arrivalTime"]["targetTimeInMs"] / 1000)
            scheduledArrival_date = datetime.datetime.fromtimestamp(scheduledArrival)
            delay = (stop["arrivalTime"]["predictedTimeInMs"] - stop["arrivalTime"]["targetTimeInMs"]) / 1000/ 60
            current_state = "next: {} at {}{} on track {}".format(
                stop["station"]['name'],
                scheduledArrival_date.strftime('%H:%M'),
                f"+{delay:.0}",
                stop['track']['target'],
            )
            possibly_notify(stop["station"]['name'], delay)
    # elif 'lat' in data and 'lng' in data:
    #     current_state = find_place_from_gps(data['lat'], data['lng'])

    print(" [{}, {}]".format(
        f"{float(data['speed']) * 3.6:.0f}km/h",
        current_state,
    ))
else:
    print("No known api host reachable")
