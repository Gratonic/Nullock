#pragma once
#include <iostream>
#include <string>

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

class App {
public:
    void open_session(std::string session_file);

    void list_sessions();

    void show_session(std::string session_file);

    void create_session(std::string session_file);
    void delete_session(std::string session_file);
};

class ProxyCore {
public:
    void start_proxy(const std::string ip, const int port);
    void stop_proxy();

    void proxy_status();
};

class Sitemap {
public:
    void show();
};

class Scope {
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

class InterceptTool {
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

class RepeaterTool {
public:
    void show();

    // note: any file passed to replace is expected to contain tab IDs
    void replayId(const int id);
    void replayFile(const std::string file_path);
};

class DevicesTool {
public:
    void list();

    void showId(const int id);
    void showMac(const std::string mac);
};

class NullE {
public:
    // note: any file passed to replace is expected to contain either url's or url's using regex
    void scanUrl(const std::string url);
    void scanRegex(const std::string regex);
    void scanFile(const std::string file_path);

    // note: any file passed to replace is expected to contain either url's or url's using regex
    void showUrl(const std::string url);
    void showRegex(const std::string regex);
    void showFile(const std::string file_path);
};