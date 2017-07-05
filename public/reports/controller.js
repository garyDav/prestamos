// ================================================
//   Controlador de prestamos
// ================================================
angular.module('reportModule').controller('reportCtrl', ['$scope','reportService', function($scope,reportService){

	$scope.activar('mReport','','Reportes','tus reportes');

	$scope.rgives = [];
	$scope.load = false;

	$scope.moverA = function( pag ){
		$scope.load = true;

		reportService.cargarPagina( pag ).then(function() {
			$scope.rgives = reportService;
			$scope.load = false;
			console.log($scope.rgives);
		});

	};
	$scope.hiddenGive = function(id) {
		reportService.hiddenGive(id);
	};

	$scope.moverA(1);

}]);
