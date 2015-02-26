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
        <h1>Lamp Home!</h1>
        <br/>
        <h2>It Works!<span style="font-size:15px;">(just like they say everytime ;) )</span></h2>
        <div class="folder-listing">
        <?php printFolders();?>
        </div>
        <footer>
            <p>Created by <a href="http://fb.com/sarkarshuvojit" target="_blank">@sarkarshuvojit</a></p>
        </footer>
    </div>
    
</body>

</html>
