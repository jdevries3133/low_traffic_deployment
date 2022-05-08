from typing import cast
from django.shortcuts import render

from ipware import get_client_ip

from .models import Example

def index(request):
    ip = cast(str, get_client_ip(request)[0])

    context = {
        'all_visits': Example.objects.all(),
        'self_visits': Example.objects.filter(ip=ip)
    }

    Example.objects.create(ip=ip)

    return render(request, 'index.html', context=context)
