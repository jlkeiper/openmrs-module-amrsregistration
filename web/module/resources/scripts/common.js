
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
	
	function replaceNull(nullInput) {
		if (nullInput == null)
			return "";
		else
			return nullInput
	}