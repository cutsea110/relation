set -e
psql -U admin sap <<EOSQL
-- 履修状況
CREATE TABLE take_lecture (
  student    VARCHAR(20),
  lecture    VARCHAR(20)
);

-- スキル獲得に必要な履修
CREATE TABLE skill_lecture (
  skill      VARCHAR(20),
  lecture    VARCHAR(20)
);

-- 履修サンプルデータ
INSERT INTO take_lecture
  (student, lecture)
VALUES
  ('伊東', 'データベース'),
  ('伊東', 'オペレーティングシステム'),
  ('伊東', 'アルゴリズム'),
  ('伊東', 'プログラミング'),
  ('伊東', 'ネットワーク'),
  ('柴田', '並列計算'),
  ('柴田', 'ハードウェア設計'),
  ('柴田', 'ネットワーク'),
  ('田中', 'アルゴリズム'),
  ('田中', 'オペレーティングシステム'),
  ('田中', 'ネットワーク'),
  ('田中', 'ハードウェア設計'),
  ('山下', 'アルゴリズム'),
  ('山下', 'プログラミング'),
  ('山下', 'ネットワーク'),
  ('山下', '並列計算'),
  ('山下', 'ハードウェア設計');

INSERT INTO skill_lecture
  (skill, lecture)
VALUES
  ('ハードウェア開発者', 'データベース'),
  ('ハードウェア開発者', 'オペレーティングシステム'),
  ('ハードウェア開発者', 'ネットワーク'),
  ('ソフトウェア開発者', 'アルゴリズム'),
  ('ソフトウェア開発者', 'ネットワーク'),
  ('ソフトウェア開発者', 'プログラミング'),
  ('ミドルウェア開発者', 'オペレーティングシステム'),
  ('ミドルウェア開発者', 'ネットワーク'),
  ('ミドルウェア開発者', 'ハードウェア設計'),
  ('リサーチャー', '並列計算'),
  ('リサーチャー', 'ハードウェア設計');


-- 関係除算により
-- 履修状況から保有スキルを抽出する
WITH student_skill AS (
    SELECT DISTINCT student, skill
    FROM take_lecture, skill_lecture
)
SELECT DISTINCT ss.student, ss.skill
FROM student_skill ss
JOIN take_lecture tl1 ON ss.student = tl1.student
WHERE NOT EXISTS (
    SELECT lecture
    FROM skill_lecture
    WHERE skill = ss.skill

    EXCEPT

    SELECT lecture
    FROM take_lecture tl2
    WHERE tl1.student = tl2.student
)
;

-- スキル獲得までに必要な履修
WITH student_skill AS (
    SELECT DISTINCT student, skill
    FROM take_lecture, skill_lecture
)
SELECT ss.student, ss.skill, sl.lecture
FROM student_skill ss
JOIN skill_lecture sl ON ss.skill = sl.skill

EXCEPT

SELECT ss.student, ss.skill, tl1.lecture
FROM student_skill ss
JOIN take_lecture tl1 ON ss.student = tl1.student
;

--------------------------------------------------
CREATE TABLE account (
  name         VARCHAR(20) NOT NULL,
  age          INTEGER     NOT NULL,
  sex          CHAR(1)     NOT NULL,

  PRIMARY KEY(name)
);

CREATE TABLE social_network (
  follower     VARCHAR(20) NOT NULL,
  followee     VARCHAR(20) NOT NULL,

  FOREIGN KEY (follower) REFERENCES account (name),
  FOREIGN KEY (followee) REFERENCES account (name),
  PRIMARY KEY (follower, followee)
);

INSERT INTO account
  (name, age, sex)
VALUES ('音無',   27, '女'),
       ('一の瀬', 50, '女'),
       ('二階堂', 22, '男'),
       ('三鷹',   32, '男'),
       ('四谷',   43, '男'),
       ('五代',   25, '男'),
       ('六本木', 29, '女'),
       ('七尾',   25, '女'),
       ('八神',   17, '女'),
       ('九条',   24, '女');

INSERT INTO social_network
   (follower, followee)
VALUES ('音無',   '一の瀬'),
       ('音無',   '三鷹'),
       ('音無',   '四谷'),
       ('音無',   '五代'),
       ('音無',   '六本木'),
       ('音無',   '七尾'),
       ('音無',   '八神'),
       ('一の瀬', '音無'),
       ('二階堂', '五代'),
       ('三鷹',   '音無'),
       ('三鷹',   '五代'),
       ('四谷',   '五代'),
       ('五代',   '音無'),
       ('五代',   '三鷹'),
       ('五代',   '四谷'),
       ('五代',   '七尾'),
       ('六本木', '音無'),
       ('六本木', '五代'),
       ('七尾',   '五代'),
       ('八神',   '五代'),
       ('八神',   '音無'),
       ('九条',   '音無'),
       ('九条',   '三鷹');

-- R . (S /\ T) \subseteq R . S /\ R . T
-- R . (S /\ T)
SELECT distinct sn.followee              -- R
  FROM social_network sn
  JOIN account a ON a.name = sn.follower -- R
 WHERE a.age <= 25 AND a.sex = '女'; -- S /\ T

-- R . S /\ R . T
SELECT distinct sn.followee              -- R
  FROM social_network sn
  JOIN account a ON a.name = sn.follower -- R
 WHERE a.age <= 25    -- S
INTERSECT
SELECT distinct sn.followee              -- R
  FROM social_network sn
  JOIN account a ON a.name = sn.follower -- R
 WHERE a.sex = '女';  -- T

-- モジュラ則
-- R . S /\ T \subseteq R . (S /\ R^op . T)
--
-- R . S /\ T
SELECT a.name, sn.followee               -- R
  FROM social_network sn
  JOIN account a ON a.name = sn.follower
 WHERE a.age <= 25 AND a.sex = '女'      -- S
INTERSECT
SELECT sn.follower, sn.followee          -- T
  FROM social_network sn
  JOIN account a1 ON a1.name = sn.follower
  JOIN account a2 ON a2.name = sn.followee
 WHERE a1.sex <> a2.sex                  -- T
;

-- R . (S /\ R^op . T)
WITH t AS (
    SELECT sn.follower, sn.followee          -- T
      FROM social_network sn
      JOIN account a1 ON a1.name = sn.follower
      JOIN account a2 ON a2.name = sn.followee
     WHERE a1.sex <> a2.sex                  -- T
),
sub AS (
    SELECT name                              -- S
      FROM account
     WHERE age <= 25 AND sex = '女'          -- S
    INTERSECT
    SELECT sn.follower AS name               -- R^op
      FROM social_network sn
      JOIN t ON t.followee = sn.followee     -- T
)
SELECT sn.follower, sn.followee
  FROM social_network sn
  JOIN sub ON sub.name = sn.follower
;

EOSQL
