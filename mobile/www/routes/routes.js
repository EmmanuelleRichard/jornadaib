angular.module('jornadaib.routes', ['ionic', 'jornadaib.services', 'jornadaib.factories', 'jornadaib.controllers', 'ngResource', 'ui.bootstrap', 'ui.router', 'ngFileUpload', 'ui.utils.masks', 'ng-token-auth', 'ipCookie', 'Devise'])
.config(function($stateProvider) {
  $stateProvider
  // MAIN ABSTRACT STATE, ALWAYS ON
  .state('index', {
    abstract: true,
    url: '/',
    templateUrl: 'views/trabalhos/index.html',
    controller: 'MainCtrl'
  })
  .state('null', { // state for showing all movies
    url: '',
    templateUrl: 'views/trabalhos/index.html',
    controller: 'MainCtrl'
  })  
  .state('/', { // state for showing all movies
    url: '',
    templateUrl: 'views/trabalhos/index.html',
    controller: 'MainCtrl'
  })
  .state('home', { //state for adding a new movie
    url: '/home',
    templateUrl: 'views/trabalhos/index.html',
    controller: 'MainCtrl'
  })  
  .state('creditos', { //state for adding a new movie
    url: '/creditos',
    templateUrl: 'views/index/creditos.html',
    controller: 'MainCtrl'
  })
  .state('mapa', { //state for adding a new movie
    url: '/mapa',
    templateUrl: 'views/index/mapa.html',
    controller: 'MainCtrl'
  })  
  .state('mapa1andar', { //state for adding a new movie
    url: '/mapa1andar',
    templateUrl: 'views/index/mapa1andar.html',
    controller: 'MainCtrl'
  })  
//Produto.inicio  
  // .state('newProduto', { //state for adding a new movie
  //   url: '/produtos/new',
  //   templateUrl: 'views/produtos/new.html',
  //   controller: 'ProdutoCreateController'
  // })
  // .state('editProduto', { //state for updating a movie
  //   url: '/produtos/:id/edit',
  //   templateUrl: 'views/produtos/edit.html',
  //   controller: 'ProdutoEditController'
  // })
  // .state('viewProduto', { //state for showing single movie
  //   url: '/produtos/:id',
  //   templateUrl: 'views/produtos/show.html',
  //   controller: 'ProdutoViewController'
  // })  
//Produto.fim
//Trabalho.inicio
  .state('newTrabalho', { //state for adding a new movie
    url: '/trabalhos/new',
    templateUrl: 'views/trabalhos/new.html',
    controller: 'TrabalhoCreateController'
  })
  
  .state('editTrabalho', { //state for updating a movie
    url: '/trabalhos/:id/edit',
    templateUrl: 'views/trabalhos/edit.html',
    controller: 'TrabalhoEditController'
  })
  .state('showTrabalho', { //state for showing single movie
    url: '/trabalhos/:id',
    templateUrl: 'views/trabalhos/show.html',
    controller: 'TrabalhoShowController',
    onEnter: ['$state', function($state, $auth) {
      console.log('onEnterLogin');
      console.log('onshowTrabalho');
    }]
  })  
//Trabalho.fim
  .state('login', {
    url: '/login',
    templateUrl: 'views/users/login.html',
    controller: 'UserCtrl',
    onEnter: ['$state', function($state, $auth) {
      console.log('onEnterLogin');
    }]
  })
  .state('logout', {
    url: '/logout',
    templateUrl: 'views/users/logout.html',
    controller: 'UserCtrl',
    onEnter: ['$state', function($state, $auth) {
      console.log('onEnterLogout');
    }]
  })  
  .state('editUser', {
    url: '/editUser',
    templateUrl: 'views/users/edit.html',
    controller: 'UserEditController',
    onEnter: ['$state', function($state, $auth) {
    // onEnter: ['$state', 'Auth', function($state, Auth) {      
      console.log('onEnterEdit');
      // console.log($auth);
    }]
  })  
  .state('newUser', {
    url: '/newUser',
    // templateUrl: 'views/users/_register.html',
    templateUrl: 'views/users/new.html',
    controller: 'UserCtrl',
    onEnter: ['$state', 'Auth', function($state, Auth) {
      console.log('register');
      Auth.currentUser().then(function (){
        $state.go('/');
      })
    }]
  })  
})