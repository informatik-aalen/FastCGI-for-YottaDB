var app = angular.module('ajaxApp', []);
app.controller('Controller', function($scope, $http) {
    var c = this;
    var uri = "/ydb/EXANGULARJS/";

    c.send = function() {
        $http.put(uri+c.id,c.address).then(function (response) {
            c.savetext = JSON.stringify(response.data);
            setTimeout(function(){
                c.savetext = ""; $scope.$apply();
            }, 2500);
        });
    };

    c.load = function() {
        $http.get(uri+c.id).then(function (response) {
            c.address =(response.data);
        });
    };
});
