#  MIT License
#
#  Copyright (c) 2021 - 2022 ViliusSutkus89.com
#
#  https://github.com/ViliusSutkus89/Sample_Android_Library-MavenCentral-Instrumented_Tests
#  ci-scripts/lib/fileParser.pm - v2.1.0
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in all
#  copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.
#
package fileUpdater;
use warnings;
use strict;

use base 'Exporter';
our $VERSION = '2.1.0';

use File::Find 'find';
use File::Path 'make_path';

use File::Basename 'dirname';
use lib dirname(__FILE__);
use pathResolver 'getAbsolutePath';

sub new {
    my ($class, $args) = @_;
    my $self = {
        rootDirectory          => $args->{rootDirectory},
        outputDirectory        => $args->{outputDirectory}
    };
    bless $self, $class;

    $self->{rootDirectory} = getAbsolutePath($self->{rootDirectory});
    if ($self->{outputDirectory}) {
        # 1: Check if dir does not exist
        # 2: Get absolute path without resolving (because resolving requires dir to actually exist)
        # 3: mkdir
        # 4: Resolve path
        $self->{outputDirectory} = getAbsolutePath($self->{outputDirectory}, { doResolvePathAndCheckIfExists => 0 });
        -e $self->{outputDirectory} && die("Output directory $self->{outputDirectory} already exists!\n");
        File::Path::make_path($self->{outputDirectory}, { chmod => 0755 });
        $self->{outputDirectory} = getAbsolutePath($self->{outputDirectory}, { doResolvePathAndCheckIfExists => 1 });
    }

    return $self;
}

sub update {
    my $self = shift;
    my $input = shift;
    my $lineUpdateExpressionsRef = shift if (@_);
    my $filenameUpdateExpressionsRef = shift if (@_);

    my $recursion = sub {
        $self->update(shift, $lineUpdateExpressionsRef, $filenameUpdateExpressionsRef);
    };

    if ('ARRAY' eq ref($input)) {
        foreach my $file (@$input) {
            &$recursion($file);
        }
        return;
    }
    elsif ('' ne ref($input)) {
        use Data::Dumper;
        die('Unrecognized input: ' . Dumper($input));
    }

    my $inputFile = getAbsolutePath($input, {
        pathRelativeTo                => $self->{rootDirectory},
        doResolvePathAndCheckIfExists => 1
    });

    -e $inputFile or die("Input $inputFile does not exist!\n");
    if (-d _) {
        File::Find::find(sub {
            &$recursion($File::Find::name) if (-f $File::Find::name);
        }, $inputFile);
    }
    elsif (-f _) {
        $self->__updateSingleFile($inputFile, $lineUpdateExpressionsRef, $filenameUpdateExpressionsRef);
    }
}

sub append {
    my $self = shift;
    my $input = shift;

    my $lineToAppend = shift;
    my $recursion = sub {
        $self->append(shift, $lineToAppend);
    };

    if ('ARRAY' eq ref($input)) {
        foreach my $file (@$input) {
            &$recursion($file);
        }
        return;
    }
    elsif ('' ne ref($input)) {
        use Data::Dumper;
        die('Unrecognized input: ' . Dumper($input));
    }

    my $inputFile = getAbsolutePath($input, {
        pathRelativeTo                => $self->{rootDirectory},
        doResolvePathAndCheckIfExists => 1
    });

    -e $inputFile or die("Input $inputFile does not exist!\n");
    if (-d _) {
        File::Find::find(sub {
            &$recursion($File::Find::name) if (-f $File::Find::name);
        }, $inputFile);
    }
    elsif (-f _) {
        my $outputFile = $inputFile;
        my $inPlaceEdit = !$self->{outputDirectory};
        if ($inPlaceEdit != 1) {
            $outputFile = $self->{outputDirectory} . substr($inputFile, length($self->{rootDirectory}));
        }

        $self->__updateSingleFile($inputFile) if ! -e $outputFile;

        open(my $FH_OUTPUT, '>>', $outputFile) or die "$! : $outputFile\n";
        print $FH_OUTPUT $lineToAppend;
        close($FH_OUTPUT);
    }
}

sub __updateSingleFile {
    my $self = shift;
    my $inputFile = shift;
    my $lineUpdateExpressionsRef = shift if (@_);
    my $filenameUpdateExpressionsRef = shift if (@_);

    my $outputFile = $inputFile;
    my $inPlaceEdit = !$self->{outputDirectory};
    if ($inPlaceEdit != 1) {
        $outputFile = $self->{outputDirectory} . substr($inputFile, length($self->{rootDirectory}));
    }

    if (defined $filenameUpdateExpressionsRef) {
        $outputFile = &$filenameUpdateExpressionsRef($outputFile, $inputFile);
        if (!defined $outputFile) {
            return;
        }
    }

    open(my $FH_INPUT, '<', $inputFile) or die "$! : $inputFile\n";
    if ($inPlaceEdit == 1) {
        rename($inputFile, $inputFile . '.orig');
        $inputFile = $inputFile . '.orig';
    }
    else {
        File::Path::make_path(File::Basename::dirname($outputFile), { chmod => 0755 });
    }

    open(my $FH_OUTPUT, '>', $outputFile) or die "$! : $outputFile\n";
    while (<$FH_INPUT>) {
        if (defined $lineUpdateExpressionsRef) {
            $_ = &$lineUpdateExpressionsRef($_);
        }
        print $FH_OUTPUT $_;
    }

    my $mode = (stat($FH_INPUT))[2] & 07777;
    close($FH_INPUT);
    chmod($mode, $FH_OUTPUT);
    close($FH_OUTPUT);

    if ($inPlaceEdit == 1) {
        unlink($inputFile);
    }
}
