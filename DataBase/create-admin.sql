--
-- create-admin.sql 
-- Create the admin account, and default passwords. This really is for testing
-- These passwords should be changed. 

use AnonID;

insert into users (id, name, status) values (0, 'admin', 'ACTIVE');

insert into shadow (uid, salt, password, type) 
	values (0, 'gtf0n00b', PASSWORD(CONCAT('gtf0n00b','admin')), 'ADMIN');
insert into shadow (uid, salt, password, type) 
	values (0, 'gtf1n00b', PASSWORD(CONCAT('gtf1n00b','login')), 'LOGIN');
insert into shadow (uid, salt, password, type) 
	values (0, 'gtf2n00b', PASSWORD(CONCAT('gtf2n00b','duress')), 'DURESS');
