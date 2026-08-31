#pragma once
#include <iostream>
#include <string>
#include <cstdint>

/* main/core classes */
class Proxy {
public:
    void parse_args(int argc, char* argv[]);
private:
};

/* general API classes */
class ProxyApi {
public:
    void start(const std::string ip, const std::uint16_t port);
    void stop();

    void status();
    void history();

};

class SitemapApi {
public:
    void show();
};

class ScopeApi {
public:
    void add(const std::string url_data);
    void remove(const std::string url_data);

    void include(const std::string url_data);
    void exclude(const std::string url_data);

    void show(const std::string scope);
};

class InterceptApi{
public:
    void on();
    void off();

    void forward();
    void drop();

    void find(std::string regex_data);
    void replace(std::string regex_replace_data);

    void show();
};

class RepeaterApi {
public:
    void show();

    void replay(std::uint32_t tab_id);

    void add(std::uint32_t entry_id);
    void remove(std::uint32_t tab_id);
};

/* special API classes */
// note: this api is souly handles the proxy interaction for devices
class DeviceControllerApi {
public:
    void list();
    void show(std::string mac_address);

    void connect(std::string mac_address);
    void disconnect(std::string mac_address);
};