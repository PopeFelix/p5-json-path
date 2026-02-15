requires 'Carp::Assert';
requires 'Exporter::Tiny';
requires 'Exporter::Shiny';
requires 'JSON::MaybeXS';
requires 'LV';
requires 'List::Util' => '1.45';    # For uniq.
requires 'Readonly';
requires 'Try::Tiny';
requires 'Class::Accessor::Fast';
requires 'perl' => '5.010';

on test => sub {
    requires 'Test2::V1';
};
