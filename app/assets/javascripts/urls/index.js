var urlsApp = angular.module("urlsApp", ['angularUtils.directives.dirPagination']);

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
    $scope.error = null;
    $scope.totalUrls = 0;

    $scope.init = function() {
        $http.get('/api/urls?page=' + $scope.currentPage + '&per_page=' + $scope.perPage).then(function(data) {
            $scope.urls = data.data.urls;
            $scope.totalUrls = data.total;
            $scope.currentUrl = $scope.urls[0];
            $scope.error = null;
        }, function(err) {
            $scope.error = err;
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

    $scope.pageChanged = function(page) {
        $scope.currentPage = page;
        $scope.init();
    };

    $scope.truncate = function(string, max_chars) {
        if (string.length <= max_chars + 3) {
            return string;
        }

        return string.substring(0, max_chars) + "...";
    };
}]);
