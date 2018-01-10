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



        <div class="input-group">
          <span class="input-group-addon"><i
            class="glyphicon glyphicon-cloud"></i></span> <input type="text" disabled
            name="projInput" class="form-control" placeholder="Enter Schema"
            required="required" />
        </div>

        <br>

        <div class="input-group">
          <span class="input-group-addon"><i
            class="glyphicon glyphicon-cd"></i></span> <input type="text" disabled
            name="dbInput" class="form-control" placeholder="Enter Hostname"
            required="required" />
        </div>




        <br>

        <div class="input-group">
          <span class="input-group-addon"><i
            class="glyphicon glyphicon-user"></i></span> <input type="text" disabled
            name="userid" class="form-control" placeholder="RO User.."
            required="required" />
        </div>

        <br>

        <div class="input-group">
          <span class="input-group-addon"><i
            class="glyphicon glyphicon-lock"></i></span> <input type="password" disabled
            name="password" class="form-control" placeholder="Password.."
            required="required" />
        </div>
        
        
        <br> <br> <label for="startDate">Start Date:</label>&nbsp
        <input type="text" disabled name="startDate_picker" id="startDate_picker"
          placeholder="Select start date" required="required"
          class="datepicker"> &nbsp &nbsp &nbsp &nbsp 
        
        
      
          <label
          for="endDate">End Date:</label> &nbsp <input type="text" disabled
          name="endDate_picker" id="endDate_picker"
          placeholder="Select end date" required="required"
          class="datepicker"> <br> <br> <br>
          
          <!--  
           <input
          type="submit" name="button3" id="button3" class="btn btn-success"
          value=" Success.." /> -->

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
<!--  
      </form>

			<form action="${pageContext.request.contextPath}/download" id=frms>
          <input type="submit" name="button10" id=button10 class="btn btn-primary" value="Download File" />
		</form> -->
		
		

<div style="width:400px;">
    <div style="float: left; width: 130px"> 
         <form action="${pageContext.request.contextPath}/perlrun" id=frms2>
            	<input type="submit"  name="button3" id="button3" class="btn btn-success"
          value=" Run again.." >
        </form>
    </div>
    <div style="float: right; width: 225px"> 
         <form action="${pageContext.request.contextPath}/download" id=frms>
            <input type="submit" name="button10" id=button10 class="btn btn-primary" value="Download File"/>
        </form>
    </div>
</div>

		
		
  <!--    <td>
 
    <form action="${pageContext.request.contextPath}/download" id=frms> 	<input type="submit" disabled name="button3" id="button3" class="btn btn-success"
          value=" Run again" > &nbsp &nbsp &nbsp &nbsp 
    
          <input type="submit" name="button10" id=button10 class="btn btn-primary" value="Download File"/>
    
     </form>
    <form action="${pageContext.request.contextPath}/perlrun" id=frms2> 	<input type="submit" name="button20" id="button20" class="btn btn-success"
          value="Run again"/ >
    </form>
 
  </td>  -->
	
	<br> <br>
	<br>	
	<div class="alert alert-success" id=alertElement>
  	<strong>Success!</strong> You can click above download button to get report..
	</div>
	
		<script>
		$('input[name=button10]')
		.click(
		     function ()
		     {
		         $(this).hide();
		         $("#alertElement").hide();
		     }
		);
		
		</script>
		
		
		
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

  

  


</div>

</div>