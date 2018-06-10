CREATE TABLE category (
  id INTEGER NOT NULL PRIMARY KEY,
  name VARCHAR NOT NULL,
  parent_id INTEGER NULL,
  FOREIGN KEY(parent_id) REFERENCES category(id)
);

CREATE TABLE media_type (
  id INTEGER NOT NULL PRIMARY KEY,
  name VARCHAR NOT NULL
);

CREATE TABLE author (
  id INTEGER NOT NULL PRIMARY KEY,
  name VARCHAR NOT NULL
);

CREATE TABLE publication (
  id INTEGER NOT NULL PRIMARY KEY,
  isbn VARCHAR NOT NULL,
  title VARCHAR NOT NULL,
  media_type INTEGER NULL,
  author INTEGER NOT NULL,
  FOREIGN KEY(media_type) REFERENCES media_type(id),
  FOREIGN KEY(author) REFERENCES author(id)
);

CREATE TABLE publication_category (
  publication_id INTEGER NOT NULL,
  category_id INTEGER NOT NULL,
  PRIMARY KEY (publication_id, category_id),
  FOREIGN KEY(publication_id) REFERENCES publication(id),
  FOREIGN KEY(category_id) REFERENCES category(id),
);

