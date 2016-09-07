var urlsApp = angular.module("urlsApp", []);

urlsApp.directive('a', function() {
    return {
        restrict: 'E',
        link: function(scope, elem, attrs) {
            if(attrs.ngClick || attrs.href === '' || attrs.href === '#'){
                elem.on('click', function(e){
                    e.preventDefault();
                });
            }
        }
    };
});

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
    $scope.frameUrl = null;
    $scope.currentPage = 1;
    $scope.perPage = 15;

    $scope.init = function() {
        $http.get('/api/urls?page=' + $scope.currentPage + "&per_page=" + $scope.perPage).then(function(data) {
            $scope.urls = data.data.urls;
            $scope.maxPage = data.data.total / $scope.perPage;
            $scope.currentUrl = $scope.urls[0];
        }, function(err) {
            console.log(err);
        });
    };

    $scope.loadUrl = function(url) {
        $scope.currentUrl = url;
        $scope.frameUrl = url.url;
    };

    $scope.loadOther = function(url) {
        $scope.frameUrl = url;
    };

    $scope.screenshotUrl = function(url) {
        return "/system/urls/" + url.id + "/screenshot.png";
    };

    $scope.pageForward = function() {
        $scope.currentPage++;

        if ($scope.currentPage > $scope.maxPage) {
            $scope.currentPage = $scope.maxPage;
        }

        $scope.init();
    };

    $scope.pageBack = function() {
        $scope.currentPage--;

        if ($scope.currentPage < 1) {
            $scope.currentPage = 1;
        }

        $scope.init();
    };

    $scope.truncate = function(string, max_chars) {
        if (string.length <= max_chars + 3) {
            return string;
        }

        return string.substring(0, max_chars) + "...";
    };
}]);
