$FormatEnumerationLimit = -1
get-counter -ListSet "*disk*" | where {$_.CounterSetName -eq "PhysicalDisk"} | select Counter | format-table -wrap

#Avg. Disk Sec/Write

#Counter
#-------
#{\PhysicalDisk(*)\Current Disk Queue Length, \PhysicalDisk(*)\% Disk Time, \PhysicalDisk(*)\Avg. Disk Queue Length,
#\PhysicalDisk(*)\% Disk Read Time, \PhysicalDisk(*)\Avg. Disk Read Queue Length, \PhysicalDisk(*)\% Disk Write Time,
#\PhysicalDisk(*)\Avg. Disk Write Queue Length, \PhysicalDisk(*)\Avg. Disk sec/Transfer, \PhysicalDisk(*)\Avg. Disk
#sec/Read, \PhysicalDisk(*)\Avg. Disk sec/Write, \PhysicalDisk(*)\Disk Transfers/sec, \PhysicalDisk(*)\Disk Reads/sec,
#\PhysicalDisk(*)\Disk Writes/sec, \PhysicalDisk(*)\Disk Bytes/sec, \PhysicalDisk(*)\Disk Read Bytes/sec,
#\PhysicalDisk(*)\Disk Write Bytes/sec, \PhysicalDisk(*)\Avg. Disk Bytes/Transfer, \PhysicalDisk(*)\Avg. Disk
#Bytes/Read, \PhysicalDisk(*)\Avg. Disk Bytes/Write, \PhysicalDisk(*)\% Idle Time, \PhysicalDisk(*)\Split IO/Sec}

get-counter -counter '\PhysicalDisk(*)\Avg. Disk sec/Write'| select -ExpandProperty countersamples

$loop = 10
for ($i = 0; $i -lt $loop; $i++) {get-counter -counter '\PhysicalDisk(*)\Avg. Disk sec/Write'| select -ExpandProperty countersamples | format-table -auto}
