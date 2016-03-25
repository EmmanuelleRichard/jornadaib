angular.module('jornadaib.factories', ['ngResource', 'ngCachedResource'])
.factory('Trabalho', function($resource, $cachedResource) {
  // return $resource("http://localhost:3000/trabalhos/:id", {id: '@id'}, {
  return $cachedResource('trabalhos', "http://localhost:3000/trabalhos/:id", {id: '@id'}, {
    update: {
      method: 'PUT'
    }  
  });
})
.factory('User', function($resource) {
  return $resource("http://localhost:3000/users/:id", {id: '@id'}, {
    update: {
      method: 'PUT'
    }
  });
})
.factory('Useredit', function($resource) {
  return $resource("http://localhost:3000/users/:id", {id: '@id'}, {
    update: {
      method: 'PUT'
    }
  });
})