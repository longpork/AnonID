use AnonID;
insert into users (id, name, status) values (0, 'admin', 'ACTIVE');
insert into shadow (uid, password, type) values (0, PASSWORD(CONCAT('admin','admin')), 'ADMIN');
insert into shadow (uid, password, type) values (0, PASSWORD(CONCAT('admin','norm')), 'NORMAL');
insert into shadow (uid, password, type) values (0, PASSWORD(CONCAT('admin','duress')), 'DURESS');