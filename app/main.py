from fastapi import FastAPI
import uvicorn
import pkuseg

app = FastAPI()


@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.get("/api/test")
async def test():
    return {"message": "testing: service is healthy"}


@app.get("/api/{text}")
async def say_hello(text: str):
    seg = pkuseg.pkuseg()
    words = seg.cut(text)
    return {"message": f"{words}"}


if __name__ == '__main__':
    uvicorn.run(app='main:app', host="0.0.0.0", port=8080, reload=True, debug=True)
