    <div class="container">

        <div class="row">
         
            <div class="col-md-3">
                <p class="lead">Task to Execute</p>
                <div class="list-group">
                    <a href="perlrun"  class="list-group-item" >Concurrent User Session</a>
                    <a href="charDetect"  class="list-group-item">Detect Character Encoding</a>
                    <a href="reporting"  class="list-group-item">Report Schedule</a>
                    <a href="notification"  class="list-group-item">Alert Management</a>
                </div>
            </div>

            <div class="col-md-9">

                <div class="row carousel-holder">

                    <div class="col-md-12">
                        <div class="carousel slide" id="myCarousel">
                            <ol class="carousel-indicators">
                                <li data-target="#myCarousel" data-slide-to="0" ></li>
                                <li data-target="#myCarousel" data-slide-to="1"></li>
                                <li data-target="#myCarousel" data-slide-to="2"></li>
                            </ol>
                            
                            <div class="carousel-inner">
                                <div class="item active" id="slide1">
                                
                                <!--http://placehold.it/800x300  -->
                                
                                    <img class="slide-image" src="${images}/image1.jpg" alt="">
                                </div>
                                <div class="item">
                                    <img class="slide-image" src="${images}/image2.jpg"  alt="">
                                </div>
                                <div class="item">
                                    <img class="slide-image" src="${images}/pic3.jpg" alt="">
                                </div>
                            </div>
                            <!-- "#carousel-example-generic" -->
                            <a class="left carousel-control" href="#myCarousel" data-slide="prev">
                                <span class="glyphicon glyphicon-chevron-left"></span>
                            </a>
                            <a class="right carousel-control" href="#myCarousel" data-slide="next">
                                <span class="glyphicon glyphicon-chevron-right"></span>
                            </a>
                        </div>
                    </div>
                    <script>
                    $('.myCarousel').carousel({
                    interval : 2000
                    
                     })
                    </script>  
                
                </div> 
  <!--  
                    <div class="col-sm-4 col-lg-4 col-md-4">
                        <h4><a href="#">Feedback for improvement</a>
                        </h4>
                        <p>You can click below button to share with us.</p>
                        <a class="btn btn-primary" target="_blank" href="MAILTO:oz-support@optymyze.com?subject=Feedback Optymyze Support Internal">Feedback</a> -->
                        
                       <!--   <a style="float:right" href="MAILTO:oz-support@optymyze.com?subject=Feedback Optymyze Suppor Internal">Request an Account</a>  -->
                        
                    </div>

                </div>

            </div>

        </div>

    </div>
    <!-- /.container -->