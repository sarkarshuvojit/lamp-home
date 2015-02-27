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
        echo '<a href="'.$dir.'">'.$dir."/</a><br/>";
        
    }
}
?>
    <body>
        <div class="center-div">
            <p style="font-size: 45px;">Lamp Home!</p>
            <p class="itWorks">It Works! :D<br/><span style="font-size:15px;">You probably already know that.</span></p>
            <div class="folder-listing">
                <p class="subhead">Projects</p>
                <ul class="folders">
                    <li>xyz/</li>
                    <?php //printFolders();?>
                </ul>
            </div>
            <div class="service-listing">
                <p class="subhead">Services</p>
                <ul class="services">
                    <li>phpMyadmin</li>
                    <li>phpinfo</li>
                </ul>
            </div>            
        </div>
        <footer>
            <p>Created by <a href="http://fb.com/sarkarshuvojit" target="_blank">@sarkarshuvojit</a></p>
        </footer>
    </body>

</html>
