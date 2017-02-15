
//Variables Globales
var casilla_actual = {fila: 4,columna: 1}
var orientacionJugador = 0;
var datosProlog;
var prologQuery;
var cantidadMovimientos = 0;
var estado_wumpus = "alive";
var flechas = 1;
var cantidad_oro = 0;
opuesto = { 0: 180, 180: 0, 270: 90, 90: 270 };
derecha = { 0: 270, 180: 90, 270: 180, 90: 0 };
izquierda = { 0: 90, 180: 270, 270: 0, 90: 180 };
//Manejador de Teclas
$('html').unbind().keyup(function(e) { 
	switch (e.keyCode) {
	    case 37:
	    	cantidadMovimientos++;
	    	seleccionarCasillaActual().html('');
	        seleccionarCasillaActual().append(obtenerImagen('images/izquierda.png'));
	        reorientar(180);
	        break;
	    case 38:
	    	cantidadMovimientos++;
	        seleccionarCasillaActual().html('');
	        seleccionarCasillaActual().append(obtenerImagen('images/espalda.png'));
	        reorientar(90);
	        break;
	    case 39:
	    	cantidadMovimientos++;
	        seleccionarCasillaActual().html('');
	        seleccionarCasillaActual().append(obtenerImagen('images/derecha.png'));
	        reorientar(0);
	        break;
	    case 40:
	    	cantidadMovimientos++;
	        seleccionarCasillaActual().html('');
	        seleccionarCasillaActual().append(obtenerImagen('images/frente.png'));
	        reorientar(270);
	        break;
	    case 65:
	    	cantidadMovimientos++;
	        estado_actual = seleccionarCasillaActual().find('img').attr('src');
	        alzar(estado_actual);
	        break;
	    case 83:
	    	cantidadMovimientos++;
	        estado_actual = seleccionarCasillaActual().find('img').attr('src');
	        disparar(estado_actual);
	        break;
        case 32:
	    	cantidadMovimientos++;
	        mover();
	        break;
	}
});



//Inicia el juego  
function iniciar_jugador(){
		iniciarProlog('iniciamosPhp');
		casilla_inicial = seleccionarCasilla(casilla_actual.fila,casilla_actual.columna);
		casilla_inicial.append(obtenerImagen('images/derecha.png'));
}

//devuelve la casilla actual en la que se encuentra el jugador
function seleccionarCasillaActual(){
	return seleccionarCasilla(casilla_actual.fila,casilla_actual.columna);
}

//Selecciona la fila indicada y la retorna
function seleccionarFila(fila){
	return $('tbody tr:nth-child('+fila+')');
}

//Selecciona una columna de una fila
function seleccionarCasilla(fila,columna){
	res_fila = seleccionarFila(fila);
	return res_fila.find('td:nth-child('+ columna + ')');	
}





//Genera Img a partir del nombre
function obtenerImagen(nombre){
	return	'<img src="' + nombre +'" alt="" />';
}

//promesa para poder animar
function sleep(ms) {
	return new Promise(resolve => setTimeout(resolve, ms));
}

// 'animacion' de alzar
async function alzar(estado_actual) {
	if(cantidad_oro == 0){
		accionProlog('alzarPhp');
		cantidadMovimientos++;
		seleccionarCasillaActual().html('');
		seleccionarCasillaActual().append(obtenerImagen('images/levantar.png'));
		await sleep(100);
		seleccionarCasillaActual().html('');
		seleccionarCasillaActual().append(obtenerImagen(estado_actual));
	}
}

// 'animación' de disparo
async function disparar(estado_actual) {
	if(flechas > 0){
		accionProlog('dispararPhp');
		imagen_disparo = seleccionarDisparo(estado_actual);
		seleccionarCasillaActual().html('');
		seleccionarCasillaActual().append(obtenerImagen(imagen_disparo));
		sonidoDisparar();
		await sleep(500);
		seleccionarCasillaActual().html('');
		seleccionarCasillaActual().append(obtenerImagen(estado_actual));
	}
}

//Selecciona la imagen adecuada de disparo
function seleccionarDisparo(estado){
	imagen_disparar = '';
	switch(estado){
		case 'images/izquierda.png':
				imagen_disparar = 'images/disparar_izquierda.png';
				break;
		case 'images/derecha.png':
				imagen_disparar = 'images/disparar_derecha.png';
				break;
		case 'images/espalda.png':
				imagen_disparar = 'images/disparar_arriba.png';
				break;
		case 'images/frente.png':
				imagen_disparar = 'images/disparar_abajo.png';
				break;
	}
	return imagen_disparar;
}

//Produce el sonido de un disparo
async function sonidoDisparar(){
	audioElement = document.createElement('audio');
	audioElement.setAttribute('src', 'song/disparo.mp3');
	audioElement.play();
	await sleep(350);
}

