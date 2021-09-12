(*
Basic rules: 
IDs are stored in a nested list.
Output is in a CSV-format (Comma separated)
IDs of Tags that don't exist on certain networks are 0
Networks (in the first row of the table) are in the URL format
*)
set AppleScript's text item delimiters to "/" --This allows us to read the links more easily later on.
try --the try statement in Applescript is the same as in Javascript where errors don't halt the script.
	tell application "Google Chrome" to tell front window --The tell statement targets the front window of your browser. Currently, only Chromium-based browsers are supported.
		if URL of active tab does not contain "https://stackexchange.com/sites?view=list" then
			set theTab to make new tab with properties {URL:"https://stackexchange.com/sites?view=list"}
		else
			set theTab to active tab
		end if
		set theTabs to tabs --we store the tabs of the front window here, because in the tell statement we targeted the front window.
		tell theTab --This further specifies the tab where the sites section of stackexchange.com was opened.
			set siteLinks to execute javascript "var links = document.getElementsByClassName('lv-info'); links = [...links].map(el => el.children[0].children[0].getAttribute('href').toString());" as list
			--this returns the URL's to all stackexchange sites.
			repeat until ((count of siteLinks) > 150) --repeat until is the same as while not and count is the same as len(array) or array.length. It sometimes happens that it will only retrieve a few sites.
				delay 0.5
				set siteLinks to execute javascript "var links = document.getElementsByClassName('lv-info'); links = [...links].map(el => el.children[0].children[0].getAttribute('href').toString());" as list
				--here we assign the same thing as above to check if the site has finished loading.
			end repeat
			if (count of theTabs) is not equal to 1 then close --Here is the reason why we assigned the tabs to a variable.
		end tell
	end tell
on error --Here is why we used a try statement at the very top. If you don't have a browser window open, it's going to produce an error.
	tell application "Google Chrome"
		set theWindow to make new window
		set URL of tab 1 of theWindow to "https://stackexchange.com/sites?view=list"
		tell tab 1 of theWindow --This targets the first tab of a new window we just made. In this tab, it is going to get the URL's to all sites like above.
			set siteLinks to execute javascript "var links = document.getElementsByClassName('lv-info'); links = [...links].map(el => el.children[0].children[0].getAttribute('href').toString());" as list
			repeat until ((count of siteLinks) > 150)
				set siteLinks to execute javascript "var links = document.getElementsByClassName('lv-info'); links = [...links].map(el => el.children[0].children[0].getAttribute('href').toString());" as list
				delay 0.5
			end repeat
		end tell
	end tell
end try

set siteLinks to siteLinks & getMetaSites(siteLinks) --This adds the meta sites to the rest of the sites (see function below for more documentation.)

tell application "Google Chrome" to tell its front window
	set theTab to make new tab --Here we assign a variable to a tab that we are going to use for every single site.
	set theBadges to {}
	set theBadgeIDs to {} --Here I declare two empty lists/arrays where the data is going to be stored.
	repeat with siteLink in siteLinks --Applescript repeat with loops are like for loops in other languages. Here it is looping over every stackexchange URL.
		set URL of theTab to siteLink --Here we change the URL of theTab to the badge section of the new network.
		tell theTab
			set theBadgeLinks to (execute javascript "var badges = document.getElementsByClassName('badge m0'); badges = [...badges].map(el => el.getAttribute('href'));") as list
			--Here it is getting all URLs to badges.
			repeat until ((count of theBadgeLinks) > 80) --In this loop it is using the same trick as above to check if the site has finished loading
				delay 0.3
				set theBadgeLinks to (execute javascript "var badges = document.getElementsByClassName('badge m0'); badges = [...badges].map(el => el.getAttribute('href'));") as list
			end repeat
		end tell
		set n to theBadges is not equal to {} and theBadgeIDs is not equal to {} --This is going to be true except for the first run.
		repeat with i from 1 to count of theBadgeLinks --Here it is initiating a more traditional for loop. List indexes in Applescript start at 1.
			try --The reason why this is in a try-block is because of site-exclusive badges, mostly on stackapps.
				if n then --This checks for the variable we assigned above. We can't have it in here or else it will only fail for the first badge on the first sit 
					set end of item (my indexOf(text item 5 of item i of theBadgeLinks, theBadges)) of theBadgeIDs to text item 4 of item i of theBadgeLinks
					(*
					indexOf() finds the index of a certain item in a list/array and is a function on the bottom of this script.
					text items are delimited by the text item delimiters we declared in the first line.
					text item 5 is the name of the badge, spaces are replaced hyphens.
					text item 4 is the id of the badge which is the goal of this entire script.
					*)
				else
					set end of theBadges to text item 5 of theBadgeLink --This populates the list containing all the badge names with the badges on the first network, here Stack Overflow
					set end of theBadgeIDs to {}
					set end of last item of theBadgeIDs to text item 4 of theBadgeLink --This populates list containing all the IDs with nested lists containing the badge-ids of the first network.
				end if
			on error --If indexOf() can't find text item 5, that is because it isn't in the list yet and it is going to throw an error.
				set end of theBadges to text item 5 of item i of theBadgeLinks --Here we insert the new badge into the pool of other badges.
				set end of theBadgeIDs to {} --Here we set the end to a new list. This is all a bit out of order, you will see why in a minute.
				set end of last item of theBadgeIDs to text item 4 of item i of theBadgeLinks --Here we set the end of the new list to the badge ID of the site specific badge.
				repeat until (count of last item of theBadgeIDs) is equal to (count of first item of theBadgeIDs)
					set beginning of last item of theBadgeIDs to 0 --This just fills the rest of the list up to this point with 0.
				end repeat
			end try
		end repeat
		repeat with k from 1 to count of theBadgeIDs
			set standard to count of item 1 of theBadgeIDs
			if (count of item k of theBadgeIDs) < standard then set end of item k of theBadgeIDs to 0 --Here we check if all list are as long as the first list and if not, we populate the end with 0's
		end repeat
	end repeat
