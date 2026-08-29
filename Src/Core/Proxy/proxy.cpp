#include <lyra/lyra.hpp>

#include "proxy.hpp"

/*
 * :: Boilder

/*
CLI Overview:
// app command(s) - 2 argument group(s)
nullock app --open "session_name" || nullock app --open "session_file.txt"
nullock app --list
nullock app --show "session_file.txt" || nullock app --show <session name>

nullock app --create <session name>
nullock app --delete "session_file.txt" || nullock app --delete <session name>

-----------------------------------------------

// proxy command(s) - 2 argument group(s)
nullock proxy --start ip:port
nullock proxy --stop

nullock proxy --status

-----------------------------------------------

// sitemap command(s) - 1 argument group(s)
nullock sitemap --show

-----------------------------------------------

// scope command(s) - 3 argument group(s)
nullock scope --add "target.com" || nullock scope --add "filename.txt"
nullock scope --remove "target.com" || nullock scope --remove "scope_file.txt"

nullock scope --show "in-scope" || nullock scope --show "out-of-scope"

nullock scope --include "target.com" || nullock scope --include "scope_file.txt"
nullock scope --exclude "target.com" || nullock scope --exclude "scope_file.txt"

-----------------------------------------------

// intercept command(s) - 4 argument group(s)
nullock intercept --on
nullock intercept --off

nullock intercept --foward
nullock intercept --drop

nullock intercept --show

nullock intercept --find "regex" || nullock intercept --find "regex_patterns.txt"
nullock intercept --replace "regex:replace" || nullock intercept --replace "regex_replace_combos.txt"

-----------------------------------------------

// repeater command(s) - 1 argument group(s)
nullock repeater --show

nullock repeater --replay <tab id>

nullock repeater --add <tab name>
nullock repeater --remove <tab name>

-----------------------------------------------

// device console command(s) - 1 argument group(s)
nullock devices --list
nullock devices --show <device MAC address>

-----------------------------------------------

// NullE control command(s) - 1 argument group(s)
nullock nullE --scan "target.com" || nullock nullE --scan "target_file.txt"
nullock nullE --show "target.com/*" || nullock nullE --show "target_file.txt"
nullock nullE --refresh
*/

