CREATE TABLE t_areas(
	id INT NOT NULL PRIMARY KEY,
	name VARCHAR(255),
	UNIQUE INDEX(name)
) Type=InnoDB;

CREATE TABLE t_issues(
	id INT NOT NULL PRIMARY KEY,
	area_id INT,
	state VARCHAR(20),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	INDEX(area_id), FOREIGN KEY(area_id) REFERENCES t_areas(id) ON DELETE CASCADE
) Type=InnoDB;

CREATE TABLE t_initiatives(
	id INT NOT NULL PRIMARY KEY,
	issue_id INT,
	INDEX(issue_id), FOREIGN KEY(issue_id) REFERENCES t_issues(id) ON DELETE CASCADE) Type=InnoDB;

