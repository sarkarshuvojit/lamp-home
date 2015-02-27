## add username shit to the php
echo "<?php \$user = \"$USER\";?>
$(cat index.php)" > index.php 
##move the files to var/www


mv index.php /var/www/html/
mv style.css /var/www/html/
mv icon.png /var/www/html/
mv phpinfo.php /var/www/html/
rm /var/www/html/index.html
