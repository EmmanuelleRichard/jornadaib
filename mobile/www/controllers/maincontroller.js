angular.module('jornadaib.controllers')
.controller('MainCtrl', [
	'$scope',
	// 'Produto',
	'Trabalho',
	// 'CONFIG',
	'Upload',
	// '$window',
	// function ($scope, Produto, Trabalho, CONFIG, Upload, $auth) {
	function ($scope, Trabalho, CONFIG, Upload, $auth, $stateParams) {
		window.validateUser = function() {
			return $auth.validateUser();
		};
		
		// $scope.signedIn = false;
	    // $scope.produtos=[
	    //   {
	    //     href: "http://poupeagora.com.br/hidratacao-matrix--escova-modeladora", 
	    //     src: "rick/temp/oferta-636-principal-532.jpeg",
	    //     ofertadescricao: "até 75 % de desconto",
	    //     titulo: "Hidratação Matrix + Escova Modeladora",
	    //     ofertapreco: "de R$ 60,00",
	    //     ofertapor: "por até R$15,00",
	    //     ofertadesconto: "até 75 % de desconto",
	    //     estabelecimento: "Espaço X Coiffeur"
	    //   }
	    // ];   
	    
	    // Produto.query().$promise.then(function(response){
	    //   	$scope.produtos = response;
	    // });

	    Trabalho.query().$promise.then(function(response){
	      	$scope.trabalhos = response;
	    });	    
		$scope.CONFIG=CONFIG;
	   
	  	$scope.pesquisaTrabalho = function(form) { //Issues a GET request to /api/movies/:id to get a produto to update
		    // console.log('pesquisaTrabalho.entrou');
		    // console.log(form.pesquisa);

			$scope.trabalhos = Trabalho.query({ q: form.pesquisa }, function (data) {
				// console.log(data);
			});
		};	   
  	}
])
