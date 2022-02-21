FROM python:3.10.1-alpine3.15

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1


# -- build dependencies
RUN apk add --no-cache postgresql-dev

# -- compile & install python (pip) dependencies
WORKDIR /src
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

COPY . .

CMD ["sh", "entrypoint.sh"]
