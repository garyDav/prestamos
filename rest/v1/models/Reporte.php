<?php if(!defined('SPECIALCONSTANT')) die(json_encode([array('id'=>'0','error'=>'Acceso Denegado')]));

$app->post("/reportes/",function() use($app) {
	$objDatos = json_decode(file_get_contents("php://input"));

	$fecha = $objDatos->fecha;

	try {
		$conex = getConex();

		$result = $conex->prepare("CALL pReporte('$fecha');");

		$result->execute();
		$res = $result->fetchAll(PDO::FETCH_OBJ);
		//$res = array('response'=>'La puta Marta');

		$conex = null;

		$app->response->headers->set("Content-type","application/json");
		$app->response->headers->set('Access-Control-Allow-Origin','*');
		$app->response->status(200);
		$app->response->body(json_encode($res));
	}catch(PDOException $e) {
		echo "Error: ".$e->getMessage();
	}
});