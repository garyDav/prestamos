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
function get_paginado_give( $pagina = 1, $id = 0, $por_pagina = 10 ){

	$conex = getConex();

	if( $id == '0' )
		$sql = "SELECT count(*) as cuantos FROM give";
	else
		$sql = "SELECT count(*) as cuantos FROM give WHERE id_user='$id';";

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

	if( $id == 0 )
		$sql = "SELECT g.id,u.ci us_ci,u.name us_name,c.ci cli_ci,c.name cli_name,g.amount,g.fec_pre,g.month,g.fine,g.interest,g.type,g.detail,g.gain,g.total_capital,g.total_interest,g.total_lender,g.total_assistant FROM give g,user u,clients c WHERE g.id_user=u.id AND g.id_clients=c.id ORDER BY g.id DESC limit $desde, $por_pagina";
	else
		$sql = "SELECT g.id,u.ci us_ci,u.name us_name,c.ci cli_ci,c.name cli_name,g.amount,g.fec_pre,g.month,g.fine,g.interest,g.type,g.detail,g.gain,g.total_capital,g.total_interest,g.total_lender,g.total_assistant FROM give g,user u,clients c WHERE g.id_user=u.id AND g.id_clients=c.id AND g.id_user='$id' ORDER BY g.id DESC limit $desde, $por_pagina;";
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

?>
