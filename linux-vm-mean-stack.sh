#azure cli

#create an Ubuntu VM.

az vm create \
  --resource-group learn-3a1cc2f0-f8af-4745-9996-1e6d2cb106dc \
  --name MeanStack \
  --image Canonical:UbuntuServer:16.04-LTS:latest \
  --admin-username azureuser \
  --generate-ssh-keys

#Open port 80 on the VM to allow incoming HTTP traffic to the web application you'll later create.

az vm open-port \
  --port 80 \
  --resource-group learn-3a1cc2f0-f8af-4745-9996-1e6d2cb106dc \
  --name MeanStack

#store iP address as variable to connect 

ipaddress=$(az vm show \
  --name MeanStack \
  --resource-group learn-3a1cc2f0-f8af-4745-9996-1e6d2cb106dc \
  --show-details \
  --query [publicIps] \
  --output tsv)

#connect to ip address ssh

ssh azureuser@$ipaddress

#update ubuntu vm, once connected

sudo apt update && sudo apt upgrade -y

#install mongodb

sudo apt-get install -y mongodb

#check status of mongodb

sudo systemctl status mongodb

#check mongodb version

mongod --version

#register node.js repo

curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

#install node.js

sudo apt install nodejs

#exit ssh session

exit

#create the files and folders for the web app in the cloud shell

cd ~
mkdir Books
touch Books/server.js
touch Books/package.json
mkdir Books/app
touch Books/app/model.js
touch Books/app/routes.js
mkdir Books/public
touch Books/public/script.js
touch Books/public/index.html

#open books dir in VS Code

code Books

#open app/model.js and add the following.

var mongoose = require('mongoose');
var dbHost = 'mongodb://localhost:27017/Books';
mongoose.connect(dbHost, { useNewUrlParser: true } );
mongoose.connection;
mongoose.set('debug', true);
var bookSchema = mongoose.Schema( {
    name: String,
    isbn: {type: String, index: true},
    author: String,
    pages: Number
});
var Book = mongoose.model('Book', bookSchema);
module.exports = Book;

#open app/routes.js and add the following code.

var path = require('path');
var Book = require('./model');
var routes = function(app) {
    app.get('/book', function(req, res) {
        Book.find({}, function(err, result) {
            if ( err ) throw err;
            res.json(result);
        });
    });
    app.post('/book', function(req, res) {
        var book = new Book( {
            name:req.body.name,
            isbn:req.body.isbn,
            author:req.body.author,
            pages:req.body.pages
        });
        book.save(function(err, result) {
            if ( err ) throw err;
            res.json( {
                message:"Successfully added book",
                book:result
            });
        });
    });
    app.delete("/book/:isbn", function(req, res) {
        Book.findOneAndRemove(req.query, function(err, result) {
            if ( err ) throw err;
            res.json( {
                message: "Successfully deleted the book",
                book: result
            });
        });
    });
    app.get('*', function(req, res) {
        res.sendFile(path.join(__dirname + '/public', 'index.html'));
    });
};
module.exports = routes;

#open public/script.js and add this code:

var app = angular.module('myApp', []);
app.controller('myCtrl', function($scope, $http) {
    var getData = function() {
        return $http( {
            method: 'GET',
            url: '/book'
        }).then(function successCallback(response) {
            $scope.books = response.data;
        }, function errorCallback(response) {
            console.log('Error: ' + response);
        });
    };
    getData();
    $scope.del_book = function(book) {
        $http( {
            method: 'DELETE',
            url: '/book/:isbn',
            params: {'isbn': book.isbn}
        }).then(function successCallback(response) {
            console.log(response);
            return getData();
        }, function errorCallback(response) {
            console.log('Error: ' + response);
        });
    };
    $scope.add_book = function() {
        var body = '{ "name": "' + $scope.Name +
        '", "isbn": "' + $scope.Isbn +
        '", "author": "' + $scope.Author +
        '", "pages": "' + $scope.Pages + '" }';
        $http({
            method: 'POST',
            url: '/book',
            data: body
        }).then(function successCallback(response) {
            console.log(response);
            return getData();
        }, function errorCallback(response) {
            console.log('Error: ' + response);
        });
    };
});

#From the editor, open public/index.html and add this code:

<!doctype html>
<html ng-app="myApp" ng-controller="myCtrl">
<head>
    <script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.7.2/angular.min.js"></script>
    <script src="script.js"></script>
</head>
<body>
    <div>
    <table>
        <tr>
        <td>Name:</td>
        <td><input type="text" ng-model="Name"></td>
        </tr>
        <tr>
        <td>Isbn:</td>
        <td><input type="text" ng-model="Isbn"></td>
        </tr>
        <tr>
        <td>Author:</td>
        <td><input type="text" ng-model="Author"></td>
        </tr>
        <tr>
        <td>Pages:</td>
        <td><input type="number" ng-model="Pages"></td>
        </tr>
    </table>
    <button ng-click="add_book()">Add</button>
    </div>
    <hr>
    <div>
    <table>
        <tr>
        <th>Name</th>
        <th>Isbn</th>
        <th>Author</th>
        <th>Pages</th>
        </tr>
        <tr ng-repeat="book in books">
        <td><input type="button" value="Delete" data-ng-click="del_book(book)"></td>
        <td>{{book.name}}</td>
        <td>{{book.isbn}}</td>
        <td>{{book.author}}</td>
        <td>{{book.pages}}</td>
        </tr>
    </table>
    </div>
</body>
</html>

#From the editor, open server.js and add this code:

var express = require('express');
var bodyParser = require('body-parser');
var app = express();
app.use(express.static(__dirname + '/public'));
app.use(bodyParser.json());
require('./app/routes')(app);
app.set('port', 80);
app.listen(app.get('port'), function() {
    console.log('Server up: http://localhost:' + app.get('port'));
});

#From the editor, open package.json and add this code:

{
  "name": "books",
  "description": "Sample web app that manages book information.",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/MicrosoftDocs/mslearn-build-a-web-app-with-mean-on-a-linux-vm"
  },
  "main": "server.js",
  "dependencies": {
    "express": "~4.16",
    "mongoose": "~5.3",
    "body-parser": "~1.18"
  }
}

#Run the following scp command to copy the contents of the ~/Books directory in your Cloud Shell session to the same directory name on your VM.

scp -r ~/Books azureuser@$ipaddress:~/Books

#check IP address is stored as variable, otherwise reoeat earlier steps to obtain and store this

echo $ipaddress

#connect to VM and install node.js

ssh azureuser@$ipaddress
cd ~/Books
npm install

#may get an error that npm is not installed - install using

sudo apt install nodejs-legacy



