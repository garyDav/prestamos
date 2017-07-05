<?php if(!defined("SPECIALCONSTANT")) die(json_encode([array("id"=>"0","nombre"=>"Acceso Denegado")]));


// ================================================
//   Funcion que pagina cualquier TABLA
// ================================================
function get_todo_paginado( $tabla, $pagina = 1, $por_pagina = 20 ){

	$conex = getConex();

	$sql = "SELECT count(*) as cuantos from $tabla";

	$result = $conex->prepare($sql);
	$result->execute();
	$res = $result->fetchObject();
	$cuantos = $res->cuantos;


	$total_paginas = ceil( $cuantos / $por_pagina );

	if( $pagina > $total_paginas ){
		$pagina = $total_paginas;
	}


	$pagina -= 1;  // 0
	$desde   = $pagina * $por_pagina; // 0 * 20 = 0
	if( $desde < 0 )
		$desde = 0;

	if( $pagina >= $total_paginas-1 ){
		$pag_siguiente = 1;
	}else{
		$pag_siguiente = $pagina + 2;
	}

	if( $pagina < 1 ){
		$pag_anterior = $total_paginas;
	}else{
		$pag_anterior = $pagina;
	}


	$sql = "SELECT * FROM $tabla ORDER BY id DESC limit $desde, $por_pagina";
	$result = $conex->prepare($sql);
	$result->execute();
	$datos = $result->fetchAll(PDO::FETCH_OBJ);

	$arrPaginas = array();
	for ($i=0; $i < $total_paginas; $i++) { 
		array_push($arrPaginas, $i+1);
	}


	$respuesta = array(
			'err'     		=> false, 
			'conteo' 		=> $cuantos,
			$tabla 			=> $datos,
			'pag_actual'    => ($pagina+1),
			'pag_siguiente' => $pag_siguiente,
			'pag_anterior'  => $pag_anterior,
			'total_paginas' => $total_paginas,
			'paginas'	    => $arrPaginas
			);


	return  $respuesta;

}


// ================================================
//   Funcion que pagina la tabla give
// ================================================
function get_paginado_give( $pagina = 1, $id = 1, $por_pagina = 10 ){

	$conex = getConex();

	if( $id == '1' )
		$sql = "SELECT count(*) as cuantos FROM give";
	else
		$sql = "SELECT count(*) as cuantos FROM give WHERE (id_userin='$id' OR id_user='$id');";

	$result = $conex->prepare($sql);
	$result->execute();
	$res = $result->fetchObject();
	$cuantos = $res->cuantos;


	$total_paginas = ceil( $cuantos / $por_pagina );

	if( $pagina > $total_paginas ){
		$pagina = $total_paginas;
	}


	$pagina -= 1;  // 0
	$desde   = $pagina * $por_pagina; // 0 * 20 = 0
	if( $desde < 0 )
		$desde = 0;

	if( $pagina >= $total_paginas-1 ){
		$pag_siguiente = 1;
	}else{
		$pag_siguiente = $pagina + 2;
	}

	if( $pagina < 1 ){
		$pag_anterior = $total_paginas;
	}else{
		$pag_anterior = $pagina;
	}

	if( $id == '1' )
		$sql = "SELECT g.id,u.id id_user,c.id id_clients,u.ci us_ci,u.name us_name,u.last_name us_last_name,c.ci cli_ci,c.name cli_name,c.last_name cli_last_name,g.amount,g.fec_pre,g.month,g.fine,g.interest,g.type,g.detail,g.gain,g.total_capital,g.total_interest,g.total_lender,g.total_assistant FROM give g,user u,clients c WHERE g.id_user=u.id AND g.id_clients=c.id ORDER BY g.id DESC limit $desde, $por_pagina";
	else
		$sql = "SELECT g.id,u.id id_user,c.id id_clients,u.ci us_ci,u.name us_name,u.last_name us_last_name,c.ci cli_ci,c.name cli_name,c.last_name cli_last_name,g.amount,g.fec_pre,g.month,g.fine,g.interest,g.type,g.detail,g.gain,g.total_capital,g.total_interest,g.total_lender,g.total_assistant FROM give g,user u,clients c WHERE g.id_user=u.id AND g.id_clients=c.id AND (g.id_userin='$id' OR g.id_user='$id') ORDER BY g.id DESC limit $desde, $por_pagina;";
	$result = $conex->prepare($sql);
	$result->execute();
	$datos = $result->fetchAll(PDO::FETCH_OBJ);

	$arrPaginas = array();
	for ($i=0; $i < $total_paginas; $i++) { 
		array_push($arrPaginas, $i+1);
	}


	$respuesta = array(
			'err'     		=> false, 
			'conteo' 		=> $cuantos,
			'gives' 		=> $datos,
			'pag_actual'    => ($pagina+1),
			'pag_siguiente' => $pag_siguiente,
			'pag_anterior'  => $pag_anterior,
			'total_paginas' => $total_paginas,
			'paginas'	    => $arrPaginas
			);


	return  $respuesta;

}

