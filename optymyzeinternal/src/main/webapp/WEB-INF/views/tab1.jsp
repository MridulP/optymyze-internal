<script type="text/javascript" src="//resources/js/datepicker.js"> </script>

<div class="container">

	<div class="row">

		<div class="jumbotron">
			<h2>Perl Script Input:</h2>
			<br>

			<form id="InputForm">
				<div class="form-group">
					<label for="ProjInput">Project Name</label> <select
						class="form-control" id="ProjInput" placeholder="Select Project">
						<option value="Low">Select Project</option>
						<option value="Low">DESJARDINS_SND2_SPM</option>
					</select>

				</div>
				<div class="form-group">
					<label for="dbInput">Database Server </label> <select
						class="form-control" id="dbInput">
						<option value="db1">Select Database</option>
						<option value="db2">d34401-b0ca.ca-aws.optymyze.net</option>

					</select>
				</div>
				<br>
				<!-- 
          <div class="form-group">
            <label for="paramone">Parameter 1</label>
            <input type="text" class="form-control" id="issueAssignedToInput" placeholder="Enter Parameter 1 ...">
          </div>
           <div class="form-group">
            <label for="param2">Parameter 2</label>
            <input type="text" class="form-control" id="issueAssignedToInput" placeholder="Enter Parameter 2 ...">
          </div>
           
          
          <table>
        <tr> <td>User Name: </td> <td><input type="text" name="userName" value="" placeholder="User Name"></input></td> <br>
         <td>User Password: </td> <td><input type="text" name="userPassword" value="" placeholder="User Password"></input></td> 
        <tr><td><input type="submit"></input></td> </tr>
         
    </table> -->

				</body>
				</html>

				<div class="input-group">

					<span class="input-group-addon"><i
						class="glyphicon glyphicon-user"></i></span> <input id="userid"
						type="text" class="form-control" name="user"
						placeholder="RO User ID..">
				</div>
				<br>

				<div class="input-group">

					<span class="input-group-addon"><i
						class="glyphicon glyphicon-lock"></i></span> <input id="password"
						type="password" class="form-control" name="password"
						placeholder="Password">
				</div>	

				<br>
				<form action="${pageContext.request.contextPath}/runBatch"
					method="get">
					<input type="submit" name="button3" class="btn btn-primary"
						value="Execute Script" />
				</form>
				<br>




<div class="container">
    <div class='col-md-5'>
        <div class="form-group">
            <div class='input-group date' id='datetimepicker6'>
                <input type='text' class="form-control" />
                <span class="input-group-addon">
                    <span class="glyphicon glyphicon-calendar"></span>
                </span>
            </div>
        </div>
    </div>
    <div class='col-md-5'>
        <div class="form-group">
            <div class='input-group date' id='datetimepicker7'>
                <input type='text' class="form-control" />
                <span class="input-group-addon">
                    <span class="glyphicon glyphicon-calendar"></span>
                </span>
            </div>
        </div>
    </div>
</div>







		</div>
		<div class="row">
			<div class="col-lg-12">
				<div id="issuesList"></div>
			</div>
		</div>


	</div>

</div>