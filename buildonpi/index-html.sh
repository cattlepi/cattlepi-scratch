#!/bin/sh

echo '<html><body>'
echo '<p>build output will be displayed here when available</p>'
sed 's/^.*/<a href="&">&<\/a><br\/>/'
echo '</body></html>'