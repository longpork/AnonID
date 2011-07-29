use AnonID;
select (FLOOR(1 + (RAND() * 2147483646))) into @newid;
insert into users (id, name, status) values (@newid, 'admin', 'ACTIVE');
insert into shadow (uid, password, type) values (@newid, PASSWORD(CONCAT('admin','admin')), 'ADMIN');
insert into shadow (uid, password, type) values (@newid, PASSWORD(CONCAT('admin','norm')), 'NORMAL');
insert into shadow (uid, password, type) values (@newid, PASSWORD(CONCAT('admin','duress')), 'DURESS');