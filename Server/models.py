
from SnipsServer import db

class SLog(db.Document):
    date=db.StringField()
    functionName= db.StringField()
    message= db.StringField()
    logLevel=db.StringField()
    fileName=db.StringField()
    lineNumber=db.StringField()
    threadName=db.StringField()
    
