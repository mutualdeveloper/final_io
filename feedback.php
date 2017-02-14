 <?php 
	$query = $_POST['query'];
	$query = $query  . ' , mostrarMundoPhp.';
	execute_prolog($query);
	


	function execute_prolog($query){
		$consultaProlog =`swipl -s pop.pl -g "$query" `;
		echo $consultaProlog;
	}

 ?>



