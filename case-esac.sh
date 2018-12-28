vim case-esac.sh

#! /bin/bash
echo "1.uptime"
echo "2.w"
echo "3.ps"
echo "4.df"
echo "5.free"
echo "6.exit"
read -p "ENTER YOUR CHOICE:" var1
case $var1 in 
1) uptime ;;
2) w ;;
3) ps -e -o uid,pid,ppid,%mem,%cpu,cmd --sort=-%mem | head -n 5 ;;
4) df -Th ;;
5) free -h ;;
6) exit
esac

:wq
chmod +x case-esac.sh
./case-esac.sh

