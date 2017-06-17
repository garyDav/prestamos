// ================================================
//   Controlador de prestamos
// ================================================
angular.module('giveModule').controller('giveCtrl', ['$scope','giveService', function($scope,giveService){

	$scope.activar('mGives','','Prestamos','listado');

	$scope.gives   = {};
	$scope.giveSel = {};
	$scope.prestamista = {};
	$scope.load = true;
	//console.log($scope.load);

	//Prestamo en el presente año
	var fec = new Date();
	$scope.fechaMin = ""+fec.getFullYear()+"-01-01";
	$scope.fechaMax = ""+fec.getFullYear()+"-12-31";


	giveService.cargarUsers().then( function( data ) {
		$scope.prestamista = data;
		console.log($scope.prestamista);
	} );

	giveService.cargarClients().then( function( data ) {
		$scope.cliente = data;
		console.log($scope.cliente);
	} );

	$scope.llenar_prestamista = function(give,id) {
		give.id_user = id;
	};
	$scope.llenar_cliente = function(give,id) {
		give.id_clients = id;
	};


	$scope.moverA = function( pag ){
		$scope.load = true;

		giveService.cargarPagina( pag ).then( function(){
			$scope.gives = giveService;
			$scope.load = false;
			console.log($scope.gives);
		});

	};

	$scope.moverA(1);

	// ================================================
	//   Mostrar modal de edicion
	// ================================================
	$scope.mostrarModal = function( data ){

		// console.log( data );
		angular.copy( data, $scope.giveSel );
		$("#modal_give").modal();

	}

	// ================================================
	//   Funcion para guardar
	// ================================================
	$scope.guardar = function( dataGive, frm){

		console.log(dataGive);
		giveService.guardar( dataGive ).then(function( data ){

			// codigo cuando se actualizo
			$("#modal_give").modal('hide');
			$scope.giveSel = {};

			frm.autoValidateFormOptions.resetForm();
			if( data.error == 'not' )
				swal("¡Correcto!", "ID: "+data.id+" "+data.msj, "success");
			else
				swal("¡Error!", data , "error");

		});

	};
	// ================================================
	//   Funcion para eliminar
	// ================================================
	$scope.eliminar = function( id ){

		swal({
			title: "¿Esta seguro de eliminar?",
			text: "¡Si confirma esta acción eliminará el registro!",
			type: "warning",
			showCancelButton: true,
			confirmButtonColor: "#DD6B55",
			confirmButtonText: "Si, Eliminar!",
			closeOnConfirm: false
		},
		function(){
			giveService.eliminar( id ).then(function( data ){
				if( data.error == 'not' )
					swal("Eliminado!", "ID: "+data.id+" "+data.msj, "success");
				else
					swal("Error!", data , "error");
			});
		});

	}

}]);
