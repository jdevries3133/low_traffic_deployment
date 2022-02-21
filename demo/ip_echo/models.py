from django.db import models


class Example(models.Model):

    created = models.DateTimeField(auto_now_add=True)
    ip = models.CharField(max_length=20)
