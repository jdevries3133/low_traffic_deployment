from django.shortcuts import render

from ipware import get_client_ip

from .models import Example

def index(request):
    ip, _ = get_client_ip(request)
    obj, created = Example.objects.get_or_create(ip=ip)  # type: ignore

    return render(request, 'index.html', context={'obj': obj, 'is_new': created })

