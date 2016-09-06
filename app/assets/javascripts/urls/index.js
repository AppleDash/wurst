var urlsApp = angular.module("urlsApp", []);

urlsApp.filter('trust', [
    '$sce',
    function($sce) {
        return function(url) {
            return $sce.trustAsResourceUrl(url);
        }
    }
]);

urlsApp.controller('UrlsListController', ['$scope', '$http', function($scope, $http) {
    $scope.urls = [];
    $scope.currentUrl = null;

    $scope.init = function() {
        $http.get('/api/urls').then(function(data) {
            $scope.urls = data.data;
            $scope.currentUrl = $scope.urls[0];
        }, function(err) {
            console.log(err);
        });
    };

    $scope.loadUrl = function(url) {
        $scope.currentUrl = url;
    };

    $scope.truncate = function(string, max_chars) {
        if (string.length <= max_chars + 3) {
            return string;
        }

        return string.substring(0, max_chars) + "...";
    };
}]);
