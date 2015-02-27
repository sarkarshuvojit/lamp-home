<?php $user = "shuvojit";?>
<?php $user = "shuvojit";?>
<html>
    <head>
        <title>Lamp Server - Welcome Page</title>
        <link rel="stylesheet" href="style.css"/>
    </head>
<?php
function printFolders(){
    $Mydir = '';

    foreach(glob($Mydir.'*', GLOB_ONLYDIR) as $dir) {
        $dir = str_replace($Mydir, '', $dir);
        if($dir != "files")
            echo '<li><a href="'.$dir.'">'.$dir."</a></li>";
        
    }
}
?>
    <body>
        <div class="center-div">
            <p style="font-size: 45px;">welcome <?php echo $user;?>!</p>
            <p class="itWorks">It Works! :D<br/><span style="font-size:15px;">You probably already know that.</span></p>
            <div class="folder-listing">
                <p class="subhead">Projects</p>
                <ul class="folders">                    
                    <?php printFolders();?>
                </ul>
            </div>
            <div class="service-listing">
                <p class="subhead">Services</p>
                <ul class="services">
                    <li><a href="phpmyadmin/">phpMyadmin</a></li>
                    <li><a href="phpinfo.php">phpinfo</a></li>
                </ul>
            </div>            
        </div>
        <footer>
            <p>Created by <a href="http://www.github.com/sarkarshuvojit" target="_blank">@sarkarshuvojit</a></p>
        </footer>
    </body>

</html>
