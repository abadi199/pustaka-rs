CREATE TABLE publication_progress(
  publication_id INT NOT NULL PRIMARY KEY,
  progress FLOAT NOT NULL,
  FOREIGN KEY(publication_id) REFERENCES publication(id)
)
