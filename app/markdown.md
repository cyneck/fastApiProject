

[mozilla](https://github.com/mozilla)/**[TTS](https://github.com/mozilla/TTS)**Docker部署



dockerfile

```dockerfile
FROM ubuntu:18.04

MAINTAINER  xxx@qq.com

ENV MYDIR  /opt/app/tts

RUN mkdir -p $MYDIR
WORKDIR $MYDIR

COPY main.py ./main.py

RUN  sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list \
&&  apt-get update -y \
&& apt-get install -y python3-pip python3-dev
RUN pip install --no-cache-dir uvicorn fastapi -i https://pypi.douban.com/simple

EXPOSE 80

CMD [ "python3","main.py" ]
```



```
docker build -t tts:v1 .

docker run -it tts:v1 bash
```

