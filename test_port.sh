#!/bin/bash
# filename: ts_xml.sh
# create_wangxb_20150126
#

#PATH=/u01/app/oracle/product/10.2.0/db_1/bin:/usr/kerberos/bin:/usr/local/bin:/bin:/usr/bin:/opt/dell/srvadmin/bin:/home/p3s_batch/tools:/home/p3s_batch/bin
#export PATH
# Database account information file
#source ~/.p3src

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# set some variable 
# XMLSCRIPT: 脚本的绝对路径
# MATCHING_RESULT_XML: xml_1的文件名 
# XML_FUNC_FILE: 生成xml函数文件路径
# MATCHING_RESULT_QUERY_DATA: sqlplus 查出数据保存的零时文件
# MATCHING_RESULT_QUERY_SQL: sqlplus 查询的sql语句
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 下面是一些基础的设置
#export XMLSCRIPT=/usr/p3s/batch/jaaa_match/tmp_xa_wangxb
XML_DIR="xmldata"
XML_FUNC_FILE="xml_func.sh"

MATCHING_RESULT_XML="matching_result_"$(date '+%Y%m%d_%H%M%S')".xml"
MATCHING_RESULT_QUERY_DATA="matching_result_query_data.tmp"
MATCHING_RESULT_QUERY_SQL="matching_result_query.sql"

CLIENT_LIST_XML="client_list_"$(date '+%Y%m%d_%H%M%S')".xml"
CLIENT_LIST_QUERY_DATA="client_list_query_data.tmp"
CLIENT_LIST_QUERY_SQL="client_list_query.sql"

# add_wangxb_20150225
if [ ! -d "$XML_DIR" ];
then
    mkdir $XML_DIR
fi

#+++++++++++++++++++++++++++
# modify_wangxb_20150224
# check for temporary file 
#+++++++++++++++++++++++++++
if [ -e "$XML_DIR/$MATCHING_RESULT_XML" ];
then
    rm -f $XML_DIR/$MATCHING_RESULT_XML
fi

if [ -e "$XMLSCRIPT/$MATCHING_RESULT_QUERY_DATA" ];
then
    MATCHING_RESULT_QUERY_DATA="matching_result_query_data_"$(date '+%Y%m%d%H%M%S')".tmp"
fi
#+++++++++++++++++++++++++++++++++++++++++++++++++
# add_wangxb_20150225
# check system time,  choice query time period
# 这是是根据crontab每天执行的时间，取得我们查询数据库时的where条件的时间区间
#+++++++++++++++++++++++++++++++++++++++++++++++++
sys_datetime=$(date '+%Y%m%d%H')
first_chk_datetime="$(date '+%Y%m%d')04"
second_chk_datetime="$(date '+%Y%m%d')12"
third_chk_datetime="$(date '+%Y%m%d')20"
# 由于服务器crontab是上面的时间，但是执行的shell比较多，在调用我这个shell的时候，不一定就是04:30 ，12:30, 20:30所以，这里的根据系统的时间判断时 范围给的比较宽
case $sys_datetime in
    "$first_chk_datetime"|"$(date '+%Y%m%d')05"|"$(date '+%Y%m%d')06"|"$(date '+%Y%m%d')07")
        chk_start=$(date '+%Y-%m-%d 21:00:00' -d '-1 day')
        chk_end=$(date '+%Y-%m-%d 04:29:59')
    ;;
    "$second_chk_datetime"|"$(date '+%Y%m%d')13"|"$(date '+%Y%m%d')14"|"$(date '+%Y%m%d')15")
        chk_start=$(date '+%Y-%m-%d 04:30:00')
        chk_end=$(date '+%Y-%m-%d 12:29:59')

    ;;
    "$third_chk_datetime"|"$(date '+%Y%m%d')21"|"$(date '+%Y%m%d')22"|"$(date '+%Y%m%d')23")
        chk_start=$(date '+%Y-%m-%d 12:30:00')
        chk_end=$(date '+%Y-%m-%d 20:59:59')

    ;;
    *)
        chk_start=$(date '+%Y-%m-%d 00:00:00')
        chk_end=$(date '+%Y-%m-%d 23:59:59')

    ;;
