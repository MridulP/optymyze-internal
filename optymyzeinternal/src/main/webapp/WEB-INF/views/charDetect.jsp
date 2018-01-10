<title>Upload File Request Page</title>

<div class="container">

	<div class="row">

		<div class="jumbotron">
			<h2>Detect Character encoding:</h2> <br>
			
			<form  action="uploadSuccess" method="POST" enctype="multipart/form-data"> <br>
			
				<p>File to upload:  <input type="file" name="file"  required="required" id=uploadelement > <br> <br>
 			
		<!--  		Name: <input type="text" name="name"> -->
 
			<input type="submit" name="button13" id=button13  value="Upload"> Press here to upload the file! </p>
			</form>	

		<script>
			$('input[name=button13]')
			.click(
			     function ()
			     {
			         
			         $("#uploadelement").hide();
			     }
			);
			</script>
		
					</div>
		
		</div>

</div>		