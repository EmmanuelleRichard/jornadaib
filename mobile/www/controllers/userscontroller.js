angular.module('jornadaib.controllers')
.controller('UserCtrl', function($scope, $auth, $state) {
	$scope.$on('auth:login-success', function(ev, data) {
		console.log('auth:login-success.entrou');
		// console.log($auth);
		// console.log(data);
		// console.log(data.signedIn);
		// console.log(data.user);
	    // alert('Welcome ', user.email);
		
		$scope.signedIn = data.signedIn;
		$scope.logout = !data.signedIn;
		$scope.user = data.user;
	    
	    console.log($scope.user);
	    // alert('Welcome ');
	    $state.go('/');
	    // $location.path('/');
	});
	$scope.$on('auth:login-error', function(ev, reason) {
		// console.log(reason);
	    alert('Erro: '+reason.errors[0]);
	});

	$scope.$on('auth:logout-success', function(ev) {
		console.log('auth:logout-success.entrou');
		$scope.signedIn = null;
		// $scope.logout = !data.signedIn;
		$scope.user = null;
	    
	    console.log($scope.user);
	    $state.go('/');
	});	

	$scope.$on('auth:validation-success', function(ev, data) {
		// console.log('auth:validation-success.entrou');
		// console.log($auth);
		// console.log(data);
		// console.log(data.signedIn);
		// console.log(data.user);
	    // alert('Welcome ', user.email);
		
		$scope.signedIn = data.signedIn;
		$scope.logout = !data.signedIn;
		$scope.user = data.user;
	    
	    console.log($scope.user);
	    // alert('Welcome ');
	    // $state.go('/');
	    // $location.path('/');
	});	
    // $scope.handleRegBtnClick = function() {
    //   $auth.submitRegistration($scope.registrationForm)
    //     .then(function(resp) {
    //       // handle success response
	   //  	console.log('gravou');
	   //  	console.log(resp);

	   //    	alert('Gravado com sucesso');
	   //    	$location.path('/login');
    //     })
    //     .catch(function(resp) {
    //       // handle error response
    //       console.log('erro');
    //     });
    // };
	$scope.$on('auth:registration-email-success', function(ev, data) {
		console.log('auth:registration-email-success');
		console.log($auth);
		console.log(data);
		console.log(ev);
		console.log($scope.signedIn);
		console.log(data.user);
	    // alert('Welcome ', user.email);
	    
	    // console.log($scope.user);
	    if($scope.signedIn){
	    	alert('alterado com sucesso')
	    }
	    else{
		    alert('criou ');
		    $state.go('login');	    	
	    }
	});    	
	$scope.$on('auth:registration-email-error', function(ev, reason) {
		console.log(reason);
		console.log(reason.errors);
		console.log(reason.errors.full_messages);
	    alert("Erro(s): " + reason.errors.full_messages);
	});
})
.controller('UserEditController', function($scope, $state, $auth) {
    // $scope.handleUpdateAccountBtnClick = function() {
    // 	console.log('handleUpdateAccountBtnClick');
	   //  $auth.updateAccount($scope.user)
	   //      .then(function(resp) {
	   //        // handle success response
	   //        console.log('handle success response')
	   //      })
	   //      .catch(function(resp) {
	   //        console.log('handle error response')
	   //      });
    // };	
  	$scope.loadUser = function() { //Issues a GET request to /api/movies/:id to get a produto to update

	    $scope.useredit=$scope.user.user;
	    $scope.user=$scope.user.user;

	};

	$scope.loadUser(); // Load a produto which can be edited on UI
	
	$scope.controller_name='UserEditController';
})
