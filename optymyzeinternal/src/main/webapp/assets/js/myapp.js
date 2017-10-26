$(function() {
		// solving the active menu problem
		switch(menu) {
		
		case 'Tab1' :
			$('#tab1').addClass('active');
			break;
		case 'Tab2' :
			$('#tab2').addClass('active');
			break;
		case 'Tab3' :
			$('#tab3').addClass('active');
			break;	
		default:
			$('#home').addClass('active');
			break;	
		
		}
	
	
	
	
});