esac

# modify_wangxb_20150310
# 下面的是做一个oracle数据库连接的测试，如果连接失败，后续代码不再执行，并且写入错误日志
$ORACLE_HOME/bin/sqlplus -s $ORAUSER_WEB_PASDB << EOF
set echo off
set feedback off
alter session set nls_date_format='YYYY-MM-DD:HH24:MI:SS';
select sysdate from dual;
quit
EOF
if [ $? -ne 0 ]
then 
    echo "********** DBへのリンク己窃した **********"
    exit
else
    echo "********** DBへのリンクＯＫです **********"
fi
# sqlplus就是oracle的一个客户端软件，具体使用方法可以问度娘，这里传入要执行的sql和参数，将结果 > 输出到指定文件
$ORACLE_HOME/bin/sqlplus -s $ORAUSER_WEB_PASDB @$XMLSCRIPT/$MATCHING_RESULT_QUERY_SQL "$chk_start" "$chk_end" > $XMLSCRIPT/$MATCHING_RESULT_QUERY_DATA


# create matching result's xml file
# add_wangxb_20150227
# 下面的算法就是将查出的数据进行分析，调用xml函数生成xml文件
source "$XMLSCRIPT/$XML_FUNC_FILE" "$XML_DIR/$MATCHING_RESULT_XML"
put_head 'xml version="1.0" encoding="utf-8"'
tag_start 'ROOT'
if [ -s "$XMLSCRIPT/$MATCHING_RESULT_QUERY_DATA" ];
then
    datas=${XMLSCRIPT}/${MATCHING_RESULT_QUERY_DATA}
    #for res in $datas
    while read res;
    do
        stock_id=$(echo $res | awk 'BEGIN {FS="\\^\\*\\^"} {print $1}')
        seirino=$(echo $res | awk 'BEGIN {FS="\\^\\*\\^"} {print $2}')
        match_flg=$(echo $res | awk 'BEGIN {FS="\\^\\*\\^"} {print $3}')
        unmatch_riyuu=$(echo $res | awk 'BEGIN {FS="\\^\\*\\^"} {print $4}')
        up_date_tmp=$(echo $res | awk 'BEGIN {FS="\\^\\*\\^"} {print $5}')
        up_date=$(echo $up_date_tmp | awk 'BEGIN {FS="@"} {print $1 " " $2}')
        tag_start 'MATCHING'
        tag 0 'STOCKID' ${stock_id:-""}
        tag 0 'SEIRINO' ${seirino:-""}
        tag 0 'RESULT' ${match_flg:-""}
        tag 1 'REASON' ${unmatch_riyuu:-""}
        tag 0 'UPDATE_DATE' ${up_date:-""}
        tag_end 'MATCHING'
    done < $datas
fi
tag_end 'ROOT'
rm $XMLSCRIPT/$MATCHING_RESULT_QUERY_DATA


# create client list's xml file
# add_wangxb_2015027
# 下面的是再生成一个xml文件，和上面一样
if [ -e "$XML_DIR/$CLIENT_LIST_XML" ];
then
    rm -f $XML_DIR/$CLIENT_LIST_XML
fi

if [ -e "$XMLSCRIPT/$CLIENT_LIST_QUERY_DATA" ];
then
    CLIENT_LIST_QUERY_DATA="client_list_query_data_"$(date '+%Y%m%d%H%M%S')".tmp"
fi


$ORACLE_HOME/bin/sqlplus -s $ORAUSER_MND @$XMLSCRIPT/$CLIENT_LIST_QUERY_SQL > $XMLSCRIPT/$CLIENT_LIST_QUERY_DATA

