$remoteport = bash.exe -c "ifconfig eth0 | grep 'inet '"
$found = $remoteport -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';

if( $found ) {
  $remoteport = $matches[0];
} else {
  echo "The Script Exited, the ip address of WSL 2 cannot be found";
  exit;
}

#[Ports]

# All the ports you want to forward separated by coma
$ports=@(22,80,443,8080,6666,6667,10000,3000,5000,51413);

for( $append_port = 22000; $append_port -lt 22223; $append_port++ ) {
  $ports += $append_port;
}

## Mosh doesn't work because WSL doesn't forward UDP ports
#
#for( $append_port_mosh = 60000; $append_port_mosh -lt 61001; $append_port_mosh++ ) {
#  $ports += $append_port_mosh;
#}

#[Static ip]
#You can change the addr to your ip config to listen to a specific address
$addr='0.0.0.0';
$ports_a = $ports -join ",";


# Remove Firewall Exception Rules
iex "Remove-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' ";
iex "Remove-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock UDP' ";

# Add Exception Rules for inbound and outbound Rules
iex "New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Outbound -LocalPort $ports_a -Action Allow -Protocol TCP";
iex "New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Inbound -LocalPort $ports_a -Action Allow -Protocol TCP";
iex "New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock UDP' -Direction Outbound -LocalPort $ports_a -Action Allow -Protocol UDP";
iex "New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock UDP' -Direction Inbound -LocalPort $ports_a -Action Allow -Protocol UDP";

# Reset interface portproxy and recreate it below
iex "netsh interface portproxy reset v4tov4";

for( $i = 0; $i -lt $ports.length; $i++ ) {
  $port = $ports[$i];
  iex "netsh interface portproxy add v4tov4 listenport=$port listenaddress=$addr connectport=$port connectaddress=$remoteport";
}

iex "netsh interface portproxy show all";

bash.exe -c "sudo service ssh start"
bash.exe -c "sudo service nginx start"
