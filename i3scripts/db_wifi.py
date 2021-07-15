#!python
import datetime
import json
import requests
import sys


if len(sys.argv) == 1 or sys.argv[1] == 'ice':
    base = 'https://portal.imice.de/api1/rs/'

    try:
        data_status = requests.get(base + 'status').json()
        data_trip = requests.get(base + 'tripInfo/trip').json()
    except json.decoder.JSONDecodeError:
        print("[connected to ICE: error with json]")
        sys.exit()
    except requests.exceptions.ConnectionError:
        print("[connected to ICE: error connecting to portal]")
        sys.exit()

    def nextstopinfo(stop_eva):
        for stop in data_trip['trip']['stops']:
            if stop['station']['evaNr'] == stop_eva:
                scheduledArrival = int(stop['timetable']['scheduledArrivalTime']) / 1000
                scheduledArrival_date = datetime.datetime.fromtimestamp(scheduledArrival)
                return "next: {} at {}{} on track {}".format(
                    stop['station']['name'],
                    scheduledArrival_date.strftime('%H:%M'),
                    stop['timetable']['arrivalDelay'],
                    stop['track']['actual'],
                )
        return

    print(" [{}, {} class, {}]".format(
        f"{data_status['speed']}km/h" if data_status['gpsStatus'] != "INVALID" else "no GPS",
        "2." if data_status["wagonClass"] == "SECOND" else "1.",
        nextstopinfo(data_trip['trip']['stopInfo']['actualNext']),
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

    from pprint import pprint
    # pprint(data)

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
        nextstopinfo(data['stateInformation']['nextStation']['id']),
    ))
