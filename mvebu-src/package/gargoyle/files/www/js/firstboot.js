var fbS=new Object;function setInitialSettings(){var p1=document.getElementById("password1").value;var p2=document.getElementById("password2").value;if(p1.length==0&&p2.length==0){alert(fbS.nopsErr)}else if(p1!=p2){alert(fbS.pseqErr)}else{setControlsEnabled(false,true);var saveCommands="";var browserSecondsUtc=Math.floor((new Date).getTime()/1e3);var escapedPassword=p1.replace(/'/,"'\"'\"'");saveCommands="(echo '"+escapedPassword+"' ; sleep 1 ; echo '"+escapedPassword+"') | passwd root \n";saveCommands=saveCommands+"\nuci set system.@system[0].timezone='"+getSelectedValue("timezone")+"'\n";saveCommands=saveCommands+"\nuci del gargoyle.global.is_first_boot\nuci commit\n";saveCommands=saveCommands+"\nuci show system | grep timezone | sed 's/^.*=//g' | sed \"s/'//g\" >/etc/TZ 2>/dev/null\n";saveCommands=saveCommands+"\n/etc/init.d/dropbear restart 2>/dev/null\n";saveCommands=saveCommands+"\n/etc/init.d/sysntpd restart >/dev/null 2>&1\n/usr/bin/set_kernel_timezone >/dev/null 2>&1\n";saveCommands=saveCommands+"\ntouch /etc/banner  >/dev/null 2>&1\n";saveCommands=saveCommands+'\neval $( gargoyle_session_validator -g -a "'+httpUserAgent+'" -i "'+remoteAddr+'" -b '+browserSecondsUtc+" )";var param=getParameterDefinition("commands",saveCommands)+"&"+getParameterDefinition("hash",document.cookie.replace(/^.*hash=/,"").replace(/[\t ;]+.*$/,""));var stateChangeFunction=function(req){if(req.readyState==4){var hashCookie="";var expCookie="";var responseLines=req.responseText.split(/[\r\n]+/);var rIndex=0;for(rIndex=0;rIndex<responseLines.length;rIndex++){if(responseLines[rIndex].match(/hash=/)){hashCookie=responseLines[rIndex].replace(/^.*hash=/,"").replace(/\";.*$/,"")}if(responseLines[rIndex].match(/exp=/)){expCookie=responseLines[rIndex].replace(/^.*exp=/,"").replace(/\";.*$/,"")}}document.cookie="hash="+hashCookie;document.cookie="exp="+expCookie;currentProtocol=location.href.match(/^https:/)?"https":"http";window.location=currentProtocol+"://"+window.location.host+"/basic.sh"}};runAjax("POST","utility/run_commands.sh",param,stateChangeFunction)}}