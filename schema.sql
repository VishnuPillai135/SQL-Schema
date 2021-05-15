-- COMP3311 20T3 Assignment 1
-- Calendar schema
-- Written by Vishnu Pillai

-- Types

create type AccessibilityType as enum ('read-write','read-only','none');
create type InviteStatus as enum ('invited','accepted','declined');

-- add more types/domains if you want
create type VisibilityStatus as enum ('public', 'private');
-- Tables

create table Users (
	id          serial,
	email       text UNIQUE not null CHECK (email ~* '.+@.+'),
	name        text not null, 
    passwd      text not null,
    is_admin    boolean not null,
	primary key (id)
);

create table Groups (
	id          serial, 
	name        text not null,
	Owner		serial not null,
	foreign key (Owner) references Users(id),
	primary key (id)
);

create table Member (
	user_id		serial references Users(id),
	group_id	serial references Groups(id),
	primary key (user_id, group_id)
);

create table Calendars (
    id          serial,
    colour      text not null, 
    name        text not null,
    default_access AccessibilityType not null,
	owner		serial not null,
	foreign key (owner) references Users(id),
	primary key (id)
);

create table Accessibility (
	calendar_id		serial references Calendars(id),
	user_id			serial references Users(id),
	access 			AccessibilityType not null,
	primary key (calendar_id, user_id)
);

create table Subscribed (
	calendar_id		serial references Calendars(id),
	user_id			serial references Users(id),
	colour			text,
	primary key (calendar_id, user_id)
);


create table Events (
	id			serial,
	title 		text not null,
	visibility	VisibilityStatus not null,
	location 	text,
	end_time	time,
	start_time	time, 
	Part_Of		serial not null,
	Created_By	serial not null,
	primary key (id),
	foreign key (Part_Of) references Calendars(id),
	foreign key (Created_By) references Users(id)
);

create table Invited (
	events_id	serial references Events(id),
	users_id	serial references Users(id),
	status		InviteStatus not null,
	primary key (events_id, users_id)
);

create table Alarms (
	events_id	serial references Events(id),
	alarm		integer, --- let it be null in case user does not want to set an alarm
	CHECK (alarm >= 1),
	primary key (events_id, alarm)
);

create table One_Day_Events (
	event_id 	serial,
	date		date not null, 
	primary key (event_id),
	foreign key (event_id) references Events(id)
);

create table Spanning_Events (
	event_id	serial,
	start_date	date not null,
	end_date	date not null,
	primary key (event_id),
	foreign key (event_id) references Events(id)
);

create table Recurring_Events (
	event_id	serial,
	ntimes		integer,
	CHECK (ntimes >= 1),
	start_date	date not null,
	end_date	date,
	primary key (event_id),
	foreign key (event_id) references Events(id)
);

create table Weekly_Events (
	recurring_event_id 	serial,
	day_Of_Week			char(3) not null,
	CHECK (day_Of_Week in ('mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun')),
	frequency			integer not null,
	CHECK (frequency >= 1),
	primary key (recurring_event_id),
	foreign key (recurring_event_id) references Recurring_Events(event_id)
);

create table Monthly_By_Day_Events (
	recurring_event_id 	serial,
	day_Of_Week			char(3) not null,
	CHECK (day_Of_Week in ('mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun')),
	week_In_Month		integer not null,
	CHECK (week_In_Month <= 5),
	CHECK (week_In_Month >= 1),
	primary key (recurring_event_id),
	foreign key (recurring_event_id) references Recurring_Events(event_id)
);

create table Monthly_By_Date_Events (
	recurring_event_id 	serial,
	date_In_Month		integer not null,
	CHECK (date_In_Month <= 31),
	CHECK (date_In_Month >= 1),
	primary key (recurring_event_id),
	foreign key (recurring_event_id) references Recurring_Events(event_id)
);

create table Annual_Events (
	recurring_event_id 	serial,
	date				date not null,
	primary key (recurring_event_id),
	foreign key (recurring_event_id) references Recurring_Events(event_id)
);
