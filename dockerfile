FROM python:3.8-ubuntu
MAINTAINER  xxx@qq.com

ENV MYDIR  /opt/app/

RUN mkdir -p $MYDIR
RUN pip install --no-cache-dir uvicorn fastapi numpy pkuseg -i https://pypi.douban.com/simple

WORKDIR $MYDIR
COPY main.py $MYDIR

EXPOSE  8000

CMD ["python","main.py"]