// ================================================
//   Funcion paginar tabla give y su payment
// ================================================
function get_paginado_main_give( $pagina = 1, $id = 1, $por_pagina = 6 ){

	$conex = getConex();

	if( $id == '1' )
		$sql = "SELECT count(*) as cuantos FROM give WHERE visible<>0";
	else
		$sql = "SELECT count(*) as cuantos FROM give WHERE (id_userin='$id' OR id_user='$id') AND visible<>0;";

	$result = $conex->prepare($sql);
	$result->execute();
	$res = $result->fetchObject();
	$cuantos = $res->cuantos;


	$total_paginas = ceil( $cuantos / $por_pagina );

	if( $pagina > $total_paginas ){
		$pagina = $total_paginas;
	}


	$pagina -= 1;  // 0
	$desde   = $pagina * $por_pagina; // 0 * 20 = 0
	if( $desde < 0 )
		$desde = 0;

	if( $pagina >= $total_paginas-1 ){
		$pag_siguiente = 1;
	}else{
		$pag_siguiente = $pagina + 2;
	}

	if( $pagina < 1 ){
		$pag_anterior = $total_paginas;
	}else{
		$pag_anterior = $pagina;
	}

	if( $id == '1' )
		$sql = "SELECT g.id,c.name,c.last_name,c.ci,c.ex,c.src,g.amount,g.fec_pre,g.month,'' payment,'' nopayment FROM clients c,give g,user u WHERE c.id=g.id_clients AND g.id_user=u.id AND g.visible<>0 ORDER BY g.id DESC limit $desde, $por_pagina";
	else
		$sql = "SELECT g.id,c.name,c.last_name,c.ci,c.ex,c.src,g.amount,g.fec_pre,g.month,'' payment,'' nopayment FROM clients c,give g,user u WHERE c.id=g.id_clients AND g.id_user=u.id AND (g.id_userin='$id' OR g.id_user='$id') AND g.visible<>0 ORDER BY g.id DESC limit $desde, $por_pagina;";
	$result = $conex->prepare($sql);
	$result->execute();
	$datos = $result->fetchAll(PDO::FETCH_OBJ);

	$arrPaginas = array();
	for ($i=0; $i < $total_paginas; $i++) { 
		array_push($arrPaginas, $i+1);
	}

	foreach ($datos as $valor) {
		//Resultados para payment
		$id = $valor->id;
		$sql = "SELECT id,fec_pago,observation FROM payment WHERE id_give='$id';";
		$result = $conex->prepare( $sql );
		$result->execute();
		$valor->payment = $result->fetchAll(PDO::FETCH_OBJ);

		//Obteniendo candidad de pagos ya realizados
		$sql = "SELECT count(id) cantidad FROM payment WHERE id_give='$id';";
		$result = $conex->prepare( $sql );
		$result->execute();
		$cantidad = $result->fetchObject()->cantidad;


		
		//Resultados para nopayment
		$cont=0;
		$resultado = [];
		$fecha_pre = $valor->fec_pre;
		$fecha_actual = date('Y-m-j');

		$final_pre = strtotime ( '+'.$valor->month.' month' , strtotime ( $fecha_pre ) ) ;
		$final_pre = date ( 'Y-m-j' , $final_pre );

		while($fecha_pre < $final_pre) { //$fecha_pre != $final_pre
			$fecha_pre = strtotime ( '+1 month' , strtotime ( $fecha_pre ) ) ;
			$fecha_pre = date ( 'Y-m-j' , $fecha_pre );
			
			if($cont > $cantidad-1)
				$resultado[] = (object) array( 'fec_pago'=>$fecha_pre, 'observation'=>'Falta pagar' );
			$cont++;
		}

		$valor->nopayment = $resultado;
	}


	$respuesta = array(
			'err'     		=> false, 
			'conteo' 		=> $cuantos,
			'gives' 		=> $datos,
			'pag_actual'    => ($pagina+1),
			'pag_siguiente' => $pag_siguiente,
			'pag_anterior'  => $pag_anterior,
			'total_paginas' => $total_paginas,
			'paginas'	    => $arrPaginas
			);


	return  $respuesta;

}

