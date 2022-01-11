from flask import Flask
import mysql.connector

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

  
if __name__ == "__main__":
    app.run(host ='0.0.0.0', port = 5001, debug = True)