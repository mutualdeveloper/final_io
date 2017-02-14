<?php 
$jugador = $_POST['jugador'];
include("template/header.php"); 
?>
	<div class="container">
		<div class="hidden-xs hidden-sm col-md-2 col-lg-2"></div>	
		<div class="col-xs-12 col-sm-12 col-md-8 col-lg-8">
			<table>
				<tbody>
					<tr>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
					</tr>
					<tr>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
					</tr>
					<tr>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
					</tr>
					<tr>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
					</tr>
				</tbody>
			</table>
		</div>
	<div id="panel-info" class="col-xs-12 col-sm-12 col-md-2 col-lg-2">
			<small><strong>Cant. de Movimientos: </strong></small><data id="movimientos"></data><br>
			<small><strong>Orientación: </strong></small><data id="orientacion"></data><br>
			<small><strong>Flechas: </strong></small><data id="flechas"></data><br>
			<small><strong>Wumpus: </strong></small><data id="estado_wumpus"></data><br>
			<small><strong>Oro: </strong></small><data id="oro"></data><br>
	</div>
	</div>

	<div class="animated">
		<small >Esta jugando: <?php echo isset($jugador) ? $jugador : 'no' ?> &nbsp;&nbsp;</small>
	</div>
<?php include("template/footer.php"); ?>

