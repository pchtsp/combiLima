from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField, SelectField
from wtforms.validators import DataRequired
import app.db as db


class StopForm(FlaskForm):
    company = SelectField('Empresa', choices=db.get_companies(), validators=[])
    position = StringField('Position', validators=[DataRequired()])
    # remember_me = BooleanField('Remember Me')
    submit = SubmitField('Guardar')