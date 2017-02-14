<?php include("template/header.php"); ?>

<div class="container">
	
	<div class="hidden-xs hidden-sm col-md-1 col-lg-2"></div>
	<div class="col-xs-12 col-sm-12 col-md-10 col-lg-8">
		<form id="log-panel" class="form-horizontal" method="post" action="game.php">
		  <fieldset>
		    <legend class="text-center">Juego del Wumpus</legend>
		    <div class="form-group">
		      <label for="jugador" class="col-lg-2 control-label">Nombre</label>
		      <div class="col-lg-10">
		        <input type="text" class="form-control" id="jugador" name="jugador" placeholder="Ingrese su nombre" required>
		      </div>
		    </div>
		    <div class="form-group text-center">
		        <a id="limpiar" class="btn btn-default">Limpiar</a>
		        <button type="submit" class="btn btn-primary">Jugar!</button>
		    </div>
		  </fieldset>
		</form>
	</div>
	<div class="hidden-xs hidden-sm col-md-1 col-lg-2"></div>
</div>

<?php include("template/footer.php"); ?>

<script>
	jQuery(document).ready(function($) {
		$('#jugador').focus();
		$('#limpiar').unbind().click(function(event) {
			$('#jugador').val('').focus();
		});
	});
</script>