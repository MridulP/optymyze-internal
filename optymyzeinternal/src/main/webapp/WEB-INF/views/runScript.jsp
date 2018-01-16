<script type="text/javascript"
  src="http://code.jquery.com/jquery-1.10.2.js"></script>
<script type="text/javascript"
  src="http://code.jquery.com/ui/1.11.0/jquery-ui.js"></script>
<link rel="stylesheet"
  href="http://code.jquery.com/ui/1.11.0/themes/smoothness/jquery-ui.css">


<div class="container">

	<div class="row">

	<div class="jumbotron">
			<h2>Detect Character encoding:</h2> <br> <br>
			
				<h4>File to upload:  <br><input type="file" disabled name="file"  required="required" id=uploadelement style=" color: #fff;background-color: #428bca;border-color: #357ebd;  display: inline-block;
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
			
				
			
  <input type="submit" disabled name="button13" id=button13  value="Upload" class="btn btn-primary" onclick="Upload_click()"> <b>File uploaded successfully!</b></h4>
		
<br>			<br> 
			
		<div style="width:400px;">
    <div style="float: left; width: 130px"> 
         <form action="${pageContext.request.contextPath}/charDetect" id=frms3>
              <input type="submit" name="button14" id=button14 class="btn btn-success" value="Run again"  />
        </form>
    </div>
    <div style="float: right; width: 225px"> 
         <form action="${pageContext.request.contextPath}/download2" id=frms>
            <input type="submit" name="button12" id=button12 class="btn btn-primary" value="Download"  />
        </form>
    </div>
</div>
<br><br><br>
<div class="alert alert-success" id=alertElement2>
  	<strong>Script ran successfully!</strong> You can click above download button to get report..
	</div>
			
			<script>
		$('input[name=button12]')
		.click(
		     function ()
		     {
		         $(this).hide();
		         $("#alertElement2").hide();
		     }
		);
		
		</script>
			
			
			
</div>
</div>
</div>	
