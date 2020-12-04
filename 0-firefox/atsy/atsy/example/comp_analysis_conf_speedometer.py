from os import path, getcwd

WRAPPER_PATH = path.abspath(path.join(getcwd(), 'firefox-test-wrapper'))

# This file provides a configuration for running the atsy tests.
#
# Format:
# SETUP = {
#     '<os_name>': {
#         '<browser_name>': {
#             'binary': Path to the browser executable,
#             'parent_filter': lambda function used to differentiate the
#                              parent process from the content processes
#
#                              The full command line is passed to it,
#             'path_filter': lambda function used to determine if the given
#                            process path is related to the browser.
#         },
#     },
# }
#
# TEST_SITES = [
#     <list of URLs to run through>
# ]

SETUP = {
    'linux': {
        'Firefox': {
            'binary': WRAPPER_PATH,
            'parent_filter': lambda x: 'firefox -content' not in x,
            'path_filter': lambda x: x.startswith('/opt/firefox-') and 'mstat' not in x,
        },
    },
}

# Example test sites.
TEST_SITES = [
  "http://localhost:1337/?unit=ms&iterationCount=10",
]
