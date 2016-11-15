/*

 WEB INTERFACE and Controll application for an headless squeezelite
 installation.

 Best used with Squeezelite-R2 
 (https://github.com/marcoc1712/squeezelite/releases)

 Copyright 2016 Marco Curti, marcoc1712 at gmail dot com.
 Please visit www.marcoc1712.it

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License,
 version 3.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

################################################################################
*/

var global_audiodevice=null;
var global_preset=null;
var global_reboot=0;
var global_shutdown=0;
var global_needRestart=0; //set to 1 to force restart after a submit.
var global_submitter= null;

$(document).ready(function() {
    
    $('#formSettings').ajaxForm({ 
        success: function(response, status, xhr, jQform) { 
            console.log( "success" );
            console.log( response );
            if (global_needRestart === 1){
                 
                if (document.getElementById('restart').disabled) {
                
                    alert(response);

                } else {

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
                                   enableSettings(initErrorCallback);
                                   loadSettings(initErrorCallback);
                                   loadStatus(initErrorCallback);
                           });
               }
               global_needRestart = 0;
            } else{
                if (response.preset){
                    
                    loadPreset(response);
                }
                
                loadPresets(initErrorCallback);
            }   
        },
        error: function() { 
           console.log( "error" );
           alert("something went wrong!");
        }
    }); 
    // set event listeners.
    document.getElementById("formSettings").onsubmit = function(event){ 

         alert( "Handler for .onsubmit() called. sbmitter" + global_submitter);
         //global_needRestart=1;
         //document.formSettings.action="/cgi-bin/saveSettings.pl";
         //document.formSettings.submit();
         global_submitter=null;
    };
    document.getElementById('submitSettings').onclick = function(){

            alert( "submit button pressed." );
            global_submitter = this;
            document.formSettings.action="/cgi-bin/saveSettings.pl";
            global_needRestart =1;
           // document.formSettings.submit();;
    }

    document.getElementById('savePreset').onclick = function(){

            alert( "save preset button pressed." );
            global_submitter = this;
            document.formSettings.action="/cgi-bin/savePreset.pl";
            global_needRestart=0;
           // document.formSettings.submit();

    }
    document.getElementById('loadPreset').onclick = function(){
            alert( "load preset button pressed." );
            global_submitter = this;
            document.formSettings.action="/cgi-bin/loadPreset.pl";
            global_needRestart=0;
            //document.formSettings.submit();
    }
    document.getElementById('deletePreset').onclick = function(){
            alert( "delete preset button pressed." );
            global_submitter = this;
            document.formSettings.action="/cgi-bin/deletePreset.pl";
            global_needRestart=0;
            document.formSettings.submit();;
    }

    document.getElementById('audioDevice').onchange = function(){
            global_audiodevice= document.getElementById('audioDevice').value;
    };
    document.getElementById('presets').onchange = function(){
            global_preset= document.getElementById('presets').value;
            document.getElementById('preset').value = global_preset;
            presetChanged();
    };
    document.getElementById('preset').onchange = function(){		
            presetChanged();			  
    };
    document.getElementById('preset').oninput = function() {
            presetChanged();
    };
    document.getElementById('preset').onpropertychange = function() {
            presetChanged();
    };
    document.getElementById('preset').onpaste = function() {
            presetChanged();
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
    document.getElementById('allowReboot').onchange = function(){

            if (! document.getElementById("allowReboot").checked){

                    enable("reboot",0);

            } else{

                    enable("reboot",!global_reboot);
            }

    };

    document.getElementById('allowShutdown').onchange = function(){

            if (! document.getElementById("allowShutdown").checked) {

                    enable("shutdown",0);

            } else{

                    enable("shutdown",!global_shutdown);
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
                    loadStatus(initErrorCallback);
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
                    loadStatus(initErrorCallback);
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
                    loadStatus(initErrorCallback);
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
                    console.log( "success but reboot failed..." );
                    // reboot failed
                    alert(data);
            })
            .fail(function(data) {
                    console.log( "error, but reboot succeded" );
                    // reboot succedeed...
                    alert("system is rebooting, please wait some time, then refresh the page");

            })
            .always(function(data) {
                    console.log( "complete" );
            });
    };

});

