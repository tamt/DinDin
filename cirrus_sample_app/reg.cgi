#! /usr/bin/python --

"""
reg.cgi by Michael Thornburgh.
This file is in the public domain.

IMPORTANT: This script is for illustrative purposes only. It does
not have user authentication or other access control measures that
a real production service would have.

This script should be placed in the cgi-bin location according to
your web server installation. The database is an SQLite3 database.
Edit the location of the database in variable "dbFile".
Create it with the following schema:

.schema

CREATE TABLE registrations (
    m_username VARCHAR COLLATE NOCASE,
    m_identity VARCHAR,
    m_updatetime DATETIME,
    
    PRIMARY KEY (m_username)
);

CREATE INDEX registrations_updatetime ON registrations (m_updatetime ASC);

"""

# CHANGE THIS
dbFile = '.../registrations.db'

import cgi
import sqlite3
import xml.sax.saxutils


query = cgi.parse()
db = sqlite3.connect(dbFile)

user = query.get('username', [None])[0]
identity = query.get('identity', [None])[0]
friends = query.get('friends', [])


print 'Content-type: text/plain\n\n<?xml version="1.0" encoding="utf-8"?>\n<result>'

if user:
	try:
		c = db.cursor()
		c.execute("insert or replace into registrations values (?, ?, datetime('now'))", (user, identity))
		print '\t<update>true</update>'
	except:
		print '\t<update>false</update>'

for f in friends:
	print "\t<friend>\n\t\t<user>%s</user>" % (xml.sax.saxutils.escape(f), )
	c = db.cursor()
	c.execute("select m_username, m_identity from registrations where m_username = ? and m_updatetime > datetime('now', '-1 hour')", (f, ))
	for result in c.fetchall():
		eachIdent = result[1]
		if not eachIdent:
			eachIdent = ""
		print "\t\t<identity>%s</identity>" % (xml.sax.saxutils.escape(eachIdent), )
		if f != result[0]:
			print "\t\t<registered>%s</registered>" % (xml.sax.saxutils.escape(result[0]), )
	print "\t</friend>"

db.commit()

print "</result>"

