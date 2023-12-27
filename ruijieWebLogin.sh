#!/bin/sh

if [ "$#" -lt "2" ]; then
  echo "Usage: ./ruijie_general.sh username password"
  echo "Example: ./ruijie_general.sh 201620000000 123456"
  exit 1
fi

doLogin() {
  loginPageURL=`curl -s "http://www.google.cn/generate_204" | awk -F \' '{print $2}'`
  loginURL=`echo $loginPageURL | awk -F \? '{print $1}'`
  loginURL="${loginURL/index.jsp/InterFace.do?method=login}"
  queryString=`echo $loginPageURL | awk -F \? '{print $2}'`
  queryString="${queryString//&/%2526}"
  queryString="${queryString//=/%253D}"

  if [ -n "$loginURL" ]; then
    authResult=`curl -s -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.91 Safari/537.36" -e "$loginPageURL" -b "EPORTAL_COOKIE_USERNAME=; EPORTAL_COOKIE_PASSWORD=; EPORTAL_COOKIE_SERVER=; EPORTAL_COOKIE_SERVER_NAME=; EPORTAL_AUTO_LAND=; EPORTAL_USER_GROUP=%E5%AD%A6%E7%94%9F%E5%8C%85%E6%9C%88; EPORTAL_COOKIE_OPERATORPWD=;" -d "userId=$1&password=$2&service=&queryString=$queryString&operatorPwd=&operatorUserId=&validcode=&passwordEncrypt=false" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" "$loginURL"`
    echo $authResult
  fi
}

while true; do
  captiveReturnCode=`curl -s -I -m 10 -o /dev/null -s -w %{http_code} http://www.google.cn/generate_204`
  if [ "$captiveReturnCode" = "204" ]; then
    echo "You are already online. Checking again in 30 seconds..."
    sleep 30
  else
    echo "Network is down. Attempting to reauthenticate..."
    doLogin $1 $2
  fi
done
