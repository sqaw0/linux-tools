#!/bin/bash
#<--{variables}--->
port="$(cat settings.txt | grep port | grep -o -E '[0-9]{1,6}')"
iface="$(cat settings.txt | grep interface | sed -r 's/\ .+//')" #interface for scan
ip="$(ip a | grep $iface | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.' | head -1)"
sys_ip="$(ip a | grep $iface | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)"

#<---{functions}--->
function banner() {
    clear
    echo -e "\e[1;36mnc-type\e[0m by sqaw"
}

function scanip() {
    for ((i = 99; i < 164; i++)); do
        timeout 0.2 nc -vn $ip$i $port 1>ipp.dat 2>&1
        if [ "$(cat ipp.dat | grep -o "open")" == "open" ]; then
            echo $ip$i >>ipp.txt
        fi
    done

    rm ipp.dat

    if [ "$1" == "b" ]; then
        banner
    fi

    if [ "$(cat ipp.txt 2>/dev/null | grep $ip)" != "" ]; then
        echo "$(cat ipp.txt | wc -l) clients was found"
    else
        echo -e "\e[31mNo 1st active client was found!\e[0m\nTry to change port or check the active clients."
        sleep 5
        clear && history -c
        exit 0
    fi
}

function exit_f() {
	clear && history -c
	exit 0
}

#<--{prepair}--->
rm ipp.txt 2>/dev/null
touch ipp.txt
clear
trap exit_f SIGINT

#<---{main}--->

banner
echo "Mode:"
echo -e "  1. \e[32mIn\e[0m"
echo -e "  2. \e[31mOut\e[0m"
echo -n "--> "
read mode

if [ "$mode" == "1" ]; then
    banner
    while (true); do
        nc -nlvp 4040
        banner
    done
elif [ "$mode" == "2" ]; then
    banner
    echo -e "\e[5;33mscan ip's\e[0m"
    scanip b
    ip_count="$(cat ipp.txt | wc -l)"
    if [ $ip_count -gt 1 ]; then
        echo "Select ip:"
        for ((i = 1; i <= $ip_count; i++)); do
            echo "  $i. $(sed "$i!d" ipp.txt)"
        done
        echo "--> "
        read ip_num
        ip=$(sed "$ip_num!d" ipp.txt)
    else
        ip=$(head -n 1 ipp.txt)
    fi
    echo -e "connecting to $ip"
    banner
    echo "$sys_ip > $ip"
    nc $ip $port
fi

clear && history -c
