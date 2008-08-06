package Artemis::Cmd::DbDeploy::Command::init;

use 5.010;

use strict;
use warnings;

use parent 'App::Cmd::Command';

use Artemis::Model 'model';

use Artemis::Schema::ReportsDB;
use Artemis::Schema::TestrunDB;

use Artemis::Cmd::DbDeploy;

use Data::Dumper;

sub opt_spec {
        return (
                [ "verbose", "some more informational output"       ],
                [ "db=s",    "STRING, one of: ReportsDB, TestrunDB" ],
               );
}

sub usage_desc
{
        my $allowed_opts = join ' ', map { '--'.$_ } _allowed_opts();
        "artemis-db-deploy upgrade --db=DBNAME  [ --verbose ]";
}

sub _allowed_opts {
        my @allowed_opts = map { $_->[0] } opt_spec();
}

sub validate_args {
        my ($self, $opt, $args) = @_;

        #         print "opt  = ", Dumper($opt);
        #         print "args = ", Dumper($args);

        my $ok = 1;
        if (not $opt->{db})
        {
                say "Missing argument --db\n";
                $ok = 0;
        }
        elsif (not $opt->{db} =~ /^ReportsDB|TestrunDB$/)
        {
                say "Wrong DB name '".$opt->{db}."' (must be ReportsDB or TestrunDB)";
                $ok = 0;
        }

        return $ok if $ok;
        die $self->usage->text;
}

sub no_live {
        print "We currently don't do live deployment.\n";
        return -1;
}

sub insert_initial_values {
        my ($schema) = @_;

        # ---------- User ----------

        my @users = (
                     [ 'Boris Petkov',            'bpetkov',  '' ],
                     [ 'Conny Seidel',            'cseidel',  '' ],
                     [ 'Frank Arnold',            'farnold',  '' ],
                     [ 'Frank Becker',            'fbecker',  '' ],
                     [ 'Jan Krocker',             'jkrocke2', '' ],
                     [ 'Joerg Roemer',            'jroemer',  '' ],
                     [ 'Maik Hentsche',           'mhentsc3', '' ],
                     [ 'Steffen Schwigon',        'sschwigo', '' ],
                     [ 'Steffen Schwigon@bascha', 'ss5',      '' ],
                    );

        foreach (@users) {
                say STDERR "Add ", join(", ", @$_);
                my $user = $schema->resultset('User')->new
                    ({
                      name     => $_->[0],
                      login    => $_->[1],
                      password => $_->[2],
                     });
                $user->insert;
                #say STDERR "Got ID ", $user->id;
        }
}

sub init_testrundb
{
        my $dsn  = Artemis::Config->subconfig->{database}{TestrunDB}{dsn};
        my $user = Artemis::Config->subconfig->{database}{TestrunDB}{username};
        my $pw   = Artemis::Config->subconfig->{database}{TestrunDB}{password};

        # ----- really? -----
        print "dsn = $dsn\n";
        print "Really delete all existing content and initialize from scratch (y/N)? ";
        read STDIN, my $answer, 1;
        do { print "Quit.\n"; return } unless lc $answer eq 'y';

        # ----- delete sqlite file -----
        if ($dsn =~ /dbi:SQLite:dbname/) {
                my ($tmpfname) = $dsn =~ m,dbi:SQLite:dbname=([\w./]+),i;
                unlink $tmpfname;
        }

        my $schema = Artemis::Schema::TestrunDB->connect ($dsn, $user, $pw);
        $schema->deploy({ add_drop_table => 1 });
        insert_initial_values($schema);
}



sub run
{
        my ($self, $opt, $args) = @_;

        my $db  = $opt->{db};
        my $env = $opt->{env} || 'development';

        exit usage()   unless $env =~ /^test|development|live$/;
        exit no_live() if     $env eq 'live';
        Artemis::Config::_switch_context($env);
        $self->init_testrundb();
}


# perl -Ilib bin/artemis-db-deploy upgrade --db=ReportsDB

1;
