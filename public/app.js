(function(angular) {

	'use strict';
	var app = angular.module('prestamosModule',[
		'ngResource',
		'ngRoute',
		'angular-loading-bar',
		'jcs-autoValidate',
		'clientsModule',
		'giveModule',
		'graphicModule',
		'reportModule',
		'userModule'
	], ["$provide", function($provide) {
		var PLURAL_CATEGORY = {ZERO: "zero", ONE: "one", TWO: "two", FEW: "few", MANY: "many", OTHER: "other"};
		$provide.value("$locale", {
		  "DATETIME_FORMATS": {
		    "AMPMS": [
		      "a.m.",
		      "p.m."
		    ],
		    "DAY": [
		      "domingo",
		      "lunes",
		      "martes",
		      "mi\u00e9rcoles",
		      "jueves",
		      "viernes",
		      "s\u00e1bado"
		    ],
		    "MONTH": [
		      "enero",
		      "febrero",
		      "marzo",
		      "abril",
		      "mayo",
		      "junio",
		      "julio",
		      "agosto",
		      "septiembre",
		      "octubre",
		      "noviembre",
		      "diciembre"
		    ],
		    "SHORTDAY": [
		      "dom",
		      "lun",
		      "mar",
		      "mi\u00e9",
		      "jue",
		      "vie",
		      "s\u00e1b"
		    ],
		    "SHORTMONTH": [
		      "ene",
		      "feb",
		      "mar",
		      "abr",
		      "may",
		      "jun",
		      "jul",
		      "ago",
		      "sep",
		      "oct",
		      "nov",
		      "dic"
		    ],
		    "fullDate": "EEEE, d 'de' MMMM 'de' y",
		    "longDate": "d 'de' MMMM 'de' y",
		    "medium": "dd/MM/yyyy HH:mm:ss",
		    "mediumDate": "dd/MM/yyyy",
		    "mediumTime": "HH:mm:ss",
		    "short": "dd/MM/yy HH:mm",
		    "shortDate": "dd/MM/yy",
		    "shortTime": "HH:mm"
		  },
		  "NUMBER_FORMATS": {
		    "CURRENCY_SYM": "\u20ac",
		    "DECIMAL_SEP": ",",
		    "GROUP_SEP": ".",
		    "PATTERNS": [
		      {
		        "gSize": 3,
		        "lgSize": 3,
		        "macFrac": 0,
		        "maxFrac": 3,
		        "minFrac": 0,
		        "minInt": 1,
		        "negPre": "-",
		        "negSuf": "",
		        "posPre": "",
		        "posSuf": ""
		      },
		      {
		        "gSize": 3,
		        "lgSize": 3,
		        "macFrac": 0,
		        "maxFrac": 2,
		        "minFrac": 2,
		        "minInt": 1,
		        "negPre": "-",
		        "negSuf": "\u00a0\u00a4",
		        "posPre": "",
		        "posSuf": "\u00a0\u00a4"
		      }
		    ]
		  },
		  "id": "es-es",
		  "pluralCat": function (n) {  if (n == 1) {   return PLURAL_CATEGORY.ONE;  }  return PLURAL_CATEGORY.OTHER;}
		});
		}]).run([
        'bootstrap3ElementModifier',
        function (bootstrap3ElementModifier) {
              bootstrap3ElementModifier.enableValidationStateIcons(true);
       }]);



	angular.module('jcs-autoValidate')
	.run([
	    'defaultErrorMessageResolver',
	    function (defaultErrorMessageResolver) {
	        // To change the root resource file path
	        defaultErrorMessageResolver.setI18nFileRootPath('app/lib');
	        defaultErrorMessageResolver.setCulture('es-co');

	        defaultErrorMessageResolver.getErrorMessages().then(function (errorMessages) {
	          errorMessages['coincide'] = 'Su contraseña no coincide';
	          errorMessages['parse'] = 'Debe ingresar la nueva contraseña';
	        });
	    }
	]);

	app.directive('coincide', [
            function() {
                return {
                    restrict: 'A',
                    require: 'ngModel',
                    link: function(scope, elm, attrs, ctrl) {

                        var validateFn = function (viewValue) {
                        	if(attrs.coincide != '')
	                            if (ctrl.$isEmpty(viewValue) || viewValue.indexOf(attrs.coincide) === -1) {
	                                ctrl.$setValidity('coincide', false);
	                                return undefined;
	                            } else {
	                                ctrl.$setValidity('coincide', true);
	                                return viewValue;
	                            }
	                        /*else {
	                        	ctrl.$setValidity('parse', false);
	                        }*/
                        };

                        ctrl.$parsers.push(validateFn);
                        ctrl.$formatters.push(validateFn);
                    }
                };
            }]);

	app.config(['$locationProvider',function($locationProvider) {
		$locationProvider.html5Mode(true);
	}]);
	app.config(['cfpLoadingBarProvider',function(cfpLoadingBarProvider) {
		cfpLoadingBarProvider.includeSpinner = true;
	}]);

	app.config(['$routeProvider',function($routeProvider) {
		$routeProvider.
			when('/',{
				templateUrl: 'public/give/views/main.view.html',
				controller: 'principalCtrl'
			}).
			when('/404',{
				templateUrl: 'public/main/views/404.view.html'
			}).
			otherwise({
				redirectTo: '/404'
			});
	}]);

	app.factory('mainService', ['$http','$rootScope','$location','$q', function( $http,$rootScope,$location,$q){
		var self = {
			logout: function() {
				$http.post('php/destroy_session.php');
				//$location.path('/login/#/ingresar');
				window.location="login/";
			},
			config:{},
			cargar: function(){
				var d = $q.defer();
				$http.get('configuracion.json')
					.success(function(data){
						self.config = data;
						d.resolve();
					})
					.error(function(){
						d.reject();
						console.error("No se pudo cargar el archivo de configuración");
					});

				return d.promise;
			},
			editarUser: function(user) {
				return $http.put('rest/v1/user/'+user.id,user);
			},
			data: function() {
				var d = $q.defer();

				$http.get('php/data.php' )
					.success(function( data ){
						if(data) {
							if( data.error == 'yes' ) {
								$http.post('php/destroy_session.php');
								window.location="login/";
							} else {
								if(data.error == 'not') {
									$rootScope.userID = data.userID;
									$rootScope.userTYPE = data.userTYPE;
								}
							}

						}
						return d.resolve();
					});

				return d.promise;
			},
			mainUser: function(id) {
				var d = $q.defer();
				$http.get('rest/v1/user/view/'+id)
					.success(function( data ) {
						d.resolve(data);
					});
				return d.promise;
			}
		};
		return self;
	}]);


	app.controller('mainCtrl', ['$scope', '$rootScope', 'mainService', 'upload', function($scope,$rootScope,mainService,upload){
		$scope.config = {};
		$scope.titulo    = "";
		$scope.subtitulo = "";

		$scope.mainUser = {};
		$scope.userSelMain = {};
		$scope.editUser = {};

		mainService.cargar().then( function(){
			$scope.config = mainService.config;
			//console.log($scope.config);
		});

		$scope.init = function() {
			mainService.data().then( function(){
				mainService.mainUser($rootScope.userID).then(function( data ) {
					$scope.mainUser = data;
				});
			});
		};

		$scope.mostrarUserModal = function(){
			$scope.init();
			$scope.userSelMain = {};

			$scope.userSelMain = $scope.mainUser;
			$("#modal_userMain").modal();
		};

		$scope.cancelarUserMain = function(frmUser) {
			location.reload();
		}


		// ================================================
		//   Funciones Globales del Scope
		// ================================================
		$scope.activar = function( menu, submenu, titulo, subtitulo ){

			$scope.titulo = "";
			$scope.subtitulo = "";

			$scope.titulo = titulo;
			$scope.subtitulo = subtitulo;
			//console.log($scope.titulo);

			$scope.mPrincipal = "";
			$scope.mUsers = "";
			$scope.mClients = "";
			$scope.mGives = "";
			$scope.mReport = "";
			$scope.mGraphic = "";

			$scope[menu] = 'active';

		};
		$scope.salir = function() {
			mainService.logout();
			//console.log('Mierda');
		};

		$scope.editarUserMain = function(user,frmUser) {
			if( (user.pwdN != '' || user.pwdR != '') && (user.pwdA == null || user.pwdA == '') ) {
				swal("ERROR", "¡Antes debe ingresar su contraseña atigua!", "error");
			}
			else {
			if(typeof user.src == 'object')
				upload.saveImg(user.src).then(function( data ) {
					if ( data.error == 'not' ) {
						user.src = data.src;
						$scope.mainUser.src = data.src;
						mainService.editarUser(user).success(function(response){
							$scope.editUser = response;
							if( $scope.editUser.error == 'not' )
								swal("CORRECTO", "¡"+data.msj+" - "+$scope.editUser.msj+"!", "success");
							else
								if ( $scope.editUser.error == 'yes' )
								swal("ERROR", "¡"+$scope.editUser.msj+"!", "error");
							else 
								swal("ERROR SERVER", "¡"+$scope.editUser+"!", "error");
						})
						.error(function(response){
							console.error(response);
						});
					} else 
					if ( data.error == 'yes' )
						swal("ERROR", "¡"+data.msj+"!", "error");
					else 
						swal("ERROR SERVER", "¡"+data+"!", "error");
				});
			else {
				mainService.editarUser(user).success(function(response){
					$scope.editUser = response;
					if( $scope.editUser.error == 'not' )
						swal("CORRECTO", "¡"+$scope.editUser.msj+"!", "success");
					else
						if ( $scope.editUser.error == 'yes' )
						swal("ERROR", "¡"+$scope.editUser.msj+"!", "error");
					else 
						swal("ERROR SERVER", "¡"+$scope.editUser+"!", "error");
				})
				.error(function(response){
					console.error(response);
				});
			}
			$scope.userSelMain = {};

			frmUser.autoValidateFormOptions.resetForm();
			$("#modal_userMain").modal('hide');
			}
		};

	}]);

	// ================================================
	//   Controlador de principal
	// ================================================
	app.controller('principalCtrl', ['$scope', function($scope){
		$scope.activar('mPrincipal','','Principal','información');
	}]);

	// ================================================
	//   Filtros
	// ================================================
	app.filter( 'quitarletra', function(){

		return function(palabra){
			if( palabra ){
				if( palabra.length > 1)
					return palabra.substr(1);
				else
					return palabra;
			}
		}
	});

	app.filter( 'palabra', function(){

		return function(palabra){
			if( palabra ){
				var unaPalabra = palabra.split(" ");
				if( unaPalabra[0] )
					return unaPalabra[0];
				else
					return '';
			}
		}
	});

	app.filter( 'reducirTexto', function(){
		return function(palabra){
			if( palabra ){
				if( palabra.length > 22)
					return palabra.substr(0,22)+' ...';
				else
					return palabra;
			}
		}
	});

	// ================================================
	//   Directiva para archivos
	// ================================================
	app.directive('fileModel',['$parse',function($parse) {
		return {
			restrict: 'A',
			link: function(scope, iElement, iAttrs) {
				iElement.on('change',function(e) {
					$parse(iAttrs.fileModel).assign(scope,iElement[0].files[0]);
				});
			}
		};
	}]);

	// ================================================
	//   Servicio para cargar archivos
	// ================================================
	app.service('upload',['$http','$q',function($http,$q) {
		var self = {
			saveImg : function(img) {
				var d = $q.defer();
				var formData = new FormData();
				formData.append('img',img);
				$http.post('php/server.php',formData,{
					headers: { 'Content-Type': undefined }
				}).success(function( data ) {
					d.resolve( data );
				}).error(function(msj, code) {
					d.reject( msj );
				});
				return d.promise;
			}
		};
		return self;
	}]);

})(window.angular);