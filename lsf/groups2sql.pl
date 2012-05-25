#!/usr/bin/perl

use strict;
use DBI;

$| = 1;

my @users;

my $dbhost = 'localhost';
my $dbname = 'lsf2';
my $dbuser = 'root';
my $dbpass = '123456';

my $dbh = DBI->connect("DBI:mysql:$dbname:$dbhost", $dbuser, $dbpass);

while (<>) {
    chomp;

    my @f = split(' ',$_,3);

    my $user_name = $f[0];
    
    my @groups    = split(' ',$f[2]);

    print "User $user_name : " . join(", ",@groups) . "\n";
    
    save_user($dbh,$user_name,@groups);
}

sub get_user {

    my ($dbh,$user_name) = @_;
    
    my $querystr = "select * from user where user_name = '$user_name'";

    
    my $query    = $dbh->prepare($querystr) or die "Can't prepare $querystr: ".$dbh->errstr."\n";
    
    my $rv = $query->execute()              or die "can't execute the query: ".$query->errstr ."\n";
 

    my %user;

    while (my @row= $query->fetchrow_array()) {
	my $internal_id = $row[0];
	my $group_name  = $row[2];

	$user{internal_id}{$internal_id} = 1;
	$user{group_name}{$group_name}   = 1;
	$user{user_name}{$user_name}     = 1;
    }
    
    my $rc = $query->finish;

    return \%user;
}

sub save_user {

    my ($dbh,$user_name,@groups) = @_;
    
    my $dbuser = get_user($dbh,$user_name);

    my $internal_id = "NULL";

    if ($dbuser->{internal_id}) {
	$internal_id = $dbuser->{internal_id}[0];
    }

    # Insert if the group is new
    foreach my $group (@groups) {
	
	if (!$dbuser->{group_name}{$group}) {
	    my $qstr     = "insert into user values($internal_id,'$user_name','$group')";
	    my $query    = $dbh->prepare($qstr)     or die "Can't prepare $qstr: ".$dbh->errstr."\n";
	    my $rv       = $query->execute()        or die "can't execute the query: ".$query->errstr ."\n";
	    my $rc = $query->finish;
	}

    }
    
    # Delete any unwanted groups
    foreach my $group (keys %{$dbuser->{group_name}}) {
	if (!(grep $_ eq $group, @groups)) {
	    my $qstr     = "delete from user where user_name = '$user_name' and group = '$group'";
	    my $query    = $dbh->prepare($qstr)     or die "Can't prepare $qstr: ".$dbh->errstr."\n";
	    my $rv       = $query->execute()        or die "can't execute the query: ".$query->errstr ."\n";
	    my $rc = $query->finish;
	    
	}
    }
    


}

