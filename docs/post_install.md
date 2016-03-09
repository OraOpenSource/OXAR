# OXAR Post Install Recommendations

The following is a list of things that we recommend to do following an OXAR installation

- Do the tasks listed in the [Securing System](securing_system.md) page
- Copy the file [`oxar/utils/oracle/adr_purge.sh`](/utils/oracle/adr_purge.sh) to a "permanent" location then schedule it

```bash
sudo -i
crontab -e

# This will schedule it to run every morning at 1am
0 1 * * * /path/to/file/adr_purge.sh
```
