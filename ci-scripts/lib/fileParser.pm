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
package fileParser;
use strict;
use warnings;
use base 'Exporter';
our $VERSION = '1.01';
our @EXPORT = qw(grepSingleLine);

sub grepSingleLine {
    my $inputFile = shift;
    my $searchExpression = shift;

    open(FH, '<', $inputFile) or die ("${!}: $inputFile!\n");
    while(<FH>) {
        my @matches = $_ =~ $searchExpression;
        if (@matches) {
            close(FH);
            return @matches;
        }
    }
    die("Failed to parse file $inputFile");
}
