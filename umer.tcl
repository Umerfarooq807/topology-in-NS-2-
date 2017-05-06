#Create a simulator object

set ns [new Simulator]



#Define different colors for data flows (for NAM)

$ns color 1 Blue

$ns color 2 Red



#Open the NAM trace file

set nf [open out.nam w]

$ns namtrace-all $nf



#Define a 'finish' procedure

proc finish {} {

        global ns nf

        $ns flush-trace

        #Close the NAM trace file

        close $nf

        #Execute NAM on the trace file

        exec nam out.nam &

        exit 0

}



#Create four nodes

set s1 [$ns node]

set s2 [$ns node]

set r1 [$ns node]

set r2 [$ns node]


set s3 [$ns node]

set s4 [$ns node]

#Create links between the nodes

$ns duplex-link $s1 $r1 5Mb 3ms DropTail

$ns duplex-link $s2 $r1 5Mb 3ms DropTail

$ns duplex-link $r1 $r2 2Mb 10ms DropTail
$ns duplex-link $r2 $s3 5Mb 3ms DropTail
$ns duplex-link $r2 $s4 5Mb 3ms DropTail



#Set Queue Size of link (n2-n3) to 10

$ns queue-limit $r1 $r2 100



#Give node position (for NAM)

$ns duplex-link-op $s1 $r1 orient right-down

$ns duplex-link-op $s2 $r1 orient right-up

$ns duplex-link-op $r1 $r2 orient right

$ns duplex-link-op $r2 $s3 orient right-down

$ns duplex-link-op $r2 $s4 orient right-up



#Monitor the queue for link (n2-n3). (for NAM)

$ns duplex-link-op $r1 $r2 queuePos 0.5





#Setup a TCP connection

set tcp [new Agent/TCP]

$tcp set class_ 2

$ns attach-agent $s1 $tcp

set sink [new Agent/TCPSink]

$ns attach-agent $r2 $sink

$ns connect $tcp $sink

$tcp set fid_ 1


#Setup a TCP connection

set tcp [new Agent/TCP]

$tcp set class_ 2

$ns attach-agent $s3 $tcp

set sink [new Agent/TCPSink]

$ns attach-agent $r1 $sink

$ns connect $tcp $sink

$tcp set fid_ 1


#Setup a FTP over TCP connection

set ftp [new Application/FTP]

$ftp attach-agent $tcp

$ftp set type_ FTP





#Setup a UDP connection

set udp [new Agent/UDP]

$ns attach-agent $s2 $udp

set null [new Agent/Null]

$ns attach-agent $r2 $null

$ns connect $udp $null

$udp set fid_ 2



#Setup a CBR over UDP connection

set cbr [new Application/Traffic/CBR]

$cbr attach-agent $udp

$cbr set type_ CBR

$cbr set packet_size_ 5

$cbr set rate_ 1mb

$cbr set random_ false





#Schedule events for the CBR and FTP agents

$ns at 0.1 "$cbr start"

$ns at 1.0 "$ftp start"

$ns at 4.0 "$ftp stop"

$ns at 4.5 "$cbr stop"



#Detach tcp and sink agents (not really necessary)

$ns at 4.5 "$ns detach-agent $s1 $tcp ; $ns detach-agent $r2 $sink"



#Call the finish procedure after 5 seconds of simulation time

$ns at 5.0 "finish"



#Print CBR packet size and interval

puts "CBR packet size = [$cbr set packet_size_]"

puts "CBR interval = [$cbr set interval_]"



#Run the simulation

$ns run

