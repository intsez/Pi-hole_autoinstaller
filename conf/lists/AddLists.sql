CREATE TEMP TABLE i(txt);
.separator ~
.import /root/pihole/PiHoleBlackLists.txt i
INSERT OR IGNORE INTO adlist (address) SELECT txt FROM i;
DROP TABLE i;
