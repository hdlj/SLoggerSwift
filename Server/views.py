from flask import Blueprint, request, redirect, render_template, url_for
from flask.views import MethodView
from Server.models import SLog

logs = Blueprint('logs', __name__, template_folder='templates')


class ListView(MethodView):

    def get(self):
        logs = SLog.objects.all()
        return render_template('logs/list.html', logs=logs)




# Register the urls
logs.add_url_rule('/', view_func=ListView.as_view('list'))
