package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.utils.getQualifiedClassName;
	import flash.net.SharedObject;
	
	public class main extends MovieClip{
		
		//constantes
		var U_LIMIT:Number=10;
		var D_LIMIT:Number=710;
		var L_LIMIT:Number=270;
		var R_LIMIT:Number=1030;
		var P_SPEED:Number=30;
		var L_SPEED:Number=5;
		var F_SPEED:Number=20;
		var LINE_FREQ:Number=50;
		var Y_FIRE_DEF:Number=665;
		var X_FIRE_DEF:Number=620;
		var Y_CHECK_BUILD:Number=680;
		var INI_MISSILES:int=10;
		var DELAY_FIRES:int=5;
		
		//objetos
		var p:puntoMira=new puntoMira();
		
		//el sembrao
		var lines:Array;
		var lineso:Array;
		var linesd:Array;
		var linesa:Array;
		var linesy:Array;
		var heads:Array;
		var expls:Array;
		var fires:Array;
		var fireso:Array;
		var firesd:Array;
		var firesa:Array;
		var firesy:Array;
		var firesyd:Array;
		var bases:Array;
		var basesdes:Array;
		
		//otras vars
		var pmove:Number=0;
		var linetrig:Number=0;
		var score:int=0;
		var inplay:Boolean=false;
		var canfire:Boolean=true;
		var level:int=0;
		var count_delay_fires:int=0;
		var missilesnum:int=0;
		var ini_missiles:Number;
		var l_speed:Number;
		var line_freq:Number;
		var pmax:int=0;
		
		//objetos
		var txtpuntos:textopuntos=new textopuntos();
		var txtwave:textowave=new textowave();
		var txtmax:textomax=new textomax();
		var txtmsg:textomsg=new textomsg();
		var back:thebackground=new thebackground();
		var txtsalir:textosalir=new textosalir();
		
		//Save
		var so:SharedObject = SharedObject.getLocal("localStorage");


		//

		public function main() {
			// constructor code
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keydown);
			stage.addEventListener(KeyboardEvent.KEY_UP,keyup);
			//startgame();
			
			if (so.data.highScore!=undefined) {
				pmax=int(so.data.highScore);
			} else {
				pmax=0;
				so.data.highScore=0;
				so.flush();
				}
			trace("puntos guardados:"+so.data.highScore)
			txtmax.texto.text="Récord "+pmax;
		}
		

		function keydown(e:KeyboardEvent){
			pmove=e.keyCode;
			if (!inplay && (pmove==16777224 || pmove==65)){
				cleanup();
				startgame();
			}
		}		
		
		function keyup(e:KeyboardEvent){
			pmove=0;
		}

		
		function cleanup(){
			
			//Limpiamos TODO
			while(numChildren>0){
				removeChildAt(0);
			}
			
			//añadimos fondo y marcadores
			addChild(back);
			back.x=260;
			addChild(txtpuntos);
			txtpuntos.x=260;
			addChild(txtmax);
			txtmax.x=460;
			txtmax.texto.text="Récord "+pmax;
			addChild(txtwave);
			txtwave.x=750;
			addChild(txtmsg);
			txtmsg.x=260;
			txtmsg.y=220;
			
			
			level=0;
			ini_missiles=INI_MISSILES;
			l_speed=L_SPEED;
			line_freq=LINE_FREQ;
			missilesnum=0;
			pmove=0;
			linetrig=0;
			score=0;
			inplay=false;
			canfire=true;
			count_delay_fires=0;

			lines=new Array();
			lineso=new Array();
			linesd=new Array();
			linesa=new Array();
			linesy=new Array();
			heads=new Array();
			expls=new Array();
			fires=new Array();
			fireso=new Array();
			firesd=new Array();
			firesa=new Array();
			firesy=new Array();
			firesyd=new Array();
			bases=new Array();
			basesdes=new Array();
			
		}
		
		
		function startgame(){
			//predefiniciones
			p.x=640;
			p.y=360;
			this.addChild(p);
			
			//bases
			var n:int=0;
			for (var i:int=0;i<9;i++){
				if (i==4){
					bases.push(new basemissile());
				}else{
					bases.push(new base());
				}
				n=bases.length-1;
				bases[n].y=690;
				bases[n].x=i*73+310;
				addChild(bases[n]);
			}
			
			//iniciamos ciclo
			addEventListener(Event.ENTER_FRAME,ciclo);
			letsgo();
		}
		
		function letsgo(){
			inplay=true;
			level++;
			ini_missiles+=1;
			l_speed+=0.5;
			line_freq--;
			missilesnum=0;
			txtwave.texto.text="Oleada "+String(level);
			txtmsg.visible=true;
			txtmsg.texto.text="OLEADA "+String(level);
			
		}
		
		function ciclo(e:Event){
			var i:int=0;
			
			//Quiza ya hemos terminado
			if (!inplay) return;
			
			//moviendo punto de mira
			switch(pmove){
				case 38: //UP
					if (p.y>=U_LIMIT) p.y-=P_SPEED;
				break;
				
				case 40: //DOWN
					if (p.y<=D_LIMIT) p.y+=P_SPEED;
				break;
				
				case 37: //LEFT
					if (p.x>=L_LIMIT) p.x-=P_SPEED;
				break;
				
				case 39: //RIGHT
					if (p.x<=R_LIMIT) p.x+=P_SPEED;
				break;
				
				case 13: //Fire
				case 32:
					//if (count_delay_fires>=DELAY_FIRES){
						//count_delay_fires=0;
						if (canfire) {
							fire(p.x,p.y);
						}
					//}
					//count_delay_fires++;
				break;
			}
			
			//Añadimos lineas si toca
			if (linetrig>=line_freq){
				linetrig=0;
				addline();
			}
			linetrig++;
			
			//movemos las lineas ya creadas
			if (lineso.length>0){
				for (i=0;i<lineso.length;i++){
					drawline(i);
					//Cleanup lineas
					if (linesy[i]>=D_LIMIT) deleteline(i);
				}
			}
			
			//movemos los disparos ya creados
			if (fireso.length>0){
				for (i=0;i<fireso.length;i++){
					drawlinefire(i);
					//Colision-Cleanup lineas disparo
					if (firesy[i]<=firesyd[i]){
						//Hemos alcanzado lugar objetivo.Detonamos.
						fireExplosion(i);
					}
				}
			}			
			
			//Eliminamos las explosiones que ya no existan
			for(i=0;i<expls.length;i++){

				if (this.getChildByName(expls[i].name)==null){
					expls.splice(i,1);
				}
			}

			//Comprobamos si las explosiones existentes colisionan con lineas
			var j:int=0;
			for (i=0;i<expls.length;i++){
				for(j=0;j<heads.length;j++){
					if(expls[i].hitTestObject(heads[j])){
						//Toma!
						collision(j);
					}
				}
			}
			
			//Hay que intentar meter este otro for dentro de uno anterior, por rendimiento
			//Comprobacion heads - edificios
			for (i=0;i<heads.length;i++){
				if (heads[i].y>Y_CHECK_BUILD){
					//Este if es porque si el head no esta ni medio cerca, no comprobamos
					for (j=0;j<bases.length;j++){
						if (heads[i].hitTestObject(bases[j])){
							//Edificio a la mierda!
							destroybase(j,i);
						}
					}
				}
			}
		}
		
		function drawline(i:int){
			var tmp:Number=0;
        	lines[i].graphics.clear();
			lines[i].graphics.moveTo(lineso[i],0);
			lines[i].graphics.lineStyle(3, 0xffffff);

			if (lineso[i]>linesd[i]){
				//nos estamos moviendo hacia la izquierda
				tmp=(lineso[i]-linesd[i])/720;
				linesa[i]-=tmp*l_speed;
			}else if (lineso[i]<linesd[i]){
				//nos movemos a la derecha
				tmp=(linesd[i]-lineso[i])/720;
				linesa[i]+=tmp*l_speed;
			}
			linesy[i]+=l_speed;
			lines[i].graphics.lineTo(linesa[i],linesy[i]);
			//movemos heads
			heads[i].x=linesa[i];
			heads[i].y=linesy[i];
		}
		
		function addline(){
			
			if (missilesnum>=ini_missiles){
				letsgo();
				return;
			}
			missilesnum++;
			txtmsg.visible=false;
			
			var g:Sprite=new Sprite();
			lines.push(g);
			lineso.push(int(Math.random()*720)+260);
			linesd.push(int(Math.random()*720)+260);
			linesa.push(lineso[lineso.length-1]);
			linesy.push(0);
			addChild(lines[lines.length-1]);
			//añadimos heads
			heads.push(new nuclearHead());
			var n:int=heads.length-1;
			heads[n].x=lineso[lineso.length-1];
			heads[n].y=0;
			addChild(heads[n]);
		}
		
		function deleteline(i:int){
			lines[i].graphics.clear();
			removeChild(lines[i]);
			lines.splice(i,1);
			lineso.splice(i,1);
			linesd.splice(i,1);
			linesa.splice(i,1);
			linesy.splice(i,1);
			//quitamos heads
			removeChild(heads[i]);
			heads.splice(i,1);
			
		}
		
		function fire(X:int,Y:int){
			var g:Sprite=new Sprite();
			fires.push(g);
			fireso.push(X_FIRE_DEF);
			firesd.push(X);
			firesa.push(X_FIRE_DEF);
			firesy.push(Y_FIRE_DEF);
			firesyd.push(Y);
			addChild(fires[fires.length-1]);
		}
		
		function fireExplosion(i:int){

			//Iniciar explosion
			expls.push(new explosion());
			var n:int=expls.length-1;
			expls[n].x=firesd[i];
			expls[n].y=firesy[i];
			addChild(expls[n]);
			
			//Borrar la estela
			deletelineexplosion(i);			
		}
		
		function deletelineexplosion(i:int){
			fires[i].graphics.clear();
			removeChild(fires[i]);
			fires.splice(i,1);
			fireso.splice(i,1);
			firesd.splice(i,1);
			firesa.splice(i,1);
			firesy.splice(i,1);
			firesyd.splice(i,1);
		}		
		
		function drawlinefire(i:int){
			var tmp:Number=0;
			
        	fires[i].graphics.clear();
			fires[i].graphics.lineStyle(1, 0xFF0000);
			fires[i].graphics.moveTo(fireso[i],Y_FIRE_DEF);
			
			var dif:int=Y_FIRE_DEF-firesyd[i];
			
			if (fireso[i]>firesd[i]){
				//nos estamos moviendo hacia la izquierda
				tmp=(fireso[i]-firesd[i])/dif;
				firesa[i]-=tmp*F_SPEED;
			}else if (fireso[i]<firesd[i]){
				//nos movemos a la derecha
				tmp=(firesd[i]-fireso[i])/dif;
				firesa[i]+=tmp*F_SPEED;
			}
			firesy[i]-=F_SPEED;
			fires[i].graphics.lineTo(firesa[i],firesy[i]);
		}
		
		function collision(a:int){
			//A es el index del head
			//Sumamos puntos
			score+=100;
			txtpuntos.texto.text=String(score)+" puntos";
			
			//Quitamos el head y la linea
			deleteline(a);
		}

		function destroybase(i:int,j:int){
			//Pintamos explosion
			explosionbuilding(bases[i].x,bases[i].y);
			
			//Quitamos el head que ha causado la colision
			deleteline(j);
			
			//ponemos edificio destruido
			basesdes.push(new basedestroyed());
			var n:int=basesdes.length-1;
			basesdes[n].x=bases[i].x;
			basesdes[n].y=bases[i].y;
			addChild(basesdes[n]);
			
			//Quitamos edificio normal
			if (getQualifiedClassName(bases[i])=='basemissile') canfire=false;
			removeChild(bases[i]);
			bases.splice(i,1);
			
			//comprobamos si quedan más bases. Si no, hemos terminado
			if (bases.length<=0){
				fin_de_juego();
			}
		}
		
		function explosionbuilding(X:int,Y:int){
			//Iniciar explosion 
			var e:explosion=new explosion();
			e.x=X+20;
			e.y=Y-15;
			addChild(e);
		}
		
		function fin_de_juego(){
			inplay=false;
			txtwave.texto.text="FIN DE JUEGO";
			txtmsg.texto.text="GAME OVER";
			txtmsg.visible=true;
			addChild(txtsalir);
			txtsalir.x=260;
			txtsalir.y=530;
			removeEventListener(Event.ENTER_FRAME,nada);
			
			//guardamos puntuacion, si procede
			if (so.data.highScore<score || so.data.highScore==undefined) {
						so.data.highScore=score;
						pmax=score;
						so.flush();
					}
		}
		
		function nada(){
			//No entiendo por qué es necesario esto
		}
		
		function startsWith(haystack:String, needle:String):Boolean {
    	return haystack.indexOf(needle) == 0;
		}
	}
	


	
}
