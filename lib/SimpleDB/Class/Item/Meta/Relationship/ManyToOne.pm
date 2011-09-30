package SimpleDB::Class::Item::Meta::Relationship::ManyToOne;
use Moose;

extends 'SimpleDB::Class::Item::Meta::Relationship';


has 'target_class' => (
    is   => 'ro',
    isa  => 'Str',
);


has 'target_attribute' => (
    is   => 'ro',
    isa  => 'Str',
);


has 'mate' => (
    is   => 'ro',
    isa  => 'Str',
);


has 'consistent' => (
    is   => 'ro',
    isa  => 'Bool',
    default => 0,
);


sub BUILD {
    my $self = shift;
    my $meta_class = $self->meta_class;

    my $consistent   = $self->consistent;
    my $mate         = $self->mate;
    my $attribute    = $self->target_attribute;
    my $target_class = $self->target_class;
   
    my $clearer = 'clear_'.$self->method_name;
    my $predicate = 'has_'.$self->method_name;
    $meta_class->add_attribute($self->method_name, {
        is      => 'rw',
        lazy    => 1,
        default => sub {
                my $self = shift;
                my $id = $attribute;
                return undef unless ($id ne '');
                my %find_options;
                if ($mate) {
                    $find_options{set} = { $mate => $self };
                }
                $find_options{consistent} = $consistent;
                return $self->simpledb->domain($target_class)->find($id, %find_options);
            },
        predicate => $predicate,
        clearer => $clearer,
        });
    $meta_class->add_after_method_modifier($attribute, sub {
        my ($self, $value) = @_;
        if (defined $value) {
            $self->$clearer;
        }
    });
}



1;
