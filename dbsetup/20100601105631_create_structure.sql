CREATE TABLE t_areas(
	id INT NOT NULL PRIMARY KEY,
	name VARCHAR(255),
	UNIQUE INDEX(name)
) Type=InnoDB DEFAULT CHARACTER SET = utf8;

CREATE TABLE t_issues(
	id INT NOT NULL PRIMARY KEY,
	area_id INT,
	state VARCHAR(20),
	created_at DATETIME,
	accepted_at DATETIME,
	half_frozen_at DATETIME,
	fully_frozen_at DATETIME,
	closed_at DATETIME,
	INDEX(area_id), FOREIGN KEY(area_id) REFERENCES t_areas(id) ON DELETE CASCADE
) Type=InnoDB DEFAULT CHARACTER SET = utf8;

CREATE TABLE t_initiatives(
	id INT NOT NULL PRIMARY KEY,
	issue_id INT,
	name VARCHAR(255),
	discussion_url VARCHAR(255),
	created_at DATETIME,
	draft_updated_at DATETIME,
	draft_content TEXT,
	INDEX(issue_id), FOREIGN KEY(issue_id) REFERENCES t_issues(id) ON DELETE CASCADE) Type=InnoDB DEFAULT CHARACTER SET = utf8;

