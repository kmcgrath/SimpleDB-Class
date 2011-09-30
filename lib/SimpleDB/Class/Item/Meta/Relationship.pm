package SimpleDB::Class::Item::Meta::Relationship;
use Moose;


has 'method_name' => (
    is   => 'rw',
    isa  => 'Str',
);


has 'meta_class' => (
    is   => 'rw',
    isa  => 'SimpleDB::Class::Item::Meta',
);

1;