source "$XMLSCRIPT/$XML_FUNC_FILE" "$XML_DIR/$CLIENT_LIST_XML"
put_head 'xml version="1.0" encoding="utf-8"'
tag_start 'ROOT'
if [ -s "$XMLSCRIPT/$CLIENT_LIST_QUERY_DATA" ];
then
    datas=${XMLSCRIPT}/${CLIENT_LIST_QUERY_DATA}
    #for res in $datas
    while read res;
    do
        corporation_id=$(echo $res | awk 'BEGIN {FS="\\^\\*\\^"} {print $1}')
        corporation_name=$(echo $res | awk 'BEGIN {FS="\\^\\*\\^"} {print $2}')
        client_id=$(echo $res | awk 'BEGIN {FS="\\^\\*\\^"} {print $3}')
        client_print_name=$(echo $res | awk 'BEGIN {FS="\\^\\*\\^"} {print $4}')
        tag_start 'CLIENT'
        tag 0 'CORPORATION_ID' ${corporation_id:-""}
        tag 1 'CORPORATION_NAME' ${corporation_name:-""}
        tag 0 'CLIENT_ID' ${client_id:-""}
        tag 1 'CLIENT_PRINT_NAME' ${client_print_name:-""}
        tag_end 'CLIENT'
    done < $datas
fi
tag_end 'ROOT'
rm $XMLSCRIPT/$CLIENT_LIST_QUERY_DATA


# add_wangxb_20150304
# Convert xml file encoding
# 这是将xml文件进行转码，命令是iconv
if [ -e "$XML_DIR/$MATCHING_RESULT_XML" ];
then
    echo "********** matching_result.xmlファイルコ〖ドを啪垂し、**********"
    iconv -f euc-jp -t utf-8 $XML_DIR/$MATCHING_RESULT_XML  -o $XML_DIR/$MATCHING_RESULT_XML.utf-8
    mv $XML_DIR/$MATCHING_RESULT_XML.utf-8 $XML_DIR/$MATCHING_RESULT_XML
fi
if [ -e "$XML_DIR/$CLIENT_LIST_XML" ];
then
    echo "********** client_list.xmlフィルコ〖ドを啪垂し、**********"
    iconv -f euc-jp -t utf-8 $XML_DIR/$CLIENT_LIST_XML  -o $XML_DIR/$CLIENT_LIST_XML.utf-8
    mv $XML_DIR/$CLIENT_LIST_XML.utf-8 $XML_DIR/$CLIENT_LIST_XML
fi

# add_wangxb_20150304
# Send the xml file to the destination server by ftp
#ftp_host="222.***.***.***"
#USER="***"
#PASS="***"
#ftp -i -n $ftp_host << EOF
#user $USER $PASS
#cd /
#lcd $XML_DIR/
#put $MATCHING_RESULT_XML
#put $CLIENT_LIST_XML
#quit
#EOF

# test ftp
# 通过ftp将xml文件放到客户服务器上，ftp_host：客户服务器地址，user登录名，pass密码
ftp_host="***.***.***.***"
USER="***"
PASS="***"
dir="/upload"
ftp -i -n $ftp_host << EOF
user $USER $PASS
cd /upload/
lcd $XML_DIR/
put $MATCHING_RESULT_XML
put $CLIENT_LIST_XML
quit
EOF


# Save the program log file
YYMM=$(date +'%Y%m%d%H%M')
cp /tmp/create_xml.log /usr/p3s/batch/jaaa_match/tmp_xa_wangxb/logs/create_xml.log.$YYMM

# Send error log files into the Admin mailbox
info_to_mail_1="**@**.co.jp"
info_to_mail_2="***@**.co.jp"
# nkf 日文转码的一个命令
title=$(echo "test" | nkf -j)
nkf -j < /tmp/create_xml.log | mail -s $title $info_to_mail_1 $info_to_mail_2


#exit
