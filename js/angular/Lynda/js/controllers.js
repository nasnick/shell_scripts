var myApp = angular.module('myApp', []);

myApp.controller('MyController', function MyController($scope, $http) {
//create an object
$http.get('js/data.json').success(function() {
  $scope.artists = data;
  });
});