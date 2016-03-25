angular.module('jornadaib.services', ['ngResource'])
// .factory('Trabalho', function($resource) {
//   return $resource("http://localhost:3000/trabalhos/:id", {id: '@id'}, {
//     update: {
//       method: 'PUT'
//     }  
//   });
// })
// .factory('User', function($resource) {
//   return $resource("http://localhost:3000/users/:id", {id: '@id'}, {
//     update: {
//       method: 'PUT'
//     }
//   });
// })
// .factory('Useredit', function($resource) {
//   return $resource("http://localhost:3000/users/:id", {id: '@id'}, {
//     update: {
//       method: 'PUT'
//     }
//   });
// })
.service('popupService',function($window){
  this.showPopup=function(message){
    return $window.confirm(message);
  }
});