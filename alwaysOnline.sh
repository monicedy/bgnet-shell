TITLE="【BG-NET】"
SLP=4

paraFlag=0
# acctInfo=""
acctPath='info.conf'
acctInfo=`cat $acctPath`

getAccts(){
        acctNum=`echo $acctInfo | awk -F ';' '{print $1}'`
        t=$(date +%s)
        rdn=`expr $t % $acctNum`
        rdn=`expr $rdn + 2`

        acct=`echo $acctInfo | awk -F ';' -v n=$rdn '{print $n}' | awk -F ',' '{print $1}'`
        pswd=`echo $acctInfo | awk -F ';' -v n=$rdn '{print $n}' | awk -F ',' '{print $2}'`
        d3="&R1=0&R2=0&R3=0&R6=0&para=00&0MKKey=123456"
        d2="&upass="$pswd
        d1="DDDDD=,0,"$acct
        postData=$d1$d2$d3
}

getParas(){
        if [ $paraFlag -eq 1]
        then
            return 0
        fi
        res=`curl -Ls -w %{url_effective} -o /dev/null http://1.1.1.1`
        stat=`echo $res | grep 1.1.1.1`
        if [ $? -eq 0 ]
            then
            return 1
        fi
        paraFlag=1
        wlanuserip=`echo $res | awk -F '&' '{print $1}' | awk -F '=' '{print $2}'`
        wlanacname=`echo $res | awk -F '&' '{print $2}' | awk -F '=' '{print $2}'`
        wlanacip=`echo $res | awk -F '&' '{print $3}' | awk -F '=' '{print $2}'`
        wlanusermac=`echo $res | awk -F '&' '{print $4}' | awk -F '=' '{print $2}'`
        wlanusermac=${wlanusermac:0:2}'-'${wlanusermac:2:2}'-'${wlanusermac:4:2}'-'${wlanusermac:6:2}'-'${wlanusermac:8:2}'-'${wlanusermac:10:2}
        postUrl="http://192.168.7.221:801/eportal/?c=ACSetting&a=Login&protocol=http:&hostname=192.168.7.221&iTermType=1&wlanuserip="$wlanuserip"&wlanacip="$wlanacip"&wlanacname="$wlanacname"&mac="$wlanusermac"&ip="$wlanuserip"&enAdvert=0&queryACIP=0&loginMethod=1"
}

checkPing(){
    ping www.baidu.com -c 2 -w 6 -W 6 > /dev/null
}

updateTime(){
    curTime=$(date "+%m.%d %H:%M:%S")
}

log(){
    updateTime
    logMsg=$curTime" "$1

    echo $logMsg
    logger -t $TITLE $logMsg
}

login(){
    getAccts
    getParas
    if [ $? -eq 1 ]
        then
        return 1
    fi

    curl -d $postData $postUrl
    sleep 3
   #  log "acct: "$acct", pswd: "$pswd
}

dynSlp(){
    slpTime=$1
    while [ $slpTime -gt 0 ]
    do
        getAccts
        curl -d $postData $postUrl
        log "reconn..."
      #   log "acct: "$acct", pswd: "$pswd

        checkPing
        if [ $? -eq 0 ]
            then
            return 0
        fi
        slpTime=`expr $slpTime - 5`
    done
    log "sleep ${1}s done"
    return 1
}

reConnWifi(){
    radio2_restart
}

main(){
    while [ 1 ]
        do
        checkPing
        if [ $? -eq 0 ]
            then
            sleep $SLP
        else
            log "ReConnect"
            login
            if [ $? -eq 1 ]
                then
                log "No paras, skip."
                continue
            fi

            checkPing
            if [ $? -eq 0 ]
                then
                log "Connected !"
            else
                log "DynReconn: 40s left"
                dynSlp 40
                if [ $? -eq 1 ]
                    then
                    log "REBOOT NOW!"
                    reConnWifi
                else
                    log "Connected !"
                fi
            fi
        fi
    done
}

log "START, check freq: ${SLP}s."
main