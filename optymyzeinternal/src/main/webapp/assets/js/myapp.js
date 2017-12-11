$(function() {
		// solving the active menu problem
		switch(menu) {
		
		case 'Perlrun' :
		    $('#perlrun').addClass('active');
			break;
		case 'Reporting' :
			$('#reporting').addClass('active');
			break;
		case 'Notification' :
			$('#notification').addClass('active');
			break;	
		default:
			$('#home').addClass('active');
			break;	
		
		}
	
});
