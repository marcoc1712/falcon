
// AudioDevices are loaded in asynchronous mode. 
// Whenever settings are loaded, it could happen the list is still empty
// then the actual value is stored and selected at the end of audioDevice loading.

var global_audiodevice=null;

window.onload = function() {

	init(); //load data.
	
	// set event listeners.
	
	document.getElementById('audioDevice').onchange = function(){
		global_audiodevice= document.getElementById('audioDevice').value;
	};
	
	document.getElementById('logFile').onchange = function(){
					
		if (!document.getElementById("logFile").value){
				enable("openLog",0);
				enable("clearLog",0);
		} else{
				enable("openLog",1);
				enable("clearLog",1);
		}				
	};



	document.getElementById('reloadSettings').onclick = function(){
		loadSettings();
	}
        
        document.getElementById('testAudioDevice').onclick = function(){
		window.open('/htm/testAudioDevice.html');
	};
        
        document.getElementById('openLog').onclick = function(){
		window.open('/htm/openLog.html');
	};
        
	document.getElementById('clearLog').onclick = function(){
		jQuery.get("/cgi-bin/clearLog.pl")
		.done(function(data) {
			console.log( "success" );
		})
		.fail(function(data) {
			console.log( "error" );
		})
		.always(function(data) {
			console.log( "complete" );
			alert(data);
		});		
	};

	document.getElementById('start').onclick = function(){
		jQuery.get("/cgi-bin/serviceStart.pl")
		.done(function(data) {
			console.log( "success" );
		})
		.fail(function(data) {
			console.log( "error" );
		})
		.always(function(data) {
			console.log( "complete" );
			alert(data);
		});
	};

	document.getElementById('stop').onclick = function(){
		jQuery.get("/cgi-bin/serviceStop.pl")
		.done(function(data) {
			console.log( "success" );
		})
		.fail(function(data) {
			console.log( "error" );
		})
		.always(function(data) {
			console.log( "complete" );
			alert(data);
		});
	};

	document.getElementById('restart').onclick = function(){
		jQuery.get("/cgi-bin/serviceRestart.pl")
		.done(function(data) {
			console.log( "success" );
		})
		.fail(function(data) {
			console.log( "error" );
		})
		.always(function(data) {
			console.log( "complete" );
			alert(data);
		});
	};

	document.getElementById('shutdown').onclick = function(){
		jQuery.get("/cgi-bin/hwShutdown.pl")
		.done(function(data) {
			console.log( "success" );
		})
		.fail(function(data) {
			console.log( "error" );
		})
		.always(function(data) {
			console.log( "complete" );
			alert(data);
		});
	};

	document.getElementById('reboot').onclick = function(){
		jQuery.get("/cgi-bin/hwReboot.pl")
		.done(function(data) {
			console.log( "success" );
		})
		.fail(function(data) {
			console.log( "error" );
		})
		.always(function(data) {
			console.log( "complete" );
			alert(data);
		});
	};

};

function init() {

	$("#audioDevice").load('/cgi-bin/loadAudioCards.pl', function(){
	
		if( ($('#audioDevice').has('option').length > 0 ) && (global_audiodevice)){
			 
			document.getElementById('audioDevice').value = global_audiodevice;
		}

	});
	hide(document.getElementById('status'));
	loadSettings();
	enableSettings();
	loadStatus();
}

function enable(item,value) {
	
	var element = document.getElementById(item);
	if (! element) {return false;}	
	
	if (value == 1) {
		element.disabled=false;
	}	else {
		element.disabled=true;
	}
}

function load(item,value) {

	var element = document.getElementById(item);
	if (! element) {return false;}

	if (element.type == 'checkbox'){
			
			if (value ==1) {
				element.checked = true;
			}	else {
				element.checked = false;
			}

	} else if ((element.type == 'text') || 
						 (element.type == 'textarea')){
		
		element.value = value;

	} else if (element.type == 'number'){

		element.value = (value ? value : 0);

	} else if (element.type == 'select-one'){
		
		var values = $.map(element, function(e) { return e.value; });

		if (values.length > 0 ){

	  	element.value=value;

		}
			
	} else if (element.type == 'radio'){

		//tobe handled.
	
	} else { //labels
		
		element.innerHTML = value;

	}
		
}

function loadSettings() {
	jQuery.getJSON("/cgi-bin/getJSONSettings.pl")
	.done(function(data) {
		console.log( "success" );
		$.each( data, function( key, val ) {
			console.log( key + " - " + val);
		
			if (key == "audioDevice"){
				
					// special case, options could not be already retrieved .
					// store a global variable, used whe deferred load will end.
	
					global_audiodevice= val;
					
					if( ($('#audioDevice').has('option').length > 0 ) && (global_audiodevice)){
					
						document.getElementById('audioDevice').value = global_audiodevice;				  		
					}
			}

			load(key,val);
		});
	})
	.fail(function() {
		console.log( "error" );
	})
	.always(function() {
		console.log( "complete" );
	});
}

function loadStatus() {
	jQuery.getJSON("/cgi-bin/getJSONStatus.pl")
	.done(function(data) {
		console.log( "success" );
		
		var isR2version=0;
		var isPathnameValid=0;

		$.each( data, function( key, val ) {
			console.log( key + " - " + val);
			
			if (key == "isR2version")	{
					
					isR2version=1;	

			}	else if (key == "isPathnameValid")	{
					
					isPathnameValid=1;

			}	else {
		
				load(key,val);
			}

		});
		
		if (! isPathnameValid){

			document.getElementById("pathname").style.color="red";

			if (!document.getElementById("pathname").value ||
					document.getElementById("pathname").value == ""){

					document.getElementById("pathname").value="unknow";
			}		
		}	
					
	 if (! isR2version ){

			document.getElementById("version").style.color="red";

			if (!document.getElementById("version").value ||
					document.getElementById("version").value == ""){

					document.getElementById("version").value="unknow (not R2)";
					document.getElementById("lmsDownsampling").checked;
					enable('lmsDownsampling', 0 );
					
			}	
		}	

	})
	.fail(function() {
		console.log( "error" );
	})
	.always(function() {
		console.log( "complete" );
	});
}

function enableSettings() {
	jQuery.getJSON("/cgi-bin/getJSONDisabled.pl")
	.done(function(data) {
		console.log( "success" );
		$.each( data, function( key, val ) {

			console.log( key + " - " + val);
			enable(key, (val ? 0 : 1));// we get disabled.

		});
	})
	.fail(function() {
		console.log( "error" );
	})
	.always(function() {
		console.log( "complete" );
	});
}

function hide (elements) {
		elements = elements.length ? elements : [elements];
		for (var index = 0; index < elements.length; index++) {
			elements[index].style.display = 'none';
		}
}

function show (elements) {
		elements = elements.length ? elements : [elements];
		for (var index = 0; index < elements.length; index++) {
			elements[index].style.display = 'block';
		}
}
function hideAll() {
		hide(document.getElementById('status'));
		hide(document.getElementById('settings'));
}

function showSettings () {
		hide(document.getElementById('status'));
		show(document.getElementById('settings'));
}

function showStatus () {
		hide(document.getElementById('settings'));
		show(document.getElementById('status'));
}
