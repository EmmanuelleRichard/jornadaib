angular.module('jornadaib.controllers')
.controller('TrabalhoShowController', function($scope, $stateParams, Trabalho, $state, popupService) {
  	$scope.trabalho = Trabalho.get({ id: $stateParams.id }); //Get a single produto.Issues a GET to /api/movies/:id
  	if(!$scope.trabalho.$resolved){
		$scope.trabalho.$promise.then(function(data) {  	    
	   	});
	};

	$scope.deleteTrabalho = function(trabalho) { // Delete a movie. Issues a DELETE to /api/movies/:id
		if (popupService.showPopup('Deseja realmente excluir?')) {
			trabalho.$delete(function() {
				// alert('Gravado com sucesso');
	      		$state.go('/');
			});
		}
	};	
})
.controller('TrabalhoCreateController', function($scope, $state, $stateParams, Trabalho, $location) {
  	$scope.trabalho = new Trabalho();  //create new movie instance. Properties will be set via ng-model on UI

  	$scope.createTrabalho = function() { //create a new movie. Issues a POST to /api/movies
	    $scope.trabalho.$save(function(data) {
	    	console.log('gravou');
	    	console.log(data);
	    	console.log(data.trabalho);
	    	console.log(data.trabalho);

	      	// alert('Gravado com sucesso');
	      	$location.path('/trabalhos/'+data.trabalho.id);
	    });
  	};
})

.controller('TrabalhoEditController', function($scope, $state, $stateParams, Trabalho) {
	$scope.updateTrabalho = function() { //Update the edited produto. Issues a PUT to /api/movies/:id
	  	console.log('TrabalhoEditController.updateTrabalho');
	  	console.log($scope);
	  	console.log($scope.trabalho);
	    $scope.trabalho.$update(function() {
	    	console.log('atualizou');
	      	
	      	alert('Gravado com sucesso');
	      	$scope.trabalho = Trabalho.get({ id: $stateParams.id });
	    });
	};
  	$scope.loadTrabalho = function() { //Issues a GET request to /api/movies/:id to get a produto to update
	    console.log('loadTrabalho.entrou');
		$scope.trabalho = Trabalho.get({ id: $stateParams.id }, function () {
		});
	};

	$scope.loadTrabalho(); // Load a produto which can be edited on UI
	$scope.controller_name='TrabalhoEditController';
})

// .controller('TrabalhoDeleteController', function($scope, $state, $stateParams, Trabalho, $location) {
// 	$scope.delete = function( index, confirmation ){
// 	     confirmation = (typeof confirmation !== 'undefined') ? confirmation : true;
// 	     if (confirmDelete(confirmation)) {
// 	       var message,
// 	           item = TrabalhoDeleteController.delete(index);
// 	       if (!!item) {
// 	         message = 'Trabalho "' + item.name + '" with id "' + item._id+ '" was removed of your contact\'s list';
// 	         AlertService.add('success', message, 5000);
// 	         $scope.listContacts = TrabalhoDeleteController.getListItems();
// 	         return true;
// 	       }
// 	       AlertService.add('error', 'Houston, we have a problem. This operation cannot be executed correctly.', 5000);
// 	       return false;
// 	     }
// 	   };
// 	   var confirmDelete = function(confirmation){
// 	     return confirmation ? confirm('This action is irreversible. Do you want to delete this contact?') : true;
// 	   };
	  	
// 	$scope.loadTrabalho = function() { //Issues a GET request to /api/movies/:id to get a produto to update
// 	    console.log('loadTrabalho.entrou');
// 		$scope.trabalho = Trabalho.get({ id: $stateParams.id }, function () {
// 		});
// 	};

// 	$scope.loadTrabalho(); // Load a produto which can be edited on UI
// 	$scope.controller_name='TrabalhoDeleteController';
// })