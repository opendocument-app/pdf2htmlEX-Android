include_guard(GLOBAL)

message(FATAL_ERROR "libintl-proxy package is disabled")

ExternalProjectMeson(intl
  URL https://github.com/ViliusSutkus89/proxy-libintl/archive/0.2.tar.gz
  URL_HASH SHA256=9467f672d2e18d61fb14cbfb08d4afcc1f88c0ec372cac79bc19e848e8d66ba7
)

