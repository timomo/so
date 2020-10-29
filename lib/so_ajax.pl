use utf8;

sub footer_ajax_use
{

}

sub header_ajax_use
{
    print <<EOF;
Cache-Control: no-cache
Pragma: no-cache
Content-Type: text/html; charset=UTF-8

EOF
}

1;
