from flask import Flask, request,   jsonify
import mysql.connector
import os
from faker import Faker
# To create a json file
import json

# For student id
from random import randint

app = Flask(__name__)
mydb = mysql.connector.connect(
  host="localhost",
  user="newuser",
  password="root_password",
  database="fakeapi"
)
mycursor = mydb.cursor()
fake = Faker(['it_IT', 'en_US', 'ja_JP', 'es_ES', 'de_DE', 'ar_AA'])
student_data =[]

#Basic REST API
@app.route('/')
def hello():
    return "Welcome to Appsmith Ted"

#REST API Health Check
@app.route('/health',methods = ['POST', 'GET'])
def health():
    return "I am healthy"

#REST API to get all students
@app.route('/v1/mysql/health',methods = ['POST', 'GET'])
def mysql_health():
    mycursor.execute("SELECT * FROM users")
    myresult = mycursor.fetchall()
    return myresult.__str__()

#REST API to restart MySQL
@app.route('/v1/noise/killmysql',methods = ['GET'])
def kill_mysql():
    os.system("kill $(ps -ef |grep mysqld|grep -v grep |awk '{print $2}')")
    return "killed"

#REST API to add ssh key for git
@app.route('/v1/gitserver/addgitssh',methods = ['GET'])
def add_sshkey():
    sshkey = request.args.get("sshkey")
    os.system("echo '"+sshkey+"' >> /home/git/.ssh/authorized_keys")
    return sshkey

#Basic REST API to add git server
@app.route('/v1/gitserver/addrepo',methods = ['GET'])
def add_repo():
    reponame = request.args.get("reponame")
    os.system("cd /git-server/repos;mkdir '"+reponame+"';cd '"+reponame+"';git init --shared=true;git add .;git commit -m README;cd ..;git clone --bare '"+reponame+"' '"+reponame+"'.git")

    return "ssh://git@host.docker.internal:2222/git-server/repos/"+reponame+".git"

#Basic REST API generate n records
@app.route('/v1/dynamicrecords/generaterecords',methods = ['GET'])
def generate_records():
    records = int(request.args.get("records"))
    student_data.clear()
    for i in range(0, records):
        new_student_data = {}
        new_student_data['id'] = i + 1  # randint(1, 1000)
        new_student_data['name'] = fake.name()
        new_student_data['address'] = fake.address()
        new_student_data['latitude'] = str(fake.latitude())
        new_student_data['longitude'] = str(fake.longitude())
        new_student_data['phone'] = fake.phone_number()
        new_student_data['email'] = fake.email()
        new_student_data['company'] = fake.company()
        new_student_data['job'] = fake.job()
        new_student_data['image'] = fake.image_url()
        new_student_data['text'] = fake.text()
        new_student_data['ssn'] = fake.ssn()
        new_student_data['credit_card'] = fake.credit_card_number()
        new_student_data['iban'] = fake.iban()
        new_student_data['postalcode'] = fake.postalcode()
        student_data.append(new_student_data)
    return jsonify(records)

#Basic REST API to get all students
@app.route('/v1/dynamicrecords/getstudents',methods = ['GET'])
def get_students():
    page = request.args.get('page', 1, type=int)
    size = request.args.get('size', 100, type=int)
    start = (page - 1) * size
    end = start + size
    return jsonify(student_data[start:end])

if __name__ == "__main__":
    app.run(host ='0.0.0.0', port = 5001, debug = True)