// ================================================
//   Funcion paginar tabla give y su payment en reporte
// ================================================
function get_paginado_reporte( $pagina = 1, $id = 1, $por_pagina = 6 ){

	$conex = getConex();

	if( $id == '1' )
		$sql = "SELECT count(*) as cuantos FROM give WHERE visible<>0";
	else
		$sql = "SELECT count(*) as cuantos FROM give WHERE (id_userin='$id' OR id_user='$id') AND visible<>0;";

	$result = $conex->prepare($sql);
	$result->execute();
	$res = $result->fetchObject();
	$cuantos = $res->cuantos;


	$total_paginas = ceil( $cuantos / $por_pagina );

	if( $pagina > $total_paginas ){
		$pagina = $total_paginas;
	}


	$pagina -= 1;  // 0
	$desde   = $pagina * $por_pagina; // 0 * 20 = 0
	if( $desde < 0 )
		$desde = 0;

	if( $pagina >= $total_paginas-1 ){
		$pag_siguiente = 1;
	}else{
		$pag_siguiente = $pagina + 2;
	}

	if( $pagina < 1 ){
		$pag_anterior = $total_paginas;
	}else{
		$pag_anterior = $pagina;
	}

	if( $id == '1' )
		$sql = "SELECT g.id,u.name us_name,u.last_name us_last_name,c.name cli_name,c.last_name cli_last_name,c.src cli_src,u.src us_src,g.amount,g.fec_pre,g.month,g.total_capital,g.total_interest,g.total_lender,g.total_assistant,g.visible,us.name ac_name,us.last_name ac_last_name,'' payment,'' nopayment FROM clients c,give g,user u,user us WHERE c.id=g.id_clients AND g.id_userin=u.id AND g.id_user=us.id AND g.visible<>0 ORDER BY g.id DESC limit $desde, $por_pagina";
	else
		$sql = "SELECT g.id,u.name us_name,u.last_name us_last_name,c.name cli_name,c.last_name cli_last_name,c.src cli_src,u.src us_src,g.amount,g.fec_pre,g.month,g.total_capital,g.total_interest,g.total_lender,g.total_assistant,g.visible,us.name ac_name,us.last_name ac_last_name,'' payment,'' nopayment FROM clients c,give g,user u,user us WHERE c.id=g.id_clients AND g.id_userin=u.id AND g.id_user=us.id AND (g.id_userin='$id' OR g.id_user='$id') AND g.visible<>0 ORDER BY g.id DESC limit $desde, $por_pagina;";
	$result = $conex->prepare($sql);
	$result->execute();
	$datos = $result->fetchAll(PDO::FETCH_OBJ);

	$arrPaginas = array();
	for ($i=0; $i < $total_paginas; $i++) { 
		array_push($arrPaginas, $i+1);
	}

	foreach ($datos as $valor) {
		//Resultados para payment
		$id = $valor->id;
		$sql = "SELECT id,fec_pago,interests,capital_shares,lender,assistant,observation FROM payment WHERE id_give='$id';";
		$result = $conex->prepare( $sql );
		$result->execute();
		$valor->payment = $result->fetchAll(PDO::FETCH_OBJ);

		//Obteniendo candidad de pagos ya realizados
		$sql = "SELECT count(id) cantidad FROM payment WHERE id_give='$id';";
		$result = $conex->prepare( $sql );
		$result->execute();
		$cantidad = $result->fetchObject()->cantidad;


		
		//Resultados para nopayment
		$cont=0;
		$resultado = [];
		$fecha_pre = $valor->fec_pre;
		$fecha_actual = date('Y-m-j');

		$final_pre = strtotime ( '+'.$valor->month.' month' , strtotime ( $fecha_pre ) ) ;
		$final_pre = date ( 'Y-m-j' , $final_pre );

		while($fecha_pre < $final_pre) { //$fecha_pre != $final_pre
			$fecha_pre = strtotime ( '+1 month' , strtotime ( $fecha_pre ) ) ;
			$fecha_pre = date ( 'Y-m-j' , $fecha_pre );
			
			if($cont > $cantidad-1)
				$resultado[] = (object) array( 'fec_pago'=>$fecha_pre,'interests'=>'0','capital_shares'=>'0','lender'=>'0','assistant'=>'0','observation'=>'Falta pagar...' );
			$cont++;
		}

		$valor->nopayment = $resultado;
	}


	$respuesta = array(
			'err'     		=> false, 
			'conteo' 		=> $cuantos,
			'gives' 		=> $datos,
			'pag_actual'    => ($pagina+1),
			'pag_siguiente' => $pag_siguiente,
			'pag_anterior'  => $pag_anterior,
			'total_paginas' => $total_paginas,
			'paginas'	    => $arrPaginas
			);


	return  $respuesta;

}

?>
