# coding: utf-8

from flask import Flask, render_template, flash, redirect
from flask_googlemaps import GoogleMaps
from flask_googlemaps import Map, icons
from app.forms import StopForm
from config import Config


app = Flask(__name__, template_folder="templates")

# you can set key as config
# app.config['GOOGLEMAPS_KEY'] = "AIzaSyAZzeHhs-8JZ7i18MjFuM35dJHq70n3Hx4"
app.config.from_object(Config)

# you can also pass key here
GoogleMaps(app, key="AIzaSyAZzeHhs-8JZ7i18MjFuM35dJHq70n3Hx4")


@app.route('/', methods=['GET', 'POST'])
def mapview():
    form = StopForm()

    if form.validate_on_submit():
        flash('Guardo empresa {} para la posicion {}'.
              format(form.company.data, form.position.data))
        return redirect('/')

    movingmap = Map(
        identifier="movingmap",
        varname="movingmap",
        lat=-12.100345,
        lng=-77.042943,
        style=(
            "height:100%;"
            "width:100%;"
            "top:0;"
            "left:0;"
            "position:absolute;"
            "z-index:200;"
        ),
        markers=[
            {
                'lat': -12.100345,
                'lng': -77.042943,
                'draggable': 'true'

            }
        ],
        zoom=12,
        click_listener="map_on_click"
    )

    return render_template('index.html',
                           movingmap=movingmap,
                           form=form)


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
