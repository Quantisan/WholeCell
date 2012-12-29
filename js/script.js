/* Functions for 
 * - toggling columns in table view
 * - saving, deleting records from database with AJAX
 *   - display tooltips with status and results
 * - logging, logging out
 *   - display tooltips with status and results
 * 
 * Author: Jonathan Karr, jkarr@stanford.edu
 * Affiliation: Covert Lab, Department of Bioengineering, Stanford University
 * Last Updated: 3/23/2010
 */

function toggleColumn(columnName, display){
	cells = document.getElementsByName(columnName);
	for(j = 0; j < cells.length; j++){
		cells[j].style.display = display ? 'none' : 'table-cell';
	}
}

function saveEntry(query, TableName, WholeCellModelID){
	var page_request = false
	if (window.XMLHttpRequest) // if Mozilla, IE7, Safari etc
		page_request = new XMLHttpRequest()
	else if (window.ActiveXObject){ // if IE6 or below
		try {
		page_request = new ActiveXObject("Msxml2.XMLHTTP")
		} 
		catch (e){
			try{
			page_request = new ActiveXObject("Microsoft.XMLHTTP")
			}
			catch (e){}
		}
	}
	else
		return false
	Tip('Saving '+TableName+' <i>'+WholeCellModelID+'</i> &#8230;', BGCOLOR, '#FFE180', FOLLOWMOUSE, false);
	page_request.onreadystatechange=function(){
		if (page_request.readyState == 4){
			if (page_request.status==200 || window.location.href.indexOf("http")==-1){
				UnTip();
				var data = eval('(' + page_request.responseText + ')');
				if(data.status>0){
					Tip(TableName+' <i>'+WholeCellModelID+'</i> saved'+(data.status>1 ? '.<br/><b>Warnings</b>: ' + data.message : ''), DURATION, 3000, BGCOLOR,'#FFE180', FOLLOWMOUSE, false);
					if(typeof(modalWindow)!=="undefined" && modalWindow!=null) modalWindow.hide();
					if(data.reloadURL){
						window.location=data.reloadURL;
						alert(window.location.split('#')[0],data.reloadURL.split('#'))
						if(window.location.split('#')[0]==data.reloadURL.split('#')[0]) window.location.reload(true);
					}
				}else{
					Tip("Error saving "+TableName+" <i>"+WholeCellModelID+"<i>: "+data.message, DURATION, 10000, BGCOLOR,'#FFE180', FOLLOWMOUSE, false);
				}
			}else{
				UnTip();
				Tip("Error saving "+TableName+" <i>"+WholeCellModelID+"<i>", DURATION, 10000, BGCOLOR,'#FFE180', FOLLOWMOUSE, false);
			}
		}
	}
	page_request.open('POST', 'editKnowledgeBase.php', true)
	page_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
	page_request.send(query)
}

function deleteEntry(query, TableName, WholeCellModelID){
	var page_request = false
	if (window.XMLHttpRequest) // if Mozilla, IE7, Safari etc
		page_request = new XMLHttpRequest()
	else if (window.ActiveXObject){ // if IE6 or below
		try {
		page_request = new ActiveXObject("Msxml2.XMLHTTP")
		} 
		catch (e){
			try{
			page_request = new ActiveXObject("Microsoft.XMLHTTP")
			}
			catch (e){}
		}
	}
	else
		return false
	Tip('Deleting '+TableName+' <i>'+WholeCellModelID+'</i> &#8230;', BGCOLOR, '#FFE180', FOLLOWMOUSE, false);
	page_request.onreadystatechange=function(){
		if (page_request.readyState == 4){
			if (page_request.status==200 || window.location.href.indexOf("http")==-1){
				UnTip();
				var data = eval('(' + page_request.responseText + ')');
				if(data.status>0){
					Tip(TableName+' <i>'+WholeCellModelID+'</i> deleted'+(data.status>1 ? '.<br/><b>Warnings</b>: ' + data.message : ''), DURATION, 3000, BGCOLOR,'#FFE180', FOLLOWMOUSE, false);
					if(typeof(modalWindow)!=="undefined" && modalWindow!=null) modalWindow.hide();
					if(data.reloadURL){
						window.location=data.reloadURL;
						if(window.location.split('#')[0]==data.reloadURL.split('#')[0]) window.location.reload(true);
					}
				}else{
					Tip("Error deleting "+TableName+" <i>"+WholeCellModelID+"<i>: "+data.message, DURATION, 10000, BGCOLOR,'#FFE180', FOLLOWMOUSE, false);
				}
			}else{
				UnTip();
				Tip("Error deleting "+TableName+" <i>"+WholeCellModelID+"<i>", DURATION, 10000, BGCOLOR,'#FFE180', FOLLOWMOUSE, false);
			}
		}
	}
	page_request.open('POST', 'editKnowledgeBase.php', true)
	page_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
	page_request.send(query)
}


