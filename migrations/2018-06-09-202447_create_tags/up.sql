CREATE TABLE tag (
  id INTEGER NOT NULL PRIMARY KEY,
  name VARCHAR NOT NULL
);

CREATE TABLE publication_tag (
  publication_id INTEGER NOT NULL,
  tag_id INTEGER NOT NULL,
  PRIMARY KEY (publication_id, tag_id),
  FOREIGN KEY(publication_id) REFERENCES publication(id),
  FOREIGN KEY(tag_id) REFERENCES tag(id)
);