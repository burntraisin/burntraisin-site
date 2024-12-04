+++
title = "Generating AO3 RSS Feeds for Work Chapters"
date = "2024-07-06"
tags = [
    "linux",
]
+++

I wrote a script to populate Atom files for my RSS feed, [elfeed](https://github.com/skeeto/elfeed). Specifically, I wanted to know when a new chapter was uploaded for an [AO3](https://archiveofourown.org/) Work.

AO3 doesn't offer RSS for chapter updates, so I used [RSS Bridge](https://rss-bridge.org/) ([GitHub](https://github.com/RSS-Bridge/rss-bridge)) to generate the Atom files. The only caveat is that the file only contains the feed up until the time you've generated it. This means that simply having the Atom file on your disk is not enough; if you want tomorrow's updates, you would have to generate a new file on the site tomorrow. At least this was my case with Elfeed. Since I had a number of Works I was reading, manually generating an Atom file every time I wanted to see if there was an update would be tedious. I figured writing a script to automate this process would save me a lot of time. I'm far from fluent on Bash scripting, so I learned a lot throughout this process, particularly about [Expect](https://wiki.tcl-lang.org/page/Expect) and [cron](https://en.wikipedia.org/wiki/Cron).

This was written on Ubuntu 22.04.4 LTS, so this should work on Linux or on other Debian-based distros. Be sure that Expect (v5.45.4) and [Lynx](https://lynx.invisible-island.net/) (v2.9.0dev.10) are also installed on your system too.

## Wait, What is RSS?

RSS stands for Really Simple Syndication. It lets you receive notifications or updates from websites when a new item is posted, such as a blog post. It allows me to keep track of many websites in one feed aggregator. In my case, that's Elfeed. It removes the need to manually open every app or check every website to see if there was an update. Even though I might receive email or app notifications, they're not as user-friendly as a feed aggregator, which can mark if an update has been read or not. It's like being in a security control room rather than being on patrol.

To me, I find it strange that a couple of major sites, such as Twitter and Instagram, have no support for RSS feeds. Perhaps it's because RSS gives you more control over their algorithms. Oh, and my feed is actually chronological!

## The Gameplan

To maintain the list of Works I was reading, I created several files in the same directory (folder), which are listed below. Also, the file paths are all relative to my home directory because I wanted `cron` automate this process once a day.

### 1. `fics.txt`
- This stores the list of Works in a comma-delimited format, where the first value is a Work ID and the second value is the filename I wanted the Atom file to be saved as.
``` txt
00000000,title-of-work.atom
11111111,another-title.atom
```

### 2. `generate-lists.sh`
- This outputs two text files: one called `work-ids.txt` and another called `filenames.txt`. The script takes the contents of `fics.txt` and separates the Work ID and the filenames into their own text files, which are then moved into a specified directory.
``` bash
#!/usr/bin/bash
	
input_file="/home/burntraisin/ao3-scripts/fics.txt"
	
declare -a input_array
declare -a work_ids
declare -a filenames

mapfile -t input_array < $input_file

for line in ${input_array[@]}; do
	mapfile -t -d ',' input_array <<< $line
	id="${input_array[0]}"
	work_ids+=($id)
	filename="${input_array[1]}"
	filenames+=($filename)
done

printf "%s\n" "${work_ids[@]}" > work-ids.txt
cat work-ids.txt
echo `mv work-ids.txt /home/burntraisin/ao3-scripts/`

printf "%s\n" "${filenames[@]}" > filenames.txt
cat filenames.txt
echo `mv filenames.txt /home/burntraisin/ao3-scripts/`
```

### 3. `move-atom-files.sh`
- This is the simplest script of the bunch. It moves the downloaded Atom files to the directory I want it saved to. In this case, my RSS directory.
``` bash
#!/usr/bin/bash
   
echo `mv *.atom ~/rss/`
```

### 4. `generate-rss.sh`
- This is the juicy part! This script calls `generate-lists.sh` to create the two text files mentioned before: `work-ids.txt` and `filenames.txt`. Then, the script takes the two text files and turns them into their own lists to be used in the script.
- [Lynx](https://lynx.invisible-island.net/), a terminal web browser, is used to access RSS Bridge. For every Work ID, its Atom file is saved with its corresponding filename that was defined in `fics.txt`.
- After the files are saved, `move-atom-files.sh` is called to move the Atom files to my RSS directory.
- Unlike the other two scripts, this script uses Expect to interact with Lynx.
``` bash
#!/usr/bin/expect
	
# Generate lists
spawn /home/burntraisin/ao3-scripts/generate-lists.sh
sleep 10

# Get list of work IDs
set file [open "/home/burntraisin/ao3-scripts/work-ids.txt"]
set work_ids [split [read $file] "\n"]
close $file

# Get list of filenames
set file [open "/home/burntraisin/ao3-scripts/filenames.txt"]
set filenames [split [read $file] "\n"]
close $file
	
set url "https://rss-bridge.org/bridge01/"
spawn lynx $url
	
for { set i 0 } { $i < [expr {[llength $work_ids] - 1}] } { incr i } {
	expect "(NORMAL LINK)"
	send -- "/"
	expect "Enter a whereis"
	send -- "id _\n"
	expect "(Textfield"
	
	# Clear the input field
	send -- "\025"
	expect "(Textfield"
	
	# Enter work ID
	send -- "[lindex $work_ids $i]\n"
	expect "(Form submit button)"
	
	# Right arrow
	send -- "\033\[C"
	sleep 2
	
	# Locate atom download file, initiate download
	expect "(NORMAL LINK)"
	send -- "\033\[C"
	expect "application/atom+xml"
	send -- "D"
	expect "Commands:"
	# Down arrow
	send -- "\033\[B"
	expect "Commands:"
	
	# Save atom file to disk
	send -- "\033\[C"
	expect "Enter a"
	
	# Delete default filename
	# C-u clears between the cursor and the start of the line
	send -- "\025"
	sleep 2
	expect "Enter a"
	
	# Enter custom filename
	send -- "[lindex $filenames $i]\n"
	expect {
		"File exists" {
			send -- "y"
			expect "Commands:"
		}
		"Commands:"
	}
	sleep 1

	# Go back to RSS Bridge homepage
	send -- "g"
	expect "URL to"
	send -- "$url\n"
}

# Quit Lynx
send -- "q\n"
expect ""
sleep 3
	
# Run script to move saved atom files
spawn /home/burntraisin/ao3-scripts/move-atom-files.sh
sleep 5
```
	
## The Script in Action

1. Type the Work IDs for the Works you want to get updates on and a corresponding filename you'd like for the Atom file to be saved as in `fics.txt`.
2. Execute the `generate-rss.sh` script.

When removing a Work ID and filename from the list, you would have to manually delete its entry in `fics.txt` and its Atom file. I haven't written a script to delete Atom files that aren't on the `fics.txt` list, but perhaps one day I'll get around to it if there are that many Works I'm keeping track of.

## Automation: Setting Up `cron`

I could execute `generate-rss.sh` whenever I want before actually fetching updates in Elfeed, but what if I forget? (I probably won't because this took me awhile to write and troubleshoot.) I could schedule the script to run at 3:00 everyday with `cron`. How sweet is that?

Enter `crontab -e` into your terminal to edit your `crontab` file:

``` bash
0 3 * * * bash /home/burntraisin/ao3-scripts/generate-rss.sh
```

I used [crontab guru](https://crontab.guru/) to help me find what cron schedule expression I wanted. Admittedly, I haven't tested this out yet. If any troubles arise, I'll definitely document them and that'll be another blog post! :)
