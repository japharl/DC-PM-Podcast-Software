drop database present;
create database present;
use present;
create table vnc_clients(
  client_id int,
  password varchar(255),
  barcode_ok int,
  host_alias varchar(255),
  ip varchar(255)
);

create table barcode_ok_code(
  code int,
  descript varchar(255)
);

insert into barcode_ok_code(code,descript) values (1,'Unable to connect.');
insert into barcode_ok_code(code,descript) values (2,'Barcode unreadable.');
insert into barcode_ok_code(code,descript) values (3,'Fail Reconnect Test.');
insert into barcode_ok_code(code,descript) values (4,'Success.');

create table active_recording(
  epoch_start int
);

create table events(
  event_epoch int,
  event_type varchar(20),
  event_extra varchar(4000)
);

create index x on events(event_epoch);
