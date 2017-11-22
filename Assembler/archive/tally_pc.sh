#! /bin/sh

# Simply tallies all entries of form "# PC: "
# Used to measure ALU efficiency

grep PC: LOG | sed -r -e's/^# PC: +//' | sort -n | uniq -c | gview -

