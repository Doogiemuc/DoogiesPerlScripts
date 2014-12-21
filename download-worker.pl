#!/usr/bin/perl -w
#
# This is a perl wrapper script for <a href="http://rg3.github.io/youtube-dl/">Youtube-dl</a>.
#
# It downloads all youtube urls listed in $url_file
# then extracts the audio trac
# converts to mp3 
# and stores the result in $mp3dir
# and tries to rsync all mp3s in $mp3dir to my mac.  
# (You need to have a ssh-key pair setup for passwordless login!)
#
# URLs of sucessfully downloaded and converted mp3s will then automatically 
# be removed from $url_file, so that they will not downloaded again.
#
# @date   December 2014
# @author Doogie.de
#

my $mp3dir="/home/doogie/youtube_vids";
my $url_file="/home/doogie/youtube-urls.txt";

my $youtubedl="youtube-dl --format bestaudio --add-metadata --restrict-filenames --extract-audio -k --audio-format mp3 ".
              "--ignore-errors --no-progress --no-post-overwrites --batch-file $url_file --output '$mp3dir/%(title)s-%(id)s.%(ext)s'";

print "\n";
print "[worker] ----------------- checking already downloaded tracks\n";
print "\n";

# collect a list of already downloaded youtube IDs
my @mp3s = <$mp3dir/*.mp3>;
my %ids  = ();   # hash of ids

foreach $file (@mp3s) { 
  if ($file =~ /.*-([a-zA-Z0-9_-]{11}).mp3/) {
    print "[worker] existing mp3 file with youtube-id=$1: $file\n";  
    $ids{$1} = 1;
  }
}

# remove these IDs from $url_file
open my $infile,  '<', $url_file or die "Cannot open $url_file: $!";
my @lines = <$infile>;
close $infile;

open my $outfile, '>', $url_file or die "Can't write to $url_file: $!";
my $num = 0;
for (@lines) {
    if ($_ =~ /^https?:\/\/(www\.)?youtube\.(de|com)\/watch\?v=([a-zA-Z0-9_-]{11})/) {
        #print "found valid youtube url with id = $3\n";
        if (exists($ids{$3})) {
            print "[worker] Already downloaded $_\n";
            next;      # do not output line again if mp3 with this id was already downloaded
        }
        $num++;
    }
    print $outfile $_ ;
}
close $outfile;

print "\n";
print "[worker] ----------------- downloading $num new tracks\n";
print "\n";

print "\n";
print "$youtubedl\n";
system($youtubedl);

if ( $? == -1 ) { die "[worker] ERROR: youtube-dl failed: $!\n"; }

# now sync the newly downloaded MP3s back to my mac.  (If it's up.)
print "\n";
print "----------------- syncing MP3s to DoogiesMacBook\n";
print "\n";

my $target_dir="doogie\@DoogiesMacBook.fritz.box:/Volumes/Data1TB/Music2/\\-\\=\\ Trance\\ Trax\\ 2014\\ \\=\\-";
my $rsync_cmd="rsync -v -i --human-readable $mp3dir/*.mp3 '$target_dir'";
print "$rsync_cmd\n";
system($rsync_cmd);

#EOF