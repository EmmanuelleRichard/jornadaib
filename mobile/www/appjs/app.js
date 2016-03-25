// Ionic Starter App

// angular.module is a global place for creating, registering and retrieving Angular modules
// 'starter' is the name of this angular module example (also set in a <body> attribute in index.html)
// the 2nd parameter is an array of 'requires'

angular.module('jornadaib', []);

angular.module('jornadaib', ['ionic', 'jornadaib.services', 'jornadaib.factories', 'jornadaib.controllers', 'jornadaib.routes', 'ngResource', 'ui.bootstrap', 'ui.router', 'ngFileUpload', 'ui.utils.masks', 'ng-token-auth', 'ipCookie', 'wiz.validation', 'ngMessages', 'ngCachedResource'])

.run(function($ionicPlatform, $state) {
  $ionicPlatform.ready(function() {
    // Hide the accessory bar by default (remove this to show the accessory bar above the keyboard
    // for form inputs)
    if(window.cordova && window.cordova.plugins.Keyboard) {
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true);
    }
    if(window.StatusBar) {
      StatusBar.styleDefault();
    }
    $state.go('/'); //make a transition to movies state when app starts
  });
})
.config(function($authProvider) {
  $authProvider.configure({
    apiUrl: 'http://localhost:3000',
    // storage:'localStorage',
    handleLoginResponse: function (response) {
      return response.data;
    }
  });
})

// .constant('CONFIG', {
//   // APIURL: "http:apiurl.com/api",
//   // HOMEPATH: "#/home",
//   Produtoinfluenciapreco_codigo_substituicao: "1",
//   Produtoinfluenciapreco_codigo_adicao: "2",
//   Produtoinfluenciapreco_codigo_subtracao: "3"
// })

.directive('directivemoveuprow', function(){
  return {
    restrict: 'A',
    scope: true,
    template: "<span style='cursor: pointer;' ><i class='fa fa-arrow-up' ng-click='moveuprowclick()'></i></span>",
    replace: true,    
    // bindToController: true,
    controller: function($scope, $element, $timeout){
    // link: function($scope, $element, attrs) {
      $scope.moveuprowclick = function(){
        // console.log($element.parent().parent().parent());

        var row =$element.parent().parent().parent();

        var parent = row.parent();
        var children = parent.children();

        var vprev;
        for (var i = 1; i < children.length; i++){
          if (children[i] === row[0]) {
            vprev = children[i-1];
          }
        };
        $(row).after(vprev);
      }; 
    }
  }
})

.directive('directivemovedownrow', function(){
    return {
        restrict: 'A',
        scope: true,
        template: "<span style='cursor: pointer;' ><i class='fa fa-arrow-down' ng-click='movedownrowclick()'></i></span>",
        replace: true,    
        controller: function($scope, $element){
            $scope.movedownrowclick = function(){
                var row =$element.parent().parent().parent();

                var parent = row.parent();
                var children = parent.children();

                var vnext;
                for (var i = 0; i < children.length-1; i++){
                  if (children[i] === row[0]) {
                    vnext = children[i+1];
                  }
                }
                $(vnext).after(row);
            }      
        }
    }
})
.directive('directiveuploadfile', function(){
    return function($scope, $element, $attrs) {
        $element.bind('change', function() {
            if ($attrs.$$element[0] && $attrs.$$element[0].files[0]) {
                var reader = new FileReader();
                reader.onload = function (e) {
                    // $('#photo-id').attr('src', e.target.result).attr('ng-src', e.target.result);
                    $('#photo-id').attr('src', e.target.result);
                    var base64Image = $('#photo-id').attr('src');
                    $scope.produto.picture = base64Image; //.replace(/data:image\/jpeg;base64,/g, '');
                }
                //Renders Image on Page
                // reader.readAsDataURL($element.files[0]);
                reader.readAsDataURL($attrs.$$element[0].files[0]);
            }          
        });
    };    
})


.filter('newlines',function() {
    return function(input) {
        if (input) {
            return input.replace(/,/g, '<br/>');    
        }
    }
});