std::string Proxy::parse_args(int argc, char* argv[]) {
    /* for tracking which command the user decided to use... */
    bool app_cmd_selected = false;
    bool proxy_cmd_selected = false;
    bool sitemap_cmd_selected = false;
    bool scope_cmd_selected = false;
    bool intercept_cmd_selected = false;
    bool repeater_cmd_selected = false;
    bool devices_cmd_selected = false;
    bool nullE_cmd_selected = false;

    /* for storing the value(s) passed to argument(s)... */

    // app command
    std::string app_open;
    std::string app_show;
    std::string app_create;
    std::string app_delete;

    bool app_list;

    // proxy command
    std::string proxy_start;

    bool proxy_stop;
    bool proxy_status;

    // sitemap command
    bool sitemap_show;

    // scope command
    std::string scope_add;
    std::string scope_remove;
    std::string scope_show;
    std::string scope_include;
    std::string scope_exclude;

    // intercept command
    std::string intercept_find;
    std::string intercept_replace;

    bool intercept_on;
    bool intercept_off;
    bool intercept_foward;
    bool intercept_drop;
    bool intercept_show;

    // repeater command
    std::string repeater_add;
    std::string repeater_remove;

    int repeater_replay; // tab id

    bool repeater_show;

    // devices command
    std::string devices_show;

    bool devices_list;

    // nullE command
    std::string nullE_scan;
    std::string nullE_show;

    bool nullE_refresh;

    /* argument groups for commands; note: numbers are used in the varaiable names for easy future maintainability) */

    // app command argument group(s)
    auto app_arg_group_0 = lyra::group()
        .require(0, 1) // no lower-limit, allow no more than one argument
        .add_argument(lyra::opt(app_open, "name or file path")
            ["-o"]["--open"]
            .help("open a known session by providing the session's name or file path")
        )
        .add_argument(lyra::opt(app_list)
            ["-l"]["--list"]
            .help("list all known sessions and their basic information")
        )
        .add_argument(lyra::opt(app_show, "name or file path")
            ["-s"]["--show"]
            .help("show the details of a known session by providing the session's name or file path")
        );

    auto app_arg_group_1 = lyra::group()
        .require(0, 1) // no lower-limit, allow no more than one argument
        .add_argument(lyra::opt(app_create, "name")
            ["-c"]["--create"]
            .help("create a new session by providing a name for the session")
        )
        .add_argument(lyra::opt(app_delete, "name or file path")
            ["-d"]["--delete"]
            .help("delete a known session by providing the session's name or file path")
        );

    // proxy command argument group(s)
    auto proxy_arg_group_0 = lyra::group()
        .require(0, 1) // no lower-limit, allow no more than one argument
        .add_argument(lyra::opt(proxy_start, "ip:port")
            ["-s"]["--start"]
            .help("start the proxy by providing an ip and port to run on in the correct format...ex: 127.0.0.1:8080")
        )
            .add_argument(lyra::opt(proxy_stop)
            ["-S"]["--stop"]
            .help("stop the proxy")
        );

    auto proxy_arg_group_1 = lyra::group()
        .require(0, 1) // no lower-limit, allow no more than one argument
        .add_argument(lyra::opt(proxy_status)
            ["-st"]["--status"]
            .help("show the current status of the proxy and some basic information about it")
        );

    // sitemap command argument group(s)
    auto sitemap_arg_group_0 = lyra::group()
        .require(0, 1) // no lower-limit, allow no more than one argument
        .add_argument(lyra::opt(sitemap_show)
            ["-s"]["--show"]
            .help("show the sitemap")
        );

    // scope command argument group(s)
    auto scope_arg_group_0 = lyra::group()
        .require(0, 1) // no lower-limit, allow no more than one argument
        .add_argument(lyra::opt(scope_add, "url or file path")
            ["-a"]["--add"]
            .help("add a domain or subdomain to the in-scope domains by providing a url or file path...ex: https://target.com/* or foo.bar.org/x/y/z")
        )
        .add_argument(lyra::opt(scope_remove, "url or file path")
            ["-r"]["--remove"]
            .help("remove a domain or subdomain from the in-scope domains by providing a url or file path...ex: https://target.com/* or foo.bar.org/x/y/z")
        );

    auto scope_arg_group_1 = lyra::group()
        .require(0, 1) // no lower-limit, allow no more than one argument
        .add_argument(lyra::opt(scope_include, "url or file path")
            ["-i"]["--include"]
            .help("include a domain or subdomain in the out-of-scope domains by providing a url or file path...ex: https://target.com/* or foo.bar.org/x/y/z")
        )
        .add_argument(lyra::opt(scope_exclude, "url or file path")
            ["-e"]["--exclude"]
            .help("exclude a domain or subdomain from the out-of-scope domains by providing a url or file path...ex: https://target.com/* or foo.bar.org/x/y/z")
        );

    auto scope_arg_group_2 = lyra::group()
        .require(0, 1) // no lower-limit, allow no more than one argument
        .add_argument(lyra::opt(scope_show, "in-scope or out-of-scope")
            ["-s"]["--show"]
            .help("show all of the in-scope or out-of-scope domains by choosing a group...ex: in-scope or out-of-scope")
        );

    // intercept command argument group(s)
    auto intercept_arg_group_0 = lyra::group()
        .require(0, 1) // no lower-limit, allow no more than one argument
        .add_argument(lyra::opt(intercept_on)
            ["-o"]["--on"]
            .help("turn the proxy intercept on to intercept packets")
        )
        .add_argument(lyra::opt(intercept_off)
            ["-O"]["--off"]
            .help("turn the proxy intercept off to stop intercepting packets")
        );

    auto intercept_arg_group_1 = lyra::group()
        .require(0, 1) // no lower-limit, allow no more than one argument
        .add_argument(lyra::opt(intercept_foward)
            ["-f"]["--foward"]
            .help("foward the currently intercepted packet")
        )
        .add_argument(lyra::opt(intercept_drop)
            ["-d"]["--drop"]
            .help("drop the currently intercepted packet")
        );

    auto intercept_arg_group_2 = lyra::group()
        .require(0, 1) // no lower-limit, allow no more than one argument
        .add_argument(lyra::opt(intercept_find, "regex or file path")
            ["-F"]["--find"]
            .help("check to see if the currently intercepted packet has any data that matches a regex pattern or list of regex patterns provided in a file...ex: regex")
        )
        .add_argument(lyra::opt(intercept_replace, "regex with replacement text or file path")
            ["-r"]["--replace"]
            .help("check to see if the currently intercepted packet has any data that matches a regex pattern or list of regex patterns provided in a file and replace any matching data with the provided replacement text...ex: regex:replace")
        );

    auto intercept_arg_group_3 = lyra::group()
        .require(0, 1) // no lower-limit, allow no more than one argument
        .add_argument(lyra::opt(intercept_show)
            ["-s"]["--show"]
            .help("show the currently intercepted request")
        );

    // repeater command argument group(s)
    auto repeater_arg_group_0 = lyra::group()
        .require(0, 1) // no lower-limit, allow no more than one argument
        .add_argument(lyra::opt(repeater_show)
            ["-s"]["--show"]
            .help("show all of the current repeater tabs")
        )
        .add_argument(lyra::opt(repeater_replay, "tab id")
            ["-R"]["--replay"]
            .help("drop the currently intercepted packet")
        );

    auto repeater_arg_group_1 = lyra::group()
        .require(0, 1) // no lower-limit, allow no more than one argument
        .add_argument(lyra::opt(repeater_add, "tab name")
            ["-a"]["--add"]
            .help("add a tab and give the tab a worthy name")
        )
        .add_argument(lyra::opt(repeater_remove, "tab name")
            ["-r"]["--remove"]
            .help("remove a tab by providing the tab name")
        );

    // devices command argument group(s)
    auto devices_arg_group_0 = lyra::group()
        .require(0, 1) // no lower-limit, allow no more than one argument
        .add_argument(lyra::opt(devices_list)
            ["-l"]["--list"]
            .help("list of the external devices connected to the proxy")
        )
        .add_argument(lyra::opt(devices_show, "mac address")
            ["-s"]["--show"]
            .help("show a device and the device's associated information by specifying the device's mac address")
        );

    // nullE command argument group(s)
    auto nullE_arg_group_0 = lyra::group()
        .require(0, 1) // no lower-limit, allow no more than one argument
        .add_argument(lyra::opt(nullE_scan, "url or file path")
            ["-S"]["--scan"]
            .help("scan a target or targets for CWEs/CVEs using the Nullock Evaluator (NullE) by providing a url or file path...ex: target.com/* or https://foo.bar")
        )
        .add_argument(lyra::opt(nullE_show, "url or file path")
            ["-s"]["--show"]
            .help("show any CWEs/CVEs discovered using the Nullock Evaluator (NullE) for a target or targets in the session history by providing a url or file path...ex: target.com/* or https://foo.bar")
        )
        .add_argument(lyra::opt(nullE_refresh)
            ["-r"]["--refresh"]
            .help("refresh the Nullock Evaluator's (NullE) global CWE/CVE database to ensure latest CWEs/CVEs are included")
        );
}





































