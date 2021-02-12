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

-- (R /\ S) . T \subseteq R . T /\ S . T
-- (R /\ S) . T
SELECT DISTINCT sn.followee
  FROM social_network sn                 -- T
  JOIN account a ON a.name = sn.follower
 WHERE a.age <= 25 AND a.sex = '女'      -- R /\ S
;

-- R . T /\ S . T
SELECT sn.followee
  FROM social_network sn                  -- T
  JOIN account a ON a.name = sn.follower
 WHERE a.age <= 25                        -- R
INTERSECT
SELECT sn.followee
  FROM social_network sn                  -- T
  JOIN account a ON a.name = sn.follower
 WHERE a.sex = '女'                       -- S
;


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

--------------------------------------------------
CREATE TABLE party_member (
  party        VARCHAR(20)   NOT NULL,
  member       VARCHAR(20)   NOT NULL,

  PRIMARY KEY(party, member)
);

CREATE TABLE supporter_member (
  supporter    VARCHAR(20)   NOT NULL,
  member       VARCHAR(20)   NOT NULL,

  PRIMARY KEY(supporter, member)
);

CREATE TABLE supporter_party (
  supporter    VARCHAR(20)   NOT NULL,
  party        VARCHAR(20)   NOT NULL,

  PRIMARY KEY(supporter, party)
);

--------------------------------------------------
CREATE TABLE coop_order (
  id           BIGINT        NOT NULL,
  ordered_at   DATE          NOT NULL,

  PRIMARY KEY (id)
);

CREATE TABLE order_item (
  order_id     BIGINT        NOT NULL,
  item         VARCHAR(20)   NOT NULL,
  price        INTEGER       NOT NULL,
  
  FOREIGN KEY (order_id) REFERENCES coop_order (id)
);

CREATE TABLE stock_item (
  order_id     BIGINT        NOT NULL,
  item         VARCHAR(20)   NOT NULL,

  FOREIGN KEY (order_id) REFERENCES coop_order (id)
);

INSERT INTO coop_order
  (id, ordered_at)
VALUES (101, '2021-01-06'),
       (102, '2021-01-13'),
       (103, '2021-01-20'),
       (104, '2021-01-27'),
       (105, '2021-02-03');

INSERT INTO order_item
   (order_id, item, price)
VALUES (101, 'ラーメン', 500),
       (101, 'ビビンバセット', 400),
       (101, 'ティッシュ', 350),
       (101, '牛乳', 1200),
       (101, 'たまご', 200),
       (102, '冷凍うどん', 500),
       (102, '牛乳', 1200),
       (102, 'たまご', 200),
       (102, '冷凍おにぎり', 390),
       (103, '牛乳', 1200),
       (103, 'たまご', 200),
       (103, 'ブロッコリー', 400),
       (103, '冷凍唐揚げ', 460),
       (103, '冷凍うどん', 500),
       (104, '牛乳', 1200),
       (104, 'たまご', 200),
       (104, '牛角キムチ', 410),
       (104, 'ビビンバセット', 400),
       (104, 'トイレットペーパー', 470),
       (104, '冷凍おにぎり', 390),
       (105, '牛乳', 1200),
       (105, 'たまご', 200),
       (105, 'ブロッコリー', 400),
       (105, 'ビビンバセット', 400);

INSERT INTO stock_item
  (order_id, item)
VALUES (101, 'ティッシュ'),
       (102, '冷凍うどん'),
       (103, '冷凍唐揚げ'),
       (104, 'トイレットペーパー'),
       (104, '牛角キムチ'),
       (105, '牛乳'),
       (105, 'たまご'),
       (105, 'ブロッコリー');

-- モジュラ則
-- R . S /\ T \subseteq R . (S /\ R^op . T)
-- R . S /\ T
SELECT co.id, oi.item
  FROM coop_order co
  JOIN order_item oi ON co.id = oi.order_id  -- R
 WHERE (
        date_part('year', co.ordered_at),
        date_part('month', co.ordered_at),
        date_part('day', co.ordered_at)
       ) IN ((2021, 1, 6), (2021, 1, 13))    -- S
INTERSECT
SELECT si.order_id AS id, si.item            -- T
  FROM stock_item si
;

-- R . (S /\ R^op . T)
WITH sub AS (
    SELECT co.id
      FROM coop_order co
     WHERE (
            date_part('year', co.ordered_at),
            date_part('month', co.ordered_at),
            date_part('day', co.ordered_at)
           ) IN ((2021, 1, 6), (2021, 1, 13))    -- S
    INTERSECT
    SELECT oi.order_id AS id                                                 -- R^op . T
      FROM stock_item si
      JOIN order_item oi ON si.order_id = oi.order_id AND si.item = oi.item  -- R^op . T
)
SELECT sub.id, oi.item
FROM sub
JOIN order_item oi ON sub.id = oi.order_id -- R
;

EOSQL
