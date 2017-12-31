# coding: utf-8

from flask import Flask, render_template, flash, redirect, request
from flask_googlemaps import GoogleMaps
from flask_googlemaps import Map, icons
from app.forms import StopForm
from config import Config
import app.db as db
import app.aux as aux


app = Flask(__name__, template_folder="templates")

# you can set key as config
# app.config['GOOGLEMAPS_KEY'] = "AIzaSyAZzeHhs-8JZ7i18MjFuM35dJHq70n3Hx4"
app.config.from_object(Config)

# you can also pass key here
GoogleMaps(app, key="AIzaSyAZzeHhs-8JZ7i18MjFuM35dJHq70n3Hx4")


@app.route('/new', methods=['GET', 'POST'])
def registerStop():
    form = StopForm()

    if form.validate_on_submit():
        flash('Guardo empresa {} para la posicion {}'.
              format(form.company.data, form.position.data))
        return redirect('/')

    center = {'lat': -12.100345, 'lon': -77.042943}

    movingmap = Map(
        identifier="movingmap",
        varname="movingmap",
        lat=center['lat'],
        lng=center['lon'],
        style=(
            "height:100%;"
            "width:100%;"
            "top:0;"
            "left:0;"
            "position:absolute;"
            "z-index:200;"
        ),
        zoom=14,
        click_listener="map_on_click"
    )

    return render_template('new.html',
                           movingmap=movingmap,
                           form=form)


@app.route('/', methods=['GET'])
def queryMap():
    form = StopForm()

    center = {'lat': -12.100345, 'lon': -77.042943}
    company = request.args.get('company', default='*', type=str)
    stops = db.get_stops_around_center(center, 0.05)
    markers_dict = aux.filter_dictionary(stops, {'lat': 'lat', 'lon': 'lng'})
    routes = {stop: list(set(db.get_stop_routes(stop))) for stop in stops}
    routes_clean = {k: [aux.clean_chars(lv, add_chars="") for lv in v]
                    for k, v in routes.items()}
    company_name = ""
    if company != "*":
        company_name = aux.clean_chars(db.search_company(company), add_chars="")
    routes_stops = list(routes_clean.keys())
    if company_name != "":
        routes_stops = [key for key, value in routes_clean.items()
                        if company_name in value]
    info = {stop: "<br>".join(routes[stop]) for stop in routes_stops}
    for key, value in info.items():
        markers_dict[key]['infobox'] = value
    markers_dict = {k: v for k, v in markers_dict.items()
                    if 'infobox' in v}

    movingmap = Map(
        identifier="movingmap",
        varname="movingmap",
        lat=center['lat'],
        lng=center['lon'],
        style=(
            "height:100%;"
            "width:100%;"
            "top:0;"
            "left:0;"
            "position:absolute;"
            "z-index:200;"
        ),
        markers=list(markers_dict.values()),
        zoom=14
    )

    return render_template('index.html', movingmap=movingmap, form=form)


@app.route('/fullmap')
def fullmap():
    fullmap = Map(
        identifier="fullmap",
        varname="fullmap",
        style=(
            "height:100%;"
            "width:100%;"
            "top:0;"
            "left:0;"
            "position:absolute;"
            "z-index:200;"
        ),
        lat=37.4419,
        lng=-122.1419,
        markers=[
            {
                'icon': '//maps.google.com/mapfiles/ms/icons/green-dot.png',
                'lat': 37.4419,
                'lng': -122.1419,
                'infobox': "Hello I am <b style='color:green;'>GREEN</b>!"
            },
            {
                'icon': '//maps.google.com/mapfiles/ms/icons/blue-dot.png',
                'lat': 37.4300,
                'lng': -122.1400,
                'infobox': "Hello I am <b style='color:blue;'>BLUE</b>!"
            },
            {
                'icon': icons.dots.yellow,
                'title': 'Click Here',
                'lat': 37.4500,
                'lng': -122.1350,
                'infobox': (
                    "Hello I am <b style='color:#ffcc00;'>YELLOW</b>!"
                    "<h2>It is HTML title</h2>"
                    "<img src='//placehold.it/50'>"
                    "<br>Images allowed!"
                )
            }
        ],
        # maptype = "TERRAIN",
        # zoom="5"
    )
    return render_template('example_fullmap.html', fullmap=fullmap)


if __name__ == "__main__":
    app.run(debug=True, use_reloader=True)
