# Linux Commands

The goal of this document is to list random linux commands that may help debug and/or trouble shoot errors.

Purpose | Command | Description
------ | ------ | ------
Find large files | `du -a / | sort -n -r | head -n 20` | Finds largest 20 files/directories
Firewall open ports | `firewall-cmd --list-all` | Uses `firewalld`
