CREATE TABLE recent_publication(
  publication_id INT NOT NULL PRIMARY KEY,
  timestamp DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(publication_id) REFERENCES publication(id)
)
