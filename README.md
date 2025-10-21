# QList

simple data format that is parsed to a hashmap\
the Q is short for quick because the format is supposed to be quick/easy to write and parse

basic types:

```qlist
/ comment
i my_int 100
f my_float 10.0
s my_str hello
b my_bool t
```

complex types:

```qlist
/ multiline string marked with a uppercase S
/ and a linecount after the name
S multi_line_str 3
hello
i am multiline
(third line here)
/ ends before this comment
```

## format

> [!NOTE]
> the type, name and value/line count are seperated with singlular spaces

the type of a field is at the front so the parser can easily tell the type or if a line is a comment with a single switch statement

after the type is the name of the field

then from the name to the end of line is the value\
unless its multiline then the linecount is after the name and the value begins on the next line
