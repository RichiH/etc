/* Random config options */
url_completion_use_history = true;
url_remoting_fn = load_url_in_new_buffer;
xkcd_add_title = true;

webjumps['goog'] = webjumps['gg'] = webjumps['google'];
require('page-modes/google-search-results.js');
google_search_bind_number_shortcuts();

// specify download directory
cwd = get_home_directory();
cwd.append("Desktop");
