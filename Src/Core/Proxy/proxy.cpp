#include <lyra/lyra.hpp>

#include "proxy.hpp"

/*
 * :: Boilder

/*
CLI Overview:

// proxy command(s) - 2 argument group(s)
nullock proxy --start ip:port
nullock proxy --stop

nullock proxy --status
nullock proxy --history

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

// devices command(s) - 2 argument group(s)
nullock devices --connect <device MAC address>
nullock devices --disconnect <device MAC address

nullock devices --list
nullock devices --show <device MAC address>

-----------------------------------------------
*/

void Proxy::parse_args(int argc, char* argv[]) {
    /* for tracking which command the user decided to use... */
    bool proxy_cmd_selected = false;
    bool sitemap_cmd_selected = false;
    bool scope_cmd_selected = false;
    bool intercept_cmd_selected = false;
    bool repeater_cmd_selected = false;
    bool devices_cmd_selected = false;

    /* for storing the value(s) passed to argument(s)... */

    // proxy command
    std::string proxy_start;

    bool proxy_stop;
    bool proxy_status;
    bool proxy_history;

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
    int repeater_add; // entry id
    int repeater_remove; // tab id
    int repeater_replay; // tab id

    bool repeater_show;

    // devices command
    std::string devices_connect;
    std::string devices_disconnect;
    std::string devices_show;

    bool devices_list;

    /* argument groups for commands; note: numbers are used in the varaiable names for easy future maintainability) */

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
        )
        .add_argument(lyra::opt(proxy_history)
            ["-h"]["--history"]
            .help("show the proxy history - shows entry ids and urls for each entry")
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
        .add_argument(lyra::opt(repeater_add, "entry id")
            ["-a"]["--add"]
            .help("add a tab by providing a http entry id (can be found by displaying the proxy history)")
        )
        .add_argument(lyra::opt(repeater_remove, "tab id")
            ["-r"]["--remove"]
            .help("remove a tab by providing the tab name")
        );

    // devices command argument group(s)
    auto devices_arg_group_0 = lyra::group()
        .require(0, 1) // no lower-limit, allow no more than one argument
        .add_argument(lyra::opt(devices_connect, "mac address")
            ["-c"]["--connect"]
            .help("connect a device by providing the device's mac address")
        )
        .add_argument(lyra::opt(devices_disconnect, "mac address")
            ["-d"]["--disconnect"]
            .help("disconnect a device by providing the device's mac address")
        );

    auto devices_arg_group_1 = lyra::group()
        .require(0, 1) // no lower-limit, allow no more than one argument
        .add_argument(lyra::opt(devices_list)
            ["-l"]["--list"]
            .help("list of the external devices connected to the proxy")
        )
        .add_argument(lyra::opt(devices_show, "mac address")
            ["-s"]["--show"]
            .help("show a device and the device's associated information by specifying the device's mac address")
        );

    /* commands */

    // proxy command
    auto proxy_cmd = lyra::command("proxy")
        .require(1, 1)
        | lyra::group([&proxy_cmd_selected](const lyra::group&) { proxy_cmd_selected = true; })
        | proxy_arg_group_0 | proxy_arg_group_1;

    // sitemap command
    auto sitemap_cmd = lyra::command("sitemap")
        .require(1, 1)
        | lyra::group([&sitemap_cmd_selected](const lyra::group&) { sitemap_cmd_selected = true; })
        | sitemap_arg_group_0;

    // scope command
    auto scope_cmd = lyra::command("scope")
        .require(1, 1)
        | lyra::group([&scope_cmd_selected](const lyra::group&) { scope_cmd_selected = true; })
        | scope_arg_group_0 | scope_arg_group_1 | scope_arg_group_2;

    // intercept command
    auto intercept_cmd = lyra::command("intercept")
        .require(1, 1)
        | lyra::group([&intercept_cmd_selected](const lyra::group&) { intercept_cmd_selected = true; })
        | intercept_arg_group_0 | intercept_arg_group_1 | intercept_arg_group_2 | intercept_arg_group_3;

    // repeater command
    auto repeater_cmd = lyra::command("repeater")
        .require(1, 1)
        | lyra::group([&repeater_cmd_selected](const lyra::group&) { repeater_cmd_selected = true; })
        | repeater_arg_group_0 | repeater_arg_group_1;

    // devices command
    auto devices_cmd = lyra::command("devices")
        .require(1, 1)
        | lyra::group([&devices_cmd_selected](const lyra::group&) { devices_cmd_selected = true; })
        | devices_arg_group_0 | devices_arg_group_1;

    /* cli */
    auto subcommands = lyra::group()
        .require(1, 1)
        | proxy_cmd
        | sitemap_cmd
        | scope_cmd
        | intercept_cmd
        | repeater_cmd
        | devices_cmd;

    auto cli = lyra::cli() | subcommands;

    auto result = cli.parse({ argc, argv });

    if (!result) {
        std::cerr << "Error: " << result.message() << std::endl;
        return;
    }

    if (proxy_cmd_selected) {
        // code here...
    }

    if (sitemap_cmd_selected) {
        // code here...
    }

    if (scope_cmd_selected) {
        // code here...
    }

    if (intercept_cmd_selected) {
        // code here...
    }

    if (repeater_cmd_selected) {
        // code here...
    }

    if (devices_cmd_selected) {
        // code here...
    }
}



































