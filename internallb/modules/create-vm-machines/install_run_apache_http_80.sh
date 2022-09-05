
#!/bin/bash
install_updates()
{
        sudo yum update -y
}
install_apache()
{
        sudo yum -y install httpd
        sudo systemctl enable httpd
}
start_apache()
{
        sudo systemctl start httpd
        sudo systemctl status httpd
}
install_updates
status_update=$?
if [ $status_update -eq 0 ]
 then
     echo "Installing apache............"
     install_apache
     status_install=$?
fi
if [ $status_install -eq 0 ]
then
        start_apache
fi