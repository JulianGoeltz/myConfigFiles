#!python
import datetime
import json
import requests
import subprocess
import sys
import time


# curl -s --insecure 'https://portal.imice.de/api1/rs/tripInfo/trip' | jq -r ".trip.stops[].station.name"
# give notification if arrival within next x minutes for the following stops:
notification_minutes = 5
notification_stops = [
    "Basel SBB",
    "Berlin",
    "Bern",
    "Crailsheim",
    "Heidelberg Hbf",
    "Mannheim Hbf",
    "Stuttgart Hbf",
]

if len(sys.argv) == 1 or sys.argv[1] == 'ice':
    base = 'https://portal.imice.de/api1/rs/'

    try:
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
        # import urllib3
        # urllib3.disable_warnings()
        print("found the following exception", file=sys.stderr)
        print(e, file=sys.stderr)
        print("retrying without verification of ssl certificate", file=sys.stderr)
        try:
            data_status = requests.get(
                base + 'status',
                verify=False,
            ).json()
            data_trip = requests.get(
                base + 'tripInfo/trip',
                verify=False
            ).json()
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

    print(" [{}, {} class{}]".format(
        f"{data_status['speed']}km/h" if data_status['gpsStatus'] != "INVALID" else "no GPS",
        "2." if data_status["wagonClass"] == "SECOND" else "1.",
        (nextstopinfo(data_trip['trip']['stopInfo']['actualNext'])
         if data_trip['trip']['stopInfo']['actualNext'] != '' else ''),
    ))

else:
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

    print(" [{}, {}]".format(
        f"{float(data['speed']) * 3.6:.0f}km/h",
        nextstopinfo(data['stateInformation']['nextStation']['id']) if 'stateInformation' in data else "(in station)"
    ))
