#  MIT License
#
#  Copyright (c) 2021 Vilius Sutkus <ViliusSutkus89@gmail.com>
#
#  https://github.com/ViliusSutkus89/Sample_Android_Library-MavenCentral-Instrumented_Tests
#  ci-scripts/lib/fileParser.pm - v1.1.5
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
package pathResolver;
use strict;
use warnings;

use base 'Exporter';
our $VERSION = '1.01';
our @EXPORT = qw(getAbsolutePath getAbsolutePathOfBasedir);

sub getAbsolutePath {
    use Cwd qw/abs_path getcwd/;

    my $path = shift;
    my $options = shift if @_;
    if (!defined($options->{pathRelativeTo})) {
        $options->{pathRelativeTo} = Cwd::getcwd;
    }
    if (!defined($options->{doResolvePathAndCheckIfExists})) {
        $options->{doResolvePathAndCheckIfExists} = 1;
    }

    # Implementation taken and heavily modified from
    # https://stackoverflow.com/questions/39275327/check-if-a-directory-exists-as-an-absolute-path/39275654#39275654
    if ($path =~ /^~/) {
        $path =~ s/^~/$ENV{HOME}/;
    }
    if ($path !~ m#^/#) {
        $path = $options->{pathRelativeTo} . '/' . $path;
    }

    if ($options->{doResolvePathAndCheckIfExists}) {
        # Cwd::abs_path() does not work on non-existent paths
        my $pathResolved = Cwd::abs_path($path);
        if (!$pathResolved || !-e $path) {
            die "Failed to resolve path: $path!\n";
        }
        $path = $pathResolved;
    }

    return $path;
}

sub getAbsolutePathOfBasedir {
    my $path = shift;
    my $basedirCount = shift;

    $path = getAbsolutePath($path);
    foreach (1..$basedirCount) {
        $path = File::Basename::dirname($path);
    }
    $path = getAbsolutePath($path);
    return $path;
}
