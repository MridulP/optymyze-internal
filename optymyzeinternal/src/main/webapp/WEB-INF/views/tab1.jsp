<div class="container">
	
	<div class="row">
	
	<div class="jumbotron">
        <h2>Perl Script Input:</h2>
        <br>
       <!--  
        <form id="InputForm">
          <div class="form-group">
            <label for="ProjInput">Project Name</label>
            <select class="form-control" id="ProjInput"  placeholder="Select Project">
            <option value="Low">CharterComm_snd</option>
            </select> 
          
          </div>
          <div class="form-group">
            <label for="dbInput">Database Server </label> 
             <select class="form-control" id="idbInput">
              <option value="db1">d34401-b0ca.ca-aws.optymyze.net</option>
              <option value="db2">v-263-op-db3.synprod.net</option>
              <option value="db3">v-supp-oi-db2.syntest.net</option>
            </select> 
          </div>
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
    </table>
</body>
</html>
          --> 
        
          
            <div class="input-group">
           
      <span class="input-group-addon"><i class="glyphicon glyphicon-user"></i></span>
      <input id="userid" type="text" class="form-control" name="email" placeholder="RO User ID..">
    </div>
    <br>
    
    <div class="input-group">
    
      <span class="input-group-addon"><i class="glyphicon glyphicon-lock"></i></span>
      <input id="password" type="password" class="form-control" name="password" placeholder="Password">
    </div>
    
    
          
          <br> 
            
        <!--    <button type="submit" onClick="location.href='/runBatch' " class="btn btn-primary">Run Script</button> -->
          
        <!--   <form action="<c:url value="/runBatch"/>" method="GET"> 
        </form>
        --> 
          
          <form action="${pageContext.request.contextPath}/runBatch.java" method="get">
          <input type="submit" name="button"  class="btn btn-primary"  value="Run Script" />
		  </form>     
        
        
      </div>
      <div class="row">
        <div class="col-lg-12">
          <div id="issuesList">
          </div>
        </div>
      </div>
	
	

</div>

</div>