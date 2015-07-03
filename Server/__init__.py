from flask import Flask,  render_template, request, json
from flask.ext.mongoengine import MongoEngine

app = Flask(__name__)
app.config["MONGODB_SETTINGS"] = {'DB': "snipsdb"}
app.config["SECRET_KEY"] = "SKSNIps172015"

db = MongoEngine(app)

if __name__ == '__main__':
    app.run()
    
def register_blueprints(app):
    # Prevents circular imports
    from Server.views import logs
    app.register_blueprint(logs)

register_blueprints(app)



@app.route("/json", methods=['GET','POST','PUT'])
def json():
    from Server.models import *
    app.logger.debug("JSON received...")
    if request.json:
        newLogs=request.json.get("data")
        for log in newLogs:
            logObject= SLog(
                date=log["date"],
                functionName=log["functionName"],
                logLevel=log["logLevel"],
                fileName=log["fileName"],
                lineNumber=log["lineNumber"],
                threadName=log["threadName"],
                message=log["message"]
                )
            logObject.save()
        return "JSON Received"
 
    else:
        return "no json received"