window.onload = function() {

    init(); //load data.
};
function init() {

    hide(document.getElementById('status'));
    enable("savePreset",0);
    enable("loadPreset",0);
    enable("deletePreset",0);
    document.getElementById('preset').value = global_preset;
                    
    loadAudioDevices(initErrorCallback);
    enableSettings(initErrorCallback);
    loadSettings(initErrorCallback);
    loadStatus(initErrorCallback);
    loadPresets(initErrorCallback);

    initOkCallback();
    return 1;
}
function presetChanged(){
    
    if (!document.getElementById("preset").value || document.getElementById("preset").value === ""){
        enable("savePreset",0);
        enable("loadPreset",0);
        enable("deletePreset",0);
    } else{
        enable("savePreset",1);
        enable("loadPreset",1);
        enable("deletePreset",1);
    }

}
function initErrorCallback(){
    
    document.getElementById("submitSettings").disabled = true;
    document.getElementById("reloadSettings").disabled = true;
    
}
function initOkCallback(){
    
    document.getElementById("submitSettings").disabled = false;
    document.getElementById("reloadSettings").disabled = false;
    
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

	if (element.type === 'checkbox'){
			
            if (value == 1) {
                    element.checked = true;
            }	else {
                    element.checked = false;
            }

	} else if ((element.type === 'text') || 
                   (element.type ==='textarea')){
		
            element.value = value;

	} else if (element.type === 'number'){

            element.value = (value ? value : 0);

	} else if (element.type === 'select-one'){
		
            var values = $.map(element, function(e) { return e.value; });

            if (values.length > 0 && values.length !== "none"){
                    element.value=value;
            } else {
                    element.value="none";
            }
			
	} else if (element.type === 'radio'){

		//tobe handled.
	
	} else { //labels
		
            element.innerHTML = value;

	}
		
}
function loadAudioDevices(errorCallback) {
    
	$("#audioDevice").load('/cgi-bin/loadAudioCards.pl', function(){
	
		if( ($('#audioDevice').has('option').length > 0 ) && (global_audiodevice)){
			 
			document.getElementById('audioDevice').value = global_audiodevice;
		} 
	});
    
}
function loadPresets(errorCallback) {
    
	$("#presets").load('/cgi-bin/loadPresets.pl', function(){
	
		if( ($('#presets').has('option').length > 0 ) && (global_preset)){
			 
			document.getElementById('presets').value = global_preset;
		} 
	});
    
}
function loadPreset(data,errorCallback){
    
    return loadSettingsData(data,errorCallback);
}

function loadSettings(errorCallback) {
    jQuery.getJSON("/cgi-bin/getJSONSettings.pl")
    .done(function(data) {

       return loadSettingsData(data,errorCallback);

    })
    .fail(function() {
            console.log( "error" );
            return 0;
    });
}
function loadSettingsData(data,errorCallback){
    
    if (data.error) { 

        console.log( data.error );
        alert(data.error);
        errorCallback();
        return 0;
    }
    console.log( "load settings succeded" );

    $.each( data, function( key, val ) {
        
        console.log( key + " - " + val);

        if (key === "audioDevice"){

            global_audiodevice= val;

            if( ($('#audioDevice').has('option').length > 0 ) && (global_audiodevice)){

                            document.getElementById('audioDevice').value = global_audiodevice;				  		
            }
        } else if (key === "presets"){

            global_preset= val;

            if( ($('#presets').has('option').length > 0 ) && (global_preset)){

                            document.getElementById('presets').value = global_preset;	
            }
        } 

        load(key,val);
        if (key === "preset"){
            presetChanged();

        } else if (key === "allowReboot"){

            if (val == 1){

                    enable("reboot",!global_reboot);

            } else{

                    enable("reboot",0);
            }
        } else if (key === "allowShutdown"){

            if (val == 1){

                    enable("shutdown",!global_shutdown);

            } else{

                    enable("shutdown",0);
            }
        }
    });
}

function loadStatus(errorCallback) {
    jQuery.getJSON("/cgi-bin/getJSONStatus.pl")
    .done(function(data) {

        if (data.error) { 

            console.log( data.error );
            alert(data.error);
            errorCallback();
            return 0;
        }

        console.log( "success" );

        var isR2version=0;
        var isPathnameValid=0;

        $.each( data, function( key, val ) {
            console.log( key + " - " + val);

            if (key === "isR2version")	{

                            isR2version=1;	

            }	else if (key === "isPathnameValid")	{

                            isPathnameValid=1;

            }	else {

                    load(key,val);
            }

        });

        if (! isPathnameValid){

            document.getElementById("pathname").style.color="red";

            if (!document.getElementById("pathname").value ||
                 document.getElementById("pathname").value === ""){

                document.getElementById("pathname").value="unknow";
            }		
        }	
             enable('lmsDownsampling', 1 );	
        if (! isR2version ){

            document.getElementById("version").style.color="red";

            if (!document.getElementById("version").value ||
                 document.getElementById("version").value === ""){

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

function enableSettings(errorCallback) {
    jQuery.getJSON("/cgi-bin/getJSONDisabled.pl")
    .done(function(data) {

            if (data.error) { 

                console.log( data.error );
                alert(data.error);
                errorCallback();
                return 0;
            }

            console.log( "success" );

            // we need to enable all in order to see changes.

            document.getElementById("shutdown").disabled = false;
            document.getElementById("reboot").disabled = false;
            document.getElementById("start").disabled = false;
            document.getElementById("stop").disabled = false;
            document.getElementById("restart").disabled = false;
            document.getElementById("testAudioDevice").disabled = false;
            document.getElementById("openLog").disabled = false;
            document.getElementById("clearLog").disabled = false;
            //
            document.getElementById("autostart").disabled = false;
            document.getElementById("allowReboot").disabled = false;
            document.getElementById("allowShutdown").disabled = false;
            document.getElementById("allowWakeOnLan").disabled = false;

            $.each( data, function( key, val ) {

                    console.log( key + " - " + val);
                    enable(key, (val ? 0 : 1));// we get only disabled.

            });
            // save configuration settings :	
            global_reboot = document.getElementById("reboot").disabled;
            global_shutdown = document.getElementById("shutdown").disabled;

            if (! document.getElementById("allowReboot").checked){
                    document.getElementById("reboot").disabled = true;
            }
            if (! document.getElementById("allowShutdown").checked){
                    document.getElementById("shutdown").disabled = true;
            }

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
