CREATE DATABASE homeagent;

-- create table
CREATE TABLE user_types(
  id SERIAL4 PRIMARY KEY,
  name VARCHAR(50) NOT NULL
);

INSERT INTO user_types (name) VALUES
('manager');
INSERT INTO user_types (name) VALUES
('customer');
INSERT INTO user_types (name) VALUES
('owner');


CREATE TABLE users(
  id SERIAL4 PRIMARY KEY,
  email VARCHAR(50) NOT NULL,
  password_digest VARCHAR(400) NOT NULL,
  name VARCHAR(50) NOT NULL,
  phone VARCHAR(50) NOT NULL,
  occupation VARCHAR(200),
  user_type_id INTEGER
);

CREATE TABLE properties(
  id SERIAL4 PRIMARY KEY,
  kind VARCHAR(50) NOT NULL,
  address VARCHAR(100) NOT NULL,
  suburb VARCHAR(50) NOT NULL,
  image VARCHAR(1000),
  rent VARCHAR(50) NOT NULL,
  description VARCHAR(1000),
  post_date TIMESTAMP NOT NULL,
  user_id INTEGER,
  property_purpose_id INTEGER
);

CREATE TABLE messages(
   id SERIAL4 PRIMARY KEY,
   suburb VARCHAR(50) NOT NULL,
   requirement VARCHAR(1000),
   post_date TIMESTAMP NOT NULL,
   user_id INTEGER
);
INSERT INTO messages (suburb, requirement, post_date, user_id) VALUES
('CBD','I need two bedrooms unit','2014-6-2 12:12:12', 1);
INSERT INTO messages (suburb, requirement, post_date, user_id) VALUES
('Carnegie','I need two bedrooms unit','2015-8-2 12:12:12', 1);

CREATE TABLE property_purposes(
  id SERIAL4 PRIMARY KEY,
  name VARCHAR(50) NOT NULL
);

INSERT INTO property_purposes (name) VALUES
('for lease');
INSERT INTO property_purposes (name) VALUES
('for sale');


CREATE TABLE comments(
  id SERIAL4 PRIMARY KEY,
  content VARCHAR(1000) NOT NULL,
  message_id INTEGER,
  property_id INTEGER,
  user_id INTEGER
);
