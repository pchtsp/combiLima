import json
import app.aux as aux


def get_companies():
    with open('data/empresas.txt', 'r') as f:
        return [(str(n), l[:-2]) for n, l in enumerate(f.readlines())][1:]


def get_stops():
    with open('data/stops.json') as f:
        return {elem['id']: elem for elem in json.load(f)}


def get_stops_in_range(north_east, south_west):
    return {k: v for k, v in get_stops().items() if
             south_west['lat'] >= v['lat'] >= north_east['lat'] and
             south_west['lon'] >= v['lon'] >= north_east['lon']}


def get_stop_routes(stop_id):
    file = aux.clean_chars(stop_id)
    with open('data/stops/{}_routes.json'.format(file)) as f:
        content = json.load(f)
    routes = [json.loads(elem["routeDesc"]) for elem in content]
    return routes
