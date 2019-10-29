/*
This is an example of convolutions using sql.
At first we create a table with interactions between users, where "cnt" is a measure of strength of interaction.
Then we create a table with user features.
Temporary table is a join of these tables to get raw features of users with which id1 interacted.
The last sql generated aggreagated features (convolution).
You can try this here: http://sqlfiddle.com/#!9/a7818f/5
*/

CREATE TABLE IF NOT EXISTS `user_interactions` (
  `id1` int(3) unsigned NOT NULL,
  `id2` int(3) unsigned NOT NULL,
  `cnt` int(3) NOT NULL,
  PRIMARY KEY (`id1`,`id2`)
) DEFAULT CHARSET=utf8;
INSERT INTO `user_interactions` (`id1`, `id2`, `cnt`) VALUES
  (1, 2, 1),
  (2, 3, 5),
  (3, 5, 4),
  (1, 3, 6),
  (1, 4, 2),
  (2, 4, 8),
  (4, 5, 5);

CREATE TABLE IF NOT EXISTS `user_features` (
  `id` int(3) unsigned NOT NULL,
  `feat1` int(3) unsigned NOT NULL,
  `feat2` int(3) NOT NULL,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;
INSERT INTO `user_features` (`id`, `feat1`, `feat2`) VALUES
  (1, 10, 3),
  (2, 20, 7),
  (3, 5, 30),
  (4, 2, 8),
  (5, 6, 1);

create table `temp` as
select id1, id2, feat1, feat2, cnt, feat1*cnt as weighted_feat1, feat2*cnt as weighted_feat2
  from user_interactions a
  join user_features b
  on a.id2 = b.id;

select id1, avg(feat1), avg(feat2), sum(weighted_feat1) / sum(cnt) as weighted_avg_feat1,
       sum(weighted_feat2) / sum(cnt) as weighted_avg_feat2
  from temp
 group by id1;
