from fastapi import FastAPI
import uvicorn

import subprocess

print(subprocess.call(["ls", "-l"], shell=False)) # shell参数为false，则，命令以及参数以列表的形式给出

app = FastAPI()


@app.post("/api")
async def api():
    return {"message": "test api"}


@app.get("/test")
async def root():
    return {"message": "Hello World"}


@app.get("/hello/{name}")
async def say_hello(name: str):
    return {"message": f"Hello {name}"}


if __name__ == '__main__':
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True, debug=True)
