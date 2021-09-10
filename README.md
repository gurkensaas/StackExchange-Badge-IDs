<h1>Table of all Stack Exchange Badge IDs</h1>

You have probably come from the [wiki post about this](https://meta.stackexchange.com/questions/369665/is-there-a-table-of-badge-ids-for-all-stack-exchange-sites/). In this README
you'll learn... 

* ...how to use the tables.
* ...how you can help me.
* ...some of my personal thoughts.

<h2>Tables</h2>

Tables follow the following conventions:

* Column headers are in the URL format and specify the network they come from.
* First item of rows are the badge names in all lowercase.
* IDs that don't exist on certain networks are 0s.

In the `tables` folder of this repository, you can find the same table in the following formats:

* CSV table. This is what the script generates.
* XLSX table. This is for comfort reading since the column width is quite large.
* NUMBERS table. This is also for comfort reading.
* DB database. In the database, there is a table called `badges`. You can execute SQL like `SELECT * FROM "badges" WHERE "badge" == "altruist"`. This will return all the IDs of the badge `altruist`.

<h2>Contributing</h2>

For this repository, there are two types of contributing:

<h3>Code</h3>

This is for contributing the code I provided rewritten in another language, since AppleScript has a relatively low compatibility. I tried my best to document the code to make it easy for other people to write it in another language. Some requirements are:

* A decent documentation.
* A decent compatibility, both with Operating Systems and Browsers.
* With a decent internet connection, it has to run in less than 10 minutes.
* Output has to be comma-delimited/CSV.

<h3>Tables</h3>

This is in case...

* ...a new badge gets added.
* ...a new site gets added to the [sites section to stackexchange](https://stackexchange.com/sites)
* ...the badge system changes.
* ...you find an error in an existing table.

You can run one of the scripts in the `scripts` directory. Converting to other formats sadly has to be done manually.

<h2>Personal Thoughts</h2>

This project took comparatively long for what it really is. I got sick halfway through and then had a few nasty bugs which were really simple. I am happy to finally share this with the world, since I want to use it [myself](https://meta.stackexchange.com/questions/369097/is-there-any-real-order-for-badges-on-different-stack-exchange-sites). This apparently also bugs [other users](https://meta.stackexchange.com/questions/254605/can-we-have-a-working-route-if-we-use-the-id-from-the-badges-table). I knew I could do it and I did it. If you're asking why I took the HTML-fetching approach instead of something classy like the Stack Exchange API, it's because I don't really know how that works and it's language independent so even something like Stack Overflow en español couldn't stop me.