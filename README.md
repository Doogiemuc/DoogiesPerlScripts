DoogiesPerlScripts
==================


 This is a perl wrapper script for <a href="http://rg3.github.io/youtube-dl/">Youtube-dl</a>.

It downloads all youtube urls listed in $url_file
 - then extracts the audio trac
 - converts to mp3 
 - and stores the result in $mp3dir
 - and tries to rsync all mp3s in $mp3dir to my mac. (You need to have a ssh-key pair setup for passwordless login!)

URLs of sucessfully downloaded and converted mp3s will then automatically  be removed from $url_file, so that they will not downloaded again.

@date   December 2014
@author Doogie.de