function sonidoPared(){
	audioElement = document.createElement('audio');
	audioElement.setAttribute('src', 'song/pared.mp3');
	audioElement.play();
}

function sonidoWumpusMuerto(){
	audioElement = document.createElement('audio');
	audioElement.setAttribute('src', 'song/wumpus_muerto.mp3');
	audioElement.play();
}



//Rotación:
function esOpuesto(grado){
	gradoOpuesto = opuesto[orientacionJugador];
	if(gradoOpuesto == grado){
		return true;
	}
	return false;
}

function esDerecho(grado){
	gradoDerecho = derecha[orientacionJugador];
	if(gradoDerecho == grado){
		return true;
	}
	return false;
}

function esIzquierdo(grado){
	gradoIzquierda = izquierda[orientacionJugador];
	if(gradoIzquierda == grado){
		return true;
	}
	return false;
}


function reorientar(nuevaOrientacion){
	if(orientacionJugador != nuevaOrientacion){
		if(esOpuesto(nuevaOrientacion)){
			accionProlog('girarIzquierdaPhp, girarIzquierdaPhp');
		}else if(esDerecho(nuevaOrientacion)){
			accionProlog('girarDerechaPhp');
		}else{
			accionProlog('girarIzquierdaPhp');
		}
		orientacionJugador = nuevaOrientacion;
	}	
}


function mover(){
	switch (orientacionJugador){
		case 0:
				movimiento = casilla_actual.columna + 1;
				desplazar(movimiento);
				break;
		case 90:
				movimiento = casilla_actual.fila - 1;
				desplazar(movimiento);
				break;
		case 180:
				movimiento = casilla_actual.columna - 1;
				desplazar(movimiento);
				break;
		case 270:
				movimiento = casilla_actual.fila + 1;
				desplazar(movimiento);
				break;
	}
}





//desplaza al personaje por el mapa
function desplazar(movimiento){
	if(movimientoCorrecto(movimiento)){
		accionProlog('caminarPhp');
		//guardo la casilla de donde me voy
		casilla_anterior = {fila: casilla_actual.fila,columna: casilla_actual.columna};
		if((orientacionJugador == 0) || (orientacionJugador == 180)){
			casilla_actual.columna = movimiento;
		}else{
			casilla_actual.fila = movimiento;
		}
		moverPersonajeACasillaActual(casilla_anterior);
	}else{
		sonidoPared();
	}
}

//Verifica que estemos dentro de los limites al caminar
function movimientoCorrecto(siguienteMovimiento){
	if((siguienteMovimiento >= 1) && (siguienteMovimiento <= 4)){
		return true;
	}
	return false;
}

//Reubica el personaje en la nueva casilla
function moverPersonajeACasillaActual(casilla_anterior){
	urlImagen = seleccionarCasilla(casilla_anterior.fila,casilla_anterior.columna).find('img').attr('src');
	seleccionarCasillaActual().append(obtenerImagen(urlImagen));
	seleccionarCasilla(casilla_anterior.fila,casilla_anterior.columna).html('');
}

function iniciarProlog(query){
	prologQuery = query;
	ajaxProlog(prologQuery);
}

function accionProlog(query){
	prologQuery = prologQuery + ' , ' + query;
	ajaxProlog(prologQuery);
}

function ajaxProlog(query){
	$.ajax({
	    url: 'http://localhost/final_io/feedback.php',
	    cache: false,
	    data: {query: query},
		type: 'post',
	    success: function(res) {
	    	console.log(res);
	    	datosProlog = JSON.parse(res);
	    	refrezcarDatos();
	    },
	    error: function(xhr, error) {
	        try {
	            console.debug(xhr); 
	            console.debug(error);
	        } catch (err) {
	            alert(err);
	        }
	    }
	});
}

function verificarMuerteWumpus(estado_anterior){
	if(estado_anterior != estado_wumpus){
		sonidoWumpusMuerto();
	}
}


function refrezcarDatos(){
	console.log(datosProlog.datos);
	flechas = datosProlog.datos.mis_flechas;
	orientacionJugador = datosProlog.datos.orientacion;
	estado_anterior = estado_wumpus;
	estado_wumpus = datosProlog.datos.est_wumpus;
	verificarMuerteWumpus(estado_anterior);
	cantidad_oro = datosProlog.datos.mi_oro;
	$('#flechas').html(flechas);
	$('#oro').html(cantidad_oro);
	$('#estado_wumpus').html(estado_wumpus);
	insertarOrientacion();
	$('#movimientos').html(cantidadMovimientos);
}


function insertarOrientacion(){
	switch(orientacionJugador){
		case '0':
				$('#orientacion').html('derecha');
				break;
		case '90':
				$('#orientacion').html('arriba');
				break;
		case '180':
				$('#orientacion').html('izquierda');
				break;
		case '270':
				$('#orientacion').html('abajo');
				break;
	}
}

