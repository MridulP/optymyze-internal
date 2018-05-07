


<title>Upload File Request Page</title>

<div class="container">

	<div class="row">

		<div class="jumbotron">
			<h2>Detect Character encoding:</h2> <br>
			
			<form action="uploadSuccess?${_csrf.parameterName}=${_csrf.token}" method="POST" enctype="multipart/form-data"> <br>

				
 <h4>File to upload:  <br><input type="file" name="file"  required="required" id=uploadelement style=" color: #fff;background-color: #428bca;border-color: #357ebd;  display: inline-block;
  padding: 6px 12px;
  margin-bottom: 0;
  font-size: 14px;
  font-weight: normal;
  line-height: 1.428571429;
  text-align: center;
  white-space: nowrap;
  vertical-align: middle;
  cursor: pointer;
  -webkit-user-select: none;
     -moz-user-select: none;
      -ms-user-select: none;
       -o-user-select: none;
          user-select: none;
  background-image: none;
  border: 1px solid transparent;
  border-radius: 4px;" > <br> <br> <br>
 			
	
		<input type="submit" name="button13" id=button13  value="Upload" class="btn btn-primary" onclick="Upload_click()"> Press here to upload the file! </h4>
		
		 <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /> 
		
			</form>	  
			
			

			

		<script>
		
		
		//  function Upload_click () {
		 //      alert("Uploaded successfully");
		//   }
		 
		  </script>
		<script>
/*			$('input[name=button13]')
			.click(
			     function ()
			     {         
			         $("#uploadelement").hide();
			     }
			); */
			</script>
		
					</div>
		
		</div>

</div>		