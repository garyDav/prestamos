angular.module('reportModule').factory('reportService', ['$http','$rootScope', '$q', function($http, $rootScope, $q){

	var self = {

		'cargando'		: false,
		'err'     		: false, 
		'conteo' 		: 0,
		'give' 			: [],
		'pag_actual'    : 1,
		'pag_siguiente' : 1,
		'pag_anterior'  : 1,
		'total_paginas' : 1,
		'paginas'	    : [],
		'tot_cap'       : 0,
		'tot_int'       : 0,

		cargarPagina: function( pag ){

			var d = $q.defer();

			$http.get('rest/v1/give/reports/' + pag + '/'+ $rootScope.userID )
				.success(function( data ){
					//console.log( data );
					if(data) {
						data.gives.forEach(function(element,index,array) {
							var values = element.fec_pre.split("-");
							element.fec_pre = new Date(Number(values[0]), Number(values[1]-1), Number(values[2]));
						});

						self.err           = data.err;
						self.conteo        = data.conteo;
						self.give          = data.gives;
						self.pag_actual    = data.pag_actual;
						self.pag_siguiente = data.pag_siguiente;
						self.pag_anterior  = data.pag_anterior;
						self.total_paginas = data.total_paginas;
						self.paginas       = data.paginas;

					}
					return d.resolve();
				});

			return d.promise;
		},

		hiddenGive: function(id) {
			swal({
				title: "¿Esta seguro de ocultar?",
				text: "¡Si confirma esta acción ocultará el prestamo!",
				type: "warning",
				showCancelButton: true,
				confirmButtonColor: "#DD6B55",
				confirmButtonText: "Si, Ocultar!",
				closeOnConfirm: false
			},
			function(){
				$http.put('rest/v1/hiddenGive/'+id).success(function(response) {
					self.cargarPagina(self.pag_actual);
					if(response) {
						swal("CORRECTO", "¡"+"ID: "+response.id+" "+response.msj+"!", "success");
					}
				}).error(function(err) {
					console.error(err);
				});
			});
		},
		cargarReporteMes: function(mes) {
			var d = $q.defer();
			$http.get('rest/v1/give/reportsmonth/' + mes + '/'+ $rootScope.userID )
				.success(function( response ){
					if(response){
						console.log(response);
						self.tot_cap = 0;
						self.tot_int = 0;
						response.resultado.forEach(function(element,index,array) {
							self.tot_cap += Number(element.capital);
							self.tot_int += Number(element.interest);
						});
						d.resolve(response);
					}
						
				}).error(function(err) {
					console.log(err);
					d.reject(err);
				});

			return d.promise;
		}


	};

	return self;

}]);

