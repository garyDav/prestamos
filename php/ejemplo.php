<?php

echo date("Y").'<br>';
$fecha = '2017-01-19';
$fecha2 = '2017-07-01';
$mes1 = date("m", strtotime($fecha));
$mes2 = date("m", strtotime($fecha2));
$resta = $mes2-$mes1;

echo date("m", strtotime($fecha)).'<br>'; 
echo $resta.'<br>';

$fecha_in = '2017-03-19';
$fecha_in = date_create_from_format('Y-m-d', $fecha_in);

echo 'pinche: '.$fecha_in.'<br>';

$fecha_in = date('Y').'-'.date('m').'-'.'01';
$fecha_out = strtotime ( '+1 month' , strtotime ( $fecha_in ) ) ;
$fecha_out = date ( 'Y-m-d' , $fecha_out );

echo $fecha_out.'<br>';

echo 15.16.'<br>';

?>

