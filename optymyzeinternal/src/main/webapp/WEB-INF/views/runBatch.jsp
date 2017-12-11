<html>
<script type="text/javascript" src="http://code.jquery.com/jquery-1.10.2.js"></script>
<script type="text/javascript" src="http://code.jquery.com/ui/1.11.0/jquery-ui.js"></script>
<link rel="stylesheet" href="http://code.jquery.com/ui/1.11.0/themes/smoothness/jquery-ui.css">


<div class="container">

	<div class="row">

		<div class="jumbotron">
			<h2>Script execution completed successfully:</h2>
			<br>					
				
					<br>
					
				    
				    <form action="${pageContext.request.contextPath}/download" id=frms>
					<input type="submit" name="button10" id=button10 class="btn btn-primary" value="Download File" />
					
					
					<script>
					$('#frms').bind('submit', function(e) {
						var button = $('#button10');

						// Disable the submit button while evaluating if the form should be submitted
						button.prop('disabled', true);

						var valid = true;

						// Do stuff (validations, etc) here and set
						// "valid" to false if the validation fails

						if (!valid) {
							// Prevent form from submitting if validation failed
							e.preventDefault();

							// Reactivate the button if the form was not submitted
							button.prop('disabled', false);
						}
					});
				</script>
					
					</form>
					<br>
	
				</div>


</div>
</div>

</html>