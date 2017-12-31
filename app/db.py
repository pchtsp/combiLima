import json
import app.aux as aux


def search_company(company_id):
    companies = get_companies()
    company_name = [c[1] for c in companies if company_id == c[0]]
    if len(company_name) > 0:
        return company_name[0]
    return ""

def get_companies():
    with open('data/empresas.txt', 'r') as f:
        return [(str(n), l[:-2]) for n, l in enumerate(f.readlines())][1:]


def get_stops():
    with open('data/stops.json') as f:
        return {elem['id']: elem for elem in json.load(f)}


def get_stops_in_range(north_east, south_west):
    return {k: v for k, v in get_stops().items() if
             south_west['lat'] <= v['lat'] <= north_east['lat'] and
             south_west['lon'] <= v['lon'] <= north_east['lon']}


def get_stops_around_center(center, dist=0.05):
    lat = center['lat']
    lon = center['lon']
    ne = {
        'lat': lat + dist,
        'lon': lon + dist
    }
    sw = {
        'lat': lat - dist,
        'lon': lon - dist
    }
    return get_stops_in_range(ne, sw)


def get_stop_routes(stop_id):
    file = aux.clean_chars(stop_id)
    with open('data/stops/{}_routes.json'.format(file)) as f:
        content = json.load(f)
    routes = [json.loads(elem["routeDesc"]) for elem in content]
    return [route.get('agency_name', '') for route in routes]


if __name__ == "__main__":
    lat = -12.100345
    lng = -77.042943

    ne = {
        'lat': lat + 0.05,
        'lon': lng + 0.05
    }
    sw = {             
        'lat': lat - 0.05,
        'lon': lng - 0.05
    }
    stops = get_stops_in_range(ne, sw)