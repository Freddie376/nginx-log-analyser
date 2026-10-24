# Nginx Log Analyser

A simple shell script that reads an nginx access log and shows the top 5 IP addresses, most requested paths, response status codes and user agents. It uses only standard Linux commands (`awk`, `sort`, `uniq`, `head`, `wc`).

Project from roadmap.sh: https://roadmap.sh/projects/nginx-log-analyser

## What it shows

1. Top 5 IP addresses with the most requests
2. Top 5 most requested paths
3. Top 5 response status codes
4. Top 5 user agents

It also prints the log file name and the total number of requests.

## Requirements

- A Linux system with Bash
- Standard tools that come with Linux: `awk`, `sort`, `uniq`, `head`, `wc`

## How to run

1. Clone the repository:
   ```bash
   git clone https://github.com/Freddie376/nginx-log-analyser.git
   cd nginx-log-analyser
   ```
2. Make the script executable:
   ```bash
   chmod +x log-analyser.sh
   ```
3. Run it with the path to a log file:
   ```bash
   ./log-analyser.sh nginx-access.log
   ```

### About the log file

The project page gives a link to a sample nginx access log. Download it and save it in this folder as `nginx-access.log`.

This repository also includes a small generated `nginx-access.log` (1,000 lines in the same format) so you can test the script right away. Replace it with the official sample when you have it.

## Usage

```bash
./log-analyser.sh <log-file>
```

## Example output

```
Log file      : nginx-access.log
Total requests: 1000

Top 5 IP addresses with the most requests:
45.76.135.253 - 255 requests
142.93.143.8 - 214 requests
178.128.94.113 - 170 requests
43.224.43.187 - 104 requests
92.118.160.61 - 78 requests

Top 5 most requested paths:
/ - 201 requests
/api/users - 103 requests
/index.html - 99 requests
/api/products - 96 requests
/static/app.js - 86 requests

Top 5 response status codes:
200 - 694 requests
304 - 99 requests
404 - 78 requests
301 - 72 requests
500 - 29 requests

Top 5 user agents:
curl/8.5.0 - 83 requests
python-requests/2.31.0 - 61 requests
...
```

The numbers depend on the log file you use.

## How it works

Each line of an nginx access log looks like this:

```
45.76.135.253 - - [10/Oct/2026:06:00:15 +0000] "GET /index.html HTTP/1.1" 200 48445 "-" "curl/8.5.0"
```

`awk` splits every line into fields at the spaces. These are the fields the script uses:

| Field | Meaning | Example |
|-------|---------|---------|
| `$1` | IP address | `45.76.135.253` |
| `$7` | Requested path | `/index.html` |
| `$9` | Response status code | `200` |
| 6th piece when split on `"` | User agent | `curl/8.5.0` |

For each of the four reports the script runs the same pipeline:

```bash
awk '{print $1}' nginx-access.log | sort | uniq -c | sort -nr | head -n 5
```

| Command | What it does |
|---------|--------------|
| `awk '{print $1}'` | Picks out one field from every line |
| `sort` | Puts identical values next to each other (needed for `uniq`) |
| `uniq -c` | Counts how many times each value appears |
| `sort -nr` | Sorts by that count, biggest first |
| `head -n 5` | Keeps only the top 5 |

The pipeline is written once in a function, `show_top5`, and used four times.

## Error handling

The script stops with a clear message when:
- No log file is given
- The file does not exist
- The file cannot be read (try `sudo`)
- The file is empty

## Project structure

```
nginx-log-analyser/
├── log-analyser.sh     # the script
├── nginx-access.log    # sample log file
└── README.md
```

## What I learned

This project has helped me learn how to generate an nginx script that runs information about a user's website. Running this log-analyser helps the user to know who has visited their website, the popular paths on the website, devices being used in the network, ensuring security and troubleshooting any failures in the system.