function login(query){
	var page_request = false
	if (window.XMLHttpRequest) // if Mozilla, IE7, Safari etc
		page_request = new XMLHttpRequest()
	else if (window.ActiveXObject){ // if IE6 or below
		try {
		page_request = new ActiveXObject("Msxml2.XMLHTTP")
		} 
		catch (e){
			try{
			page_request = new ActiveXObject("Microsoft.XMLHTTP")
			}
			catch (e){}
		}
	}
	else
		return false
	Tip('Logging in ...', BGCOLOR, '#FFE180', FOLLOWMOUSE, false);
	page_request.onreadystatechange=function(){
		if (page_request.readyState == 4){
			if (page_request.status==200 || window.location.href.indexOf("http")==-1){
				UnTip();
				var data = eval('(' + page_request.responseText + ')');
				if(data.status==1){
					Tip('Logged in', DURATION, 3000, BGCOLOR,'#FFE180', FOLLOWMOUSE, false);
					if(typeof(modalWindow)!=="undefined" && modalWindow!=null) modalWindow.hide();
					window.location.reload(true);
				}else{
					Tip(data.message, DURATION, 10000, BGCOLOR,'#FFE180', FOLLOWMOUSE, false);
				}
			}else{
				UnTip();
				Tip("Error logging in", DURATION, 10000, BGCOLOR,'#FFE180', FOLLOWMOUSE, false);
			}
		}
	}
	page_request.open('POST', 'login.php', true)
	page_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
	page_request.send(query)
}

function logoff(query){
	var page_request = false
	if (window.XMLHttpRequest) // if Mozilla, IE7, Safari etc
		page_request = new XMLHttpRequest()
	else if (window.ActiveXObject){ // if IE6 or below
		try {
		page_request = new ActiveXObject("Msxml2.XMLHTTP")
		} 
		catch (e){
			try{
			page_request = new ActiveXObject("Microsoft.XMLHTTP")
			}
			catch (e){}
		}
	}
	else
		return false
	Tip('Logging off ...', BGCOLOR, '#FFE180', FOLLOWMOUSE, false);
	page_request.onreadystatechange=function(){
		if (page_request.readyState == 4){
			if (page_request.status==200 || window.location.href.indexOf("http")==-1){
				UnTip();
				var data = eval('(' + page_request.responseText + ')');
				if(data.status==1){
					Tip('Logged off', DURATION, 3000, BGCOLOR,'#FFE180', FOLLOWMOUSE, false);
					if(typeof(modalWindow)!=="undefined" && modalWindow!=null) modalWindow.hide();
					location.reload(true);
				}else{
					Tip("Error logging off", DURATION, 10000, BGCOLOR,'#FFE180', FOLLOWMOUSE, false);
				}
			}else{
				UnTip();
				Tip("Error logging off", DURATION, 10000, BGCOLOR,'#FFE180', FOLLOWMOUSE, false);
			}
		}
	}
	page_request.open('POST', 'login.php', true)
	page_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
	page_request.send(query)
}