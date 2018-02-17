### Langstats

A console application that accepts an organization in github and returns
the percentage of each programming language that is used in its public
non forked repositories

## Installation
1. git clone https://github.com/manosprom/langstats.git
2. cd in the project
3. gem build langstats
4. gem install langstats-$GEM_VERSION$.gem

## Instructions

***tests are written using rspec and webmock \
coverage is generated with simplecov \
and documentation with rdoc***

Usage: langstats [options]

|Short | Full                       | Desc |
| :--- | :------------------------: | --------------------------: |
| -v   | --verbose                  |Print info messages          |
| -o   | --organization MANDATORY   | Organization to scan repos  |
| -u   | --username username        | User login                  |
| -p   | --password password        | User password               |
| -h   | --help                     | Display help                |

example:
**langsats -v -o #org#**

*Due to api limit of github which currently is 60 hits per hour
app waits till the limit passes if it encouters a rate_limit error* **use
verbose(-v) messages to see logging**

you can use github credentials for authenticated client to get 5000 hits per hour

example:
**langstats -v -o #org# -u #mail# -p #password#**