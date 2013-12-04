Prototype Web Site for the Red Programming Language
====

The contained files constitute most of the working files required to operate the site. Missing is the [Rebol](http://rebol.com/downloads.html) executable (requires Rebol/Core 2.7.8), a web server (Apache or [Cheyenne](http://cheyenne-server.org/) are both known to work) and [MySQL](http://www.mysql.com/).

Included is the [QuarterMaster](https://github.com/rgchris/QuarterMaster) web framework on top of which this site is built.

Configuration
----

First, web servers should be configured so that the `/html` folder is the web root and `/cgi-bin` is the CGI root. The `/cgi-bin` folder contains a sample CGI script `red.txt`. Clone this file as `red.r`, enable `+x` file permissions (unless on Windows), delete the preamble (all lines before the Shebang) and alter referenced locations and settings, including the path to the Rebol executable on the Shebang line. Missing files (404s) should be soft-redirected to the CGI script.

The `app/schemas` folder contains SQL code necessary to create a new database with the correct schema. NOTE: this will overwrite any database of the same name. The database must be in place before the app will work correctly.

Permissions for the `/space` folder should allow write access to the web user or group.

Structure
----

**/html** contains static web content.

**/cgi-bin** contains CGI scripts.

**/qm** contains QuarterMaster and standard support files.

**/app** contains the QuarterMaster application.

**/app/controllers** contains Controllers—used to arbitrate web requests.

**/app/models** contains Models—used to model application data.

**/app/views** contains templates.

**/app/events** contains code performed for every request.

**/app/makedoc** contains configuration files for the MakeDoc text processor.

**/app/support** contains support modules specific to this application.

**/app/schemas** contains the specification for the database schema corresponding to this application.

**/space** file space for storing miscellaneous data.

Conventions
----

Rebol code should where applicable conform to the [Rebol Style Guide](http://www.rebol.com/docs/core23/rebolcore-5.html#section-5). CSS code should be grouped within weighted comments: `/** Headers */ ... /* End Headers **/`. HTML should follow conventions used by [Bootstrap](http://getbootstrap.com/css/).

Do not replace the content of [red.css](https://github.com/rgchris/Red-Lang.org/blob/master/html/assets/red.css) unless you are correcting errors, adding missing features. Departures from the included style should be contained within a new CSS file.
