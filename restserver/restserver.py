from flask import Flask
import mysql.connector
import os

app = Flask(__name__)
mydb = mysql.connector.connect(
  host="localhost",
  user="newuser",
  password="root_password",
  database="fakeapi"
)
mycursor = mydb.cursor()
  
@app.route('/')
def hello():
    return "Welcome to Appsmithted"

@app.route('/health',methods = ['POST', 'GET'])
def health():
    return "I am healthy2"

@app.route('/mysql/health',methods = ['POST', 'GET'])
def mysql_health():
    mycursor.execute("SELECT * FROM users")
    myresult = mycursor.fetchall()
    return myresult.__str__()

@app.route('/killmysql',methods = ['GET'])
def kill_mysql():
    os.system("kill $(ps -ef |grep mysqld|grep -v grep |awk '{print $2}')")
    return "killed"

  
if __name__ == "__main__":
    app.run(host ='0.0.0.0', port = 5001, debug = True)