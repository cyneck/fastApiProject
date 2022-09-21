from fastapi import FastAPI, Body
from typing import Optional
import uvicorn
import pkuseg

app = FastAPI()


@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.get("/api/test")
async def test():
    return {"message": "testing: service is healthy"}


@app.post("/api/text")
async def say_hello(
        text: str = Body(None, title='文本', max_length=1024)
):
    seg = pkuseg.pkuseg()
    words = seg.cut(text)
    return {"message": f"{words}"}


if __name__ == '__main__':
    uvicorn.run(app='main:app', host="0.0.0.0", port=8080, reload=True, debug=True)
