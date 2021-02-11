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
);

EOSQL
