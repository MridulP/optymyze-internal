<script type="text/javascript"
	src="http://code.jquery.com/jquery-1.10.2.js"></script>
<script type="text/javascript"
	src="http://code.jquery.com/ui/1.11.0/jquery-ui.js"></script>
<link rel="stylesheet"
	href="http://code.jquery.com/ui/1.11.0/themes/smoothness/jquery-ui.css">


<div class="container">

	<div class="row">

		<div class="jumbotron">
			<h2>Perl Script Input:</h2>
			<br>

			<form action="${pageContext.request.contextPath}/runBatch"
				method="post" id="frm">

				<div class="input-group">
					<span class="input-group-addon"><i
						class="glyphicon glyphicon-cloud"></i></span> <input type="text"
						name="projInput" class="form-control" placeholder="Enter Project"
						required="required" />
				</div>

				<br>

				<div class="input-group">
					<span class="input-group-addon"><i
						class="glyphicon glyphicon-cd"></i></span> <input type="text"
						name="dbInput" class="form-control" placeholder="Enter Database"
						required="required" />
				</div>



				<!--		<div class="input-group">
					<span class="input-group-addon"><i
						class="glyphicon glyphicon-cd"></i></span>		
				      <select
						class="form-control" name="dbinput"  id="dbInput" placeholder="Enter Database">
						<option value="Low">Select Database</option>
						<option value="Low">DESJARDINS_SND2_SPM</option>
					</select>
					</div> -->

				<br>

				<div class="input-group">
					<span class="input-group-addon"><i
						class="glyphicon glyphicon-user"></i></span> <input type="text"
						name="userid" class="form-control" placeholder="RO User.."
						required="required" />
				</div>

				<br>

				<div class="input-group">
					<span class="input-group-addon"><i
						class="glyphicon glyphicon-lock"></i></span> <input type="password"
						name="password" class="form-control" placeholder="Password.."
						required="required" />
				</div>

				<br> <br> <label for="startDate">Start Date:</label>&nbsp
				<input type="text" name="startDate_picker" id="startDate_picker"
					placeholder="Select start date" required="required"
					class="datepicker"> &nbsp &nbsp &nbsp &nbsp 
					
					<label
					for="endDate">End Date:</label> &nbsp <input type="text"
					name="endDate_picker" id="endDate_picker"
					placeholder="Select end date" required="required"
					class="datepicker"> <br> <br> <br>
					
					 <input
					type="submit" name="button3" id="button3" class="btn btn-primary"
					value="Run Script" />

				<script>
					$('#frm').bind('submit', function(e) {
						var button = $('#button3');

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





			<script>
				$(document).ready(function() {
					$("#endDate_picker").datepicker({
						"altField2" : "endDate_picker",
						"dateFormat" : "mm/dd/yy",
						"altFormat" : "YY-m-dd",
						"changeMonth" : true,
						"changeYear" : true
					});
				});
			</script>

		</div>

		<script>
			$(document).ready(function() {
				$("#startDate_picker").datepicker({
					"altField" : "startDate_picker",
					"dateFormat" : "mm/dd/yy",
					"altFormat" : "YY-m-dd",
					"changeMonth" : true,
					"changeYear" : true
				});
			});
		</script>

		</form>

	</div>
	<div class="row">
		<div class="col-lg-12">
			<div id="issuesList"></div>
		</div>
	</div>


</div>

</div>