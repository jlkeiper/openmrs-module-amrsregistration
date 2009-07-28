
	$j = jQuery.noConflict();
	$j(document).ready(function() {
		
		//if close button is clicked
		$j('#clear').click(function (e) {
			//Cancel the link behavior
			e.preventDefault();
			
			$j('#mask').hide();
			$j('.window').hide();
		});
		
		//if mask is clicked
		$j('#mask').click(function () {
			$j(this).hide();
			$j('.window').hide();
		});
		
		$j(window).bind('resize', function() {
			//Get the screen height and width
			var maskHeight = $j(document).height();
			var maskWidth = $j(window).width();
			 
			//Set heigth and width to mask to fill up the whole screen
			$j('#mask').css({'width':maskWidth,'height':maskHeight});
			
			//Get the window height and width
			var winH = $j(window).height();
			var winW = $j(window).width();
			
			var id = "#dialog";
			
			//Set the popup window to center
			$j(id).css('top',  winH/2-($j(id).height()/2));
			$j(id).css('left', winW/2-($j(id).width()/2));
		});
		
	});
	
    function animatePatientData() {
		
		// fancy stuff to create modal dialog
		
		//Get the window height and width
		var winH = $j(window).height();
		var winW = $j(window).width();
		
		var id = "#dialog";
		
		//Set the popup window to center
		$j(id).css('top',  winH/2-($j(id).height()/2));
		$j(id).css('left', winW/2-($j(id).width()/2));
		
		//transition effect
		$j(id).fadeIn(0);
		
		//Get the screen height and width
		var maskHeight = $j(document).height();
		var maskWidth = $j(window).width();
		
		//Set heigth and width to mask to fill up the whole screen
		$j('#mask').css({'width':maskWidth,'height':maskHeight});
		
		//transition effect		
		$j('#mask').fadeIn(0);	
		$j('#mask').fadeTo(0, 0.8);
    }
	
	function replaceNull (nullInput) {
		if (nullInput == null)
			return "";
		else
			return nullInput
	}
	
	function parseDate(d, format) {
		var str = '';
		if (d != null) {
			
			// get the month, day, year values
			var month = "";
			var day = "";
			var year = "";
			var date = d.getDate();
			
			if (date < 10)
				day += "0";
			day += date;
			var m = d.getMonth() + 1;
			if (m < 10)
				month += "0";
			month += m;
			if (d.getYear() < 1900)
				year = (d.getYear() + 1900);
			else
				year = d.getYear();
		
			var datePattern = format;
			var sep = datePattern.substr(2,1);
			var datePatternStart = datePattern.substr(0,1).toLowerCase();
			
			if (datePatternStart == 'm') /* M-D-Y */
				str = month + sep + day + sep + year
			else if (datePatternStart == 'y') /* Y-M-D */
				str = year + sep + month + sep + day
			else /* (datePatternStart == 'd') D-M-Y */
				str = day + sep + month + sep + year
			
		}
		return str;
	}

    function focusOnTextBox(id) {
        var idCardInput = document.getElementById(id);
        idCardInput.focus();
    }