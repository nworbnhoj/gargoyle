function checkKey(e){var keycode=0;if(window.event)keycode=window.event.keyCode;else if(e)keycode=e.which;if(keycode==13)runCmd()}function runCmd(){var Commands=[];Commands.push(document.getElementById("cmd").value);setControlsEnabled(false,true,UI.Wait);var param=getParameterDefinition("commands",Commands.join("\n"))+"&"+getParameterDefinition("hash",document.cookie.replace(/^.*hash=/,"").replace(/[\t ;]+.*$/,""));var stateChangeFunction=function(req){if(req.readyState==4){document.getElementById("output").value=req.responseText;setControlsEnabled(true)}};runAjax("POST","utility/run_commands.sh",param,stateChangeFunction)}