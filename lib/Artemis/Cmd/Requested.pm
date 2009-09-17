use MooseX::Declare;

=head1 NAME

Artemis::Cmd::Request - Backend functions for manipluation of requested hosts or features in the database

=head1 SYNOPSIS

This project is offers wrapper around database manipulation functions. These
wrappers handle things like setting default values or id<->name
translation. This module handles requested hosts and features for a
testrequest.

    use Artemis::Cmd::Testrun;

    my $bar = Artemis::Cmd::Testrun->new();
    $bar->add($testrun);
    ...

=head1 FUNCTIONS


=head2 add_host

Add a requested host entry to database.

=cut

class Artemis::Cmd::Requested
  extends Artemis::Cmd
{
        use Artemis::Model 'model';
  

=head2 add_host

Add a requested host for a given testrun.

@param int    - testrun id
@param string - hostname

@return success - local id (primary key)
@return error   - undef

=cut

        method add_host($id, $hostname) {

                my $hosts = model('TestrunDB')->resultset('Host')->search({name => $hostname});
                return if not $hosts;
                my $host_id = $hosts->first->id;
                my $request = model('TestrunDB')->resultset('TestrunRequestedHost')->new({testrun_id => $id, host_id => $host_id});
                $request->insert();
                return $request->id;
        }

=head2 add_feature

Add a requested feature for a given testrun.

@param int    - testrun id
@param string - hostname

@return success - local id (primary key)
@return error   - undef

=cut

        method add_feature($id, $feature) {

                my $request = model('TestrunDB')->resultset('TestrunRequestedFeature')->new({testrun_id => $id, feature => $feature});
                $request->insert();
                return $request->id;
        }
}


=head1 AUTHOR

OSRC SysInt Team, C<< <osrc-sysint at elbe.amd.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<osrc-sysin at elbe.amd.com>, or through
the web interface at L<https://osrc/bugs>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 COPYRIGHT & LICENSE

Copyright 2009 OSRC SysInt Team, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Artemis::Cmd::Testrun
