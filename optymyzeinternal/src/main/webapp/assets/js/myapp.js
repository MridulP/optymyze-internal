$(function() {
		// solving the active menu problem
		switch(menu) {
		
		case 'tab1' :
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


$('.list-group-item').on('click', function() {
    var $this = $(this);
    var $alias = $this.data('alias');

    $('.active').removeClass('active');
    $this.toggleClass('active')

    // Pass clicked link element to another function
    myfunction($this, $alias)
})

function myfunction($this) {
    console.log($this.text());  // Will log Paris | France | etc...

    console.log($alias);  // Will output whatever is in data-alias=""
}