end tell

set MasterOutput to "" --We declare an empty string which is going to be output later.
set AppleScript's text item delimiters to "," --Here we change the delimiters so later when the lists get compressed to one single string, they are comma separated.

set j to 1
repeat while j < (count of theBadges) + 1
	if MasterOutput is not equal to "" then --This check only fails the first time so in the else block we can define the header.
		set MasterOutput to (MasterOutput & replaceText("-", " ", item j of theBadges) & "," & item j of theBadgeIDs as string) & return
		(*
		If we return a list as string, it gets compressed to a string and items get seperated by the text item delimiters
		return in a string context is the same as "\n"
		The first item of the row is the badge name, all lower case and thanks to the replaceText() function hyphen-free.
		*)
		set j to j + 1
	else
		set MasterOutput to "badge," & (siteLinks as string) & return --This is for the first time and sets the first row/column headers.
	end if
end repeat

set the clipboard to MasterOutput --This cuts the need to copy the huge amounts of data output by this program.
beep --This notifies you when the program finishes.
return MasterOutput --Just to be safe, this line also displays the MasterOutput in the result tab of Script Editor

on indexOf(theItem, theList)
	repeat with a from 1 to count of theList
		if item a of theList is theItem then return a
	end repeat
end indexOf

on replaceText(find, replace, subject)
	set prevTIDs to text item delimiters of AppleScript
	set text item delimiters of AppleScript to find
	set subject to text items of subject
	set text item delimiters of AppleScript to replace
	set subject to subject as text
	set text item delimiters of AppleScript to prevTIDs
	return subject
end replaceText

on getMetaSites(theLinks)
	set prevTIDs to text item delimiters of AppleScript --This stores the previous text item delimters so we can reset them after the function is called.
	set metaLinks to {} --This is the list that is getting returned in the end.
	set sitesWithoutMeta to {"https://stackapps.com", "https://meta.stackexchange.com"} --These sites don't have a meta site.
	repeat with i from 1 to count of theLinks --Here we iterate over all links that we took as input.
		if sitesWithoutMeta does not contain item i of theLinks then --Here we check if the site has a meta.
			set AppleScript's text item delimiters to "." --This step is essential for splitting sub-domain, domain and top-level domain of the links.
			set theItems to text items of item i of theLinks --Here we split by periods.
			if (count of theItems) is equal to 2 then --Here we check if the site has a sub-domain.
				set AppleScript's text item delimiters to ""
				set end of metaLinks to characters 1 thru 8 of item 1 of theItems & "meta." & characters 9 thru (count of characters of (item 1 of theItems)) of item 1 of theItems & "." & item 2 of theItems as string
				--This mess adds the meta into the URL.
			else if (count of theItems) is equal to 3 then
				set end of metaLinks to item 1 of theItems & ".meta." & items 2 thru 3 of theItems as string --It's quite a lot simpler if the URL has a sub-domain.
			end if
		end if
	end repeat
	set text item delimiters of AppleScript to prevTIDs --Here we reset the text item delimiters.
	return metaLinks
end getMetaSites