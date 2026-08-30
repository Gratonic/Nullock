#pragma once
#include <iostream>
#include <string>

/* main/core classes */
class Proxy {
public:
    std::string parse_args(int argc, char* argv[]);
private:
    // :: command group structs ::
    class App {
    public:
        void open(const std::string file_path);

        void list();

        // note: any file passed to show is expected to contain session names or session paths
        void showName(const std::string session_name);
        void showFile(const std::string file_path);

        // note: any file passed to delete is expected to contain session names or session paths
        void deleteName(const std::string session_name);
        void deleteFile(const std::string file_path);
    private:
    };
};

/* general API classes */
class ProxyApi {
public:
    void start_proxy(const std::string ip, const int port);
    void stop_proxy();

    void proxy_status();
};

class SitemapApi {
public:
    void show();
};

class ScopeApi {
public:
    // note: any file passed to add is expected to contain url's
    void addUrl(const std::string url);
    void addFile(const std::string file_path);

    // note: any file passed to remove is expected to contain url's
    void removeUrl(const std::string url);
    void removeFile(const std::string file_path);

    // note: any file passed to include is expected to contain url's
    void includeUrl(const std::string url);
    void includeFile(const std::string file_path);

    // note: any file passed to exclude is expected to contain url's
    void excludeUrl(const std::string url);
    void excludeFile(const std::string file_path);

    void showInScope();
    void showOutOfScope();
};

class InterceptApi{
public:
    void on();
    void off();
    void foward();
    void drop();

    void show();

    // note: any file passed to find is expected to contain regex patterns to look for
    void findRegex(const std::string regex);
    void findFile(const std::string file_path);

    // note: any file passed to replace is expected to contain regex patterns to look for with replacement text/strings
    void replaceRegex(const std::string regex_replace);
    void replaceFile(const std::string file_path);
};

class RepeaterApi {
public:
    void show();

    // note: any file passed to replace is expected to contain tab IDs
    void replayId(const int id);
    void replayFile(const std::string file_path);
};


/* special API classes */
// note: this api is souly handles the proxy interaction for devices
class DeviceControllerApi {
public:
    void list();

    void showId(const int id);
    void showMac(const std::string mac);
};