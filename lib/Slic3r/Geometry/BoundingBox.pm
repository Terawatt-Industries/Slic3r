package Slic3r::Geometry::BoundingBox;
use Moo;
use Slic3r::Geometry qw(X Y Z MIN MAX X1 Y1 X2 Y2);
use Storable qw();

has 'extents' => (is => 'ro', required => 1);

sub clone { Storable::dclone($_[0]) }

# four-arguments 2D bb
sub bb {
    my $self = shift;
    my $extents = $self->extents;
    return [ $extents->[X][MIN], $extents->[Y][MIN], $extents->[X][MAX], $extents->[Y][MAX] ];
}

sub polygon {
    my $self = shift;
    return Slic3r::Polygon->new_from_bounding_box($self->bb);
}

sub rotate {
    my $self = shift;
    my ($angle, $center) = @_;
    
    # rotate the 2D bounding box polygon and leave Z unaltered
    my $bb_p = $self->polygon;
    $bb_p->rotate($angle, $center);
    my @bb = $bb_p->bounding_box;
    $self->extents->[X][MIN] = $bb[X1];
    $self->extents->[Y][MIN] = $bb[Y1];
    $self->extents->[X][MAX] = $bb[X2];
    $self->extents->[Y][MAX] = $bb[Y2];
    
    $self;
}

sub scale {
    my $self = shift;
    my ($factor) = @_;
    
    $_ *= $factor
        for map @$_[MIN,MAX],
            grep $_, @{$self->extents}[X,Y,Z];
    
    $self;
}

sub size {
    my $self = shift;
    
    my $extents = $self->extents;
    return [ map $extents->[$_][MAX] - $extents->[$_][MIN], grep $extents->[$_], (X,Y,Z) ];
}

sub center {
    my $self = shift;
    
    my $extents = $self->extents;
    return [ map +($extents->[$_][MAX] + $extents->[$_][MIN])/2, grep $extents->[$_], (X,Y,Z) ];
}

sub center_2D {
    my $self = shift;
    return Slic3r::Point->new(@{$self->center}[X,Y]);
}

sub min_point {
    my $self = shift;
    return Slic3r::Point->new($self->extents->[X][MIN], $self->extents->[Y][MIN]);
}

sub max_point {
    my $self = shift;
    return Slic3r::Point->new($self->extents->[X][MAX], $self->extents->[Y][MAX]);
}

1;
