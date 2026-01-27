from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import path
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

from ox.core.views import core, accounts
from ox import urls as ox_urls

urlpatterns = list(ox_urls.urlpatterns)


if settings.DEBUG:
    urlpatterns += [
        path("admin/", admin.site.urls),
        *static(settings.STATIC_URL, document_root=settings.STATIC_ROOT),
        *static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT),
        path("api/schema/", SpectacularAPIView.as_view(), name="schema"),
        path("api/swagger/", SpectacularSwaggerView.as_view(url_name="schema")),
    ]

handler403 = core.PermissionForbiddenView.as_view()
handler405 = core.InternalErrorView.as_view()
