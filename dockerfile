FROM python:3.8.14-buster
MAINTAINER  cyneck@qq.com

ENV MYDIR  /opt/app/

RUN mkdir -p $MYDIR

RUN sed -i 's#http://deb.debian.org#https://mirrors.cloud.tencent.com#g' /etc/apt/sources.list
# RUN sed -i 's#http://archive.ubuntu.com#https://mirrors.cloud.tencent.com#g' /etc/apt/sources.list
RUN apt update && apt install vim net-tools -y
RUN pip3 install --no-cache-dir uvicorn fastapi -i https://pypi.douban.com/simple

WORKDIR $MYDIR
COPY main.py $MYDIR

EXPOSE  8000

CMD ["python3","main.py"]
# CMD ["sleep","3600"]