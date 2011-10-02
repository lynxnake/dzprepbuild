PrepBuild is a commandline tool for handling the version information
for Delphi projects when compiling using the dcc32.exe commandline
compiler. It can also be used as a Pre-Build tool in Delphi 2007 and up.

It can read and update four different kinds of sources for the
version information:
* <projectname>.dof files (used up to Delphi 7)
* <projectname>.bdsproj files (used in BDS 2005 and 2006)
* <projectname>.dproj files (used in Delphi 2007, 2009 and 2010)
* <projectname>_version.ini files (uses the same format as .dof but has some
                                   extensions)

If you call the programm with the --help or -? option, it will display
usage information.

Use case 1, Delphi 7:

Let's assume you are using Delphi 7, so you probably store the version
in the <projectname>.dof file and let the IDE autoincrement the build
number. Now, for release builds you don't want to use the IDE because
you want to make sure that the process is 100% repeatable without
relying on a particular IDE setup. So instead of the IDE you use the
commandline compiler dcc32.exe which is called from a script called
build.cmd:

-------------

[... other stuff, e.g. checkout the current sourcecode ...]

del <projectname>.cfg
dcc32 [... options ...] <projectname>.dpr

[... other stuff, e.g. create a tag in the SCM ...]

-------------

dcc32, in contrast to the IDE, does not use the .dof file and does not
automatically increment the build number. Instead it reads a .cfg file,
if one exists. The Delphi IDE creates this .cfg file every time it saves,
the project, so it always contains the settings of the IDE, which is
usually not what you want, hence the delete in the example above.

If you are like me you don't check your .res file into the sourcecode
repository because it is binary, so you can't easily check what changed,
and it changes with every build. Instead you rely on the .dof file for
tracking the version information and let the IDE create the .res file
whenever needed.

This has got the drawback that you lose the application's icon because
it is only stored in the .res file. Which is quite annoying. Also, the
commandline compiler does not create the .res file but fails if it does
not exist.

PrepBuild to the rescue. It does any of the following for you:
1. Read the .dof file
2. increment the build number
3. call a batch file that again calls prepbuild to
  3.1 change the .dof file
  3.2 create a .rc file containing the version info
  3.3 add a .ico file to the .rc file so the icon is back
  3.4 call brcc32 to create .res file for the project

Your build script then looks like this:

-------------

[... other stuff, e.g. checkout the current sourcecode ...]

prepbuild --ReadDof=<projectname> --IncBuild --exec=prep.cmd

del <projectname>.cfg
dcc32 [... options ...] <projectname>.dpr

[... other stuff, e.g. create a tag in the SCM ...]

-------------

Which means that it reads the .dof file of your project, increments the
build number and calls another script prep.cmd. This script will get
all the version information as well as the current date and time as
environment variables. It can use these to call PrepBuild once again to

1. update the .dof file
2. write the build date / time e.g. to the comment entry of the
   version information
3. write a .rc file

To do this, you create a prep.cmd script containing this call:

PrepBuild --updatedof=%dzProject%
          --icon=%dzProject%
          --writerc=%dzProject%
          --MajorVer=%dzVersion.MajorVer%
          --MinorVer=%dzVersion.MinorVer%
          --Release=%dzVersion.Release%
          --Build=%dzVersion.Build% 
          --FileDesc="%dzVersion.FileDesc%"
          --InternalName="%dzVersion.InternalName%"
          --OriginalName="%dzVersion.OriginalName%"
          --Product="%dzVersion.Product%"
          --ProductVersion="%dzVersion.ProductVersion%"
          --Company="%dzVersion.Company%"
          --Copyright="%dzVersion.Copyright%"
          --Trademark="%dzVersion.Trademark%"
          --Comments="build on %dzDateTime%"

(all this must go into one line, I just wrapped it to improve readability)

The following environment variables can be used (in addition to the ones
that are usually set):

%dzDate% - the current date in ISO format (yyyy-mm-dd)
%dzTime% - the current time in 24 hour format (hh:mm:ss)
%dzDateTime% - combination of the above (yyyy-mm-dd hh:mm:ss)
%dzMyDocuments% - the My Documents folder of the current user
%dzProject% - the project name passed by the --ReadDof / --ReadBdsProj
              or --ReadIni option without extension

The following values are read from the .dof / .bdsproj / .dproj / .ini file and
also passed as environment variables:

%dzVersion.MajorVer% - the major version number
%dzVersion.MinorVer% - the minor version number
%dzVersion.Release% - the release number
%dzVersion.Build% - the build number (optionally incremented by one)
%dzVersion.FileDesc% - the file description
%dzVersion.InternalName% - the internal name
%dzVersion.OriginalName% - the original filename
%dzVersion.Product% - the product name
%dzVersion.ProductVersion% - the product version
%dzVersion.Company% - the company name
%dzVersion.Copyright% - the copyright string
%dzVersion.Trademark% - the trademark string
%dzVersion.Comments% - the comments string

In the above example these environment variables are used to call
PrepBuild again passing all values as commandline options to update
the project's .dof file and also create a .rc file.

In addition an icon file is also added to the .rc file.

You may ask why I am using a second script instead of doing everything
in PrepBuild itself. The answer is that I didn't want to add too
much functionality to the tool but also wanted the maximum of flexibility.
With this second script, I can use the version info and also the
build timestamp to modify the version information. Others may want to
add the user name to the version info, so they can just use the
standard environment variable %USERNAME% to add it. You might even want
to move creating a tag in your SCM to this script because there you
can use the current version number and build date/time for generating
the tag's name.

Use case 2, Delphi 2007:

Let's assume your company is using Delphi 2007 and there are
multiple Developers working on the same project. You want to make
sure that the build number of a project always increases no matter
which developer does a build. This cannot be done with the options
of the Delphi IDE because it - worse than Delphi 7 - takes the
version information from the .res file (and only from the .dproj file
if no .res file exists). .res files are binary and there is no easy
way to modify them. So, what do you do?

The first thing is disabling the version information in the project
options. Since the IDE doesn't do it correctly, there is no point in
letting it manage the version info. Instead you use a .ini file
to store it. This .ini file goes into your source code repository
together with the code. In addtion you have got another .ini file
in a central location (on the network) that stores the build number.
You refer to this .ini file in the entry of your version .ini file
like this:

[Version Info]
// other stuff
Build=redirect:\\server\share\Testproject_Buildno.ini,Version Info,Build

This will make PrepBuild read and write the build number to the
central .ini file rather than the local one (*1). Make sure that
everybody involved has write permissions on that file.

Now, you add PrepBuild as a prebuild event like this:

prepbuild 

to be continued ....

dzPrepBuild itself uses the same mechanism, but not with a central file
on a server but with a separate file in the repository. This is for two
reasons:
1. It demonstrates how it is done
2. It reduces the changes to one single very small file.


(*1: Of course there is the small chance of two developers doing
a build at the same time. This will result in a duplicate build
number, but this shouldn't happen very often and I was too lazy
to try and implement some kind of locking mechanism to prevent
this rare case. If you need it, you have got the source code....)

