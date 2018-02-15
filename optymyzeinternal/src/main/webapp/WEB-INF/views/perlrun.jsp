<head>
 
<link rel="stylesheet" href="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.2/themes/smoothness/jquery-ui.css" type="text/css" media="all" />
    <style>
    .ui-timepicker-div .ui-widget-header { margin-bottom: 8px; }
    .ui-timepicker-div dl { text-align: left; }
    .ui-timepicker-div dl dt { height: 25px; margin-bottom: -25px; }
    .ui-timepicker-div dl dd { margin: 0 10px 10px 65px; }
    .ui-timepicker-div td { font-size: 90%; }
    .ui-tpicker-grid-label { background: none; border: none; margin: 0; padding: 0; }
    .ui-timepicker-rtl{ direction: rtl; }
    .ui-timepicker-rtl dl { text-align: right; }
    .ui-timepicker-rtl dl dd { margin: 0 65px 10px 10px; }
    
   .ui-datepicker {
   z-index:9999 !important; ;
   }
    
    </style> 

 <link rel="stylesheet" href="${css}/jquery-ui-timepicker-addon.css" />  

</head>



<script src="//ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min.js"></script>
<script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.2/jquery-ui.min.js"></script>
<script src="${js}/jquery-ui-timepicker-addon.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.10.0/jquery.ui.slider.min.js"></script>



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
						name="projInput" class="form-control" placeholder="Enter Schema"
						required="required" />
				</div>

				<br>

				<div class="input-group">
					<span class="input-group-addon"><i
						class="glyphicon glyphicon-cd"></i></span> <input type="text"
						name="dbInput" class="form-control" placeholder="Enter Hostname"
						required="required" />
				</div>


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
				<br> <br> 
				
				
		<!--  		<br> <br> <label for="startDate">Start Date:</label>&nbsp
				<input type="text" name="startDate_picker" id="startDate_picker"
					placeholder="Select start date" required="required"
					class="datepicker"> &nbsp &nbsp &nbsp &nbsp 
				
			
					<label
					for="endDate">End Date:</label> &nbsp <input type="text"
					name="endDate_picker" id="endDate_picker"
					placeholder="Select end date" required="required"
					class="datepicker"> <br> <br> <br>  -->
	 			
			
			
	<!--  	
    <label for="startDate">Start Date:</label>
	<input type="text" name="date_begin" id="date_begin" value="" > &nbsp &nbsp &nbsp &nbsp 
			
			
	  
      <label for="endDate">End Date:
	  <input type="text" name="date_end" id="date_end" value=""  > 
		</div>		-->	
			

<div style="width:400px;">
    <div style="float: left; width: 150px"> 
         
     <label for="startDate">Start Date:</label>       	
     <input type="text" name="startDate_picker" id="startDate_picker" value="" class="form-control" placeholder="Select start date" required="required">
        
    </div>
    <div style="float: right; width: 150px"> 
         <label for="endDate">End Date: </label>  
            <input type="text" name="endDate_picker" id="endDate_picker" value="" class="form-control" placeholder="Select end date" required="required"> 
        
    </div>
</div>

<br><br><br><br><br>



			
			<script>
			$('#startDate_picker,#endDate_picker').datetimepicker(); 
			</script> 
 						


						
				
					
					
					
					
					
					
					
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
		$(document).ready(function(){

		    $("#startDate_picker").datetimepicker({
		        onSelect: function(selected) {
		          $("#endDate_picker").datetimepicker("option","minDate", selected)
		        }
		    });

		    $("#endDate_picker").datetimepicker({		        
		        onSelect: function(selected) {
		    //       $("#startDate_picker").datepicker("option","maxDate", selected)
		        }
		    }); 
		});
		</script>

			<script>
				$(document).ready(function() {
					$("#endDate_picker").datetimepicker({
						"altField2" : "endDate_picker",
					//	"dateFormat" : "mm/dd/yy",
							"dateFormat" : "mm/yy/dd",
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

 

	


</div>

</div>