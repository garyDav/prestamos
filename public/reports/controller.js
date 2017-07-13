// ================================================
//   Controlador de prestamos
// ================================================
angular.module('reportModule').controller('reportCtrl', ['$scope','reportService', function($scope,reportService){

	$scope.activar('mReport','','Reportes','tus reportes');

	$scope.rgives = [];
	$scope.rmes = [];
	$scope.tot_cap = 0;
	$scope.tot_int = 0;
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

	$scope.mostrarModal = function( month,form ){

		reportService.cargarReporteMes(month).then(function(response) {
			$scope.rmes = response;
			$scope.tot_cap = reportService.tot_cap;
	      	$scope.tot_int = reportService.tot_int;
	      	console.log($scope.tot_cap);
	      	console.log($scope.tot_int);
			console.log($scope.rmes);
			$("#modal_report").modal();
		});

	};

	$scope.moverA(1);

}]);
