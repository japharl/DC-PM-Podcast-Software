drop database if exists podcasts;
create database podcasts;
use podcasts;
create table data(
  podcast_id int not null primary key auto_increment,
  epoch_time int null,
  topic varchar(4000)
);

create table links(
  link_id int not null primary key auto_increment,
  podcast_id int,
  link varchar(4